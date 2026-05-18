#!/bin/sh

set -eu

# Patch the small set of ED2 v2.2.0 source incompatibilities that prevent the
# model executable from building cleanly as part of the rED2 package.
#
# Most of the Windows-only C compatibility code lives in ed2_compat_prefix.h.
# This script only inserts that header and applies source edits that cannot be
# represented safely by a pre-included header.

ed2_dir="${1:-src/ED2}"
edmain="${ed2_dir}/ED/src/driver/edmain.F90"
utils_c="${ed2_dir}/ED/src/utils/utils_c.c"
rsys="${ed2_dir}/ED/src/utils/rsys.F90"
compat_header='../../../../../tools/ed2_compat_prefix.h'

require_file() {
  if ! test -f "$1"; then
    echo "$2 not found: $1" >&2
    exit 1
  fi
}

patch_fortran_argument_handling() {
  # ED2 v2.2.0 uses the non-standard iargc/ugetarg interface and stores
  # C-style NUL-terminated arguments.  Modern gfortran exposes the standard
  # command_argument_count/get_command_argument intrinsics instead.
  perl -0pi \
    -e 's/\n\s*integer\s+::\s+iargc\s*\n/\n/;' \
    -e 's/numarg=iargc\(\)/numarg=command_argument_count()/;' \
    -e 's/call ugetarg\(n,cargx\)/call get_command_argument(n,cargx)/;' \
    -e 's/cargs\(n\)=trim\(cargx\)\/\/char\(0\)/cargs(n)=trim(cargx)/;' \
    -e 's/\n\s*numarg=numarg\+1\s*\n/\n/;' \
    -e 's/name_name = cargs\(n\+1\)\(1:len_trim\(cargs\(n\+1\)\)-1\)/if (n < numarg) name_name = trim(cargs(n+1))/' \
    "$edmain"
}

remove_legacy_inline_scandir_patch() {
  # Older rED2 patch scripts pasted the full Windows scandir fallback into
  # utils_c.c.  Remove that block so the implementation has one home.
  perl -0pi \
    -e 's/\n#if defined\(_WIN32\)\n\/\* rED2 Windows scandir fallback \*\/.*?\n#endif\n\n/\n/s' \
    "$utils_c"
}

include_c_compat_header() {
  if ! grep -Fq "$compat_header" "$utils_c"; then
    perl -0pi \
      -e "s|#include <math\\.h>|#include <math.h>\\n#include \"$compat_header\"|" \
      "$utils_c"
  fi

  perl -0pi \
    -e 's/#include <dirent\.h>/#if !defined(_WIN32)\n#include <dirent.h>\n#endif/g' \
    "$utils_c"
}

patch_c_pointer_width() {
  # ED2 computes a Fortran-visible pointer offset by casting C pointers through
  # int.  That truncates addresses on 64-bit Windows, so use intptr_t instead.
  perl -0pi \
    -e 's/int n, ifaddr, imaddr;/int n;\n  intptr_t ifaddr, imaddr;/;' \
    -e 's/\(int\s*\)ia/(intptr_t)ia/g;' \
    -e 's/\(int\s*\)iaddr/(intptr_t)iaddr/g;' \
    "$utils_c"
}

patch_c_warning_fixes() {
  # These are real C inconsistencies, not platform shims: ignored fread return
  # values and pointer comparisons against the character literal '\0'.
  perl -0pi \
    -e 's/fread\(a,1,\*numbytes,ramsfile\);/if (fread(a,1,*numbytes,ramsfile) != (size_t)*numbytes) return -1;/g;' \
    -e 's/fread\(b,1,80,\s*ramsfile\);/if (fread(b,1,80,ramsfile) != 80) return;/;' \
    -e 's/fread\(b,1,\*n \* nchs,ramsfile\);/if (fread(b,1,*n * nchs,ramsfile) != (size_t)(*n * nchs)) return;/;' \
    -e "s/token != '\\\\0'/token != NULL/g;" \
    -e 's/tfound>1 & val==0/(tfound > 1) \&\& (val == 0)/g;' \
    "$utils_c"
}

patch_windows_cpu_helper() {
  # The Linux sched_getcpu path is not available on Windows.  Keep the original
  # ED2 behavior for SUNHPC/macOS and add Windows to that fallback branch.
  perl -0pi \
    -e 's/#if defined\(SUNHPC\) \|\| defined\(__APPLE__\)(?: \|\| defined\(_WIN32\))*/#if defined(SUNHPC) || defined(__APPLE__) || defined(_WIN32)/;' \
    "$utils_c"
}

patch_windows_sleep_helper() {
  # MSVC does not provide POSIX sleep; use the Win32 API there.  On POSIX
  # builds with strict C99 checks (icx), declare sleep explicitly so we do not
  # rely on implicit declarations.
  perl -0pi \
    -e 's@void irsleep\(int \*seconds\)\s*\{[^}]*\}@void irsleep(int *seconds)\n{\n#if defined(_WIN32)\n   Sleep((DWORD)(*seconds) * 1000U);\n#elif !defined (PC_NT1)\n   extern unsigned int sleep(unsigned int);\n   sleep((unsigned int)(*seconds));\n#endif\n\n   return;\n}@s' \
    "$utils_c"
}

patch_intel_getpid() {
  # Intel Fortran exposes getpid through ifport.  ED2 already uses that module
  # on Intel-specific platforms; include Windows and oneAPI ifx builds in the
  # same path so Linux/WSL Intel builds are covered too.
  random_utils="${ed2_dir}/ED/src/utils/random_utils.F90"
  require_file "$random_utils" "ED2 random utility source"

  perl -0pi \
    -e 's/#if defined\(ODYSSEY\) \|\| defined\(SUNHPC\) \|\| defined\(PC_INTEL\)(?: \|\| defined\(_WIN32\)| \|\| defined\(__INTEL_COMPILER\)| \|\| defined\(__INTEL_LLVM_COMPILER\))*/#if defined(ODYSSEY) || defined(SUNHPC) || defined(PC_INTEL) || defined(__INTEL_COMPILER) || defined(__INTEL_LLVM_COMPILER)/;' \
    "$random_utils"
}

patch_windows_timing() {
  # Intel Fortran on Windows does not provide gfortran's ETIME external.  ED2
  # only needs elapsed CPU time here, so use the standard intrinsic.
  require_file "$rsys" "ED2 system utility source"

  perl -0pi \
    -e 's/#if defined\(CRAY\)\n      call cpu_time\(T1\)/#if defined(CRAY) || defined(_WIN32)\n      call cpu_time(T1)/g' \
    "$rsys"
}

verify_patches() {
  grep -Fq 'command_argument_count()' "$edmain" || {
    echo "ED2 argument parsing patch was not applied to: $edmain" >&2
    exit 1
  }

  grep -Fq "$compat_header" "$utils_c" || {
    echo "ED2 C compatibility header was not included by: $utils_c" >&2
    exit 1
  }

  grep -Fq 'intptr_t ifaddr, imaddr;' "$utils_c" || {
    echo "ED2 pointer-width patch was not applied to: $utils_c" >&2
    exit 1
  }

  grep -Fq 'token != NULL' "$utils_c" || {
    echo "ED2 NULL comparison patch was not applied to: $utils_c" >&2
    exit 1
  }

  grep -Fq '(tfound > 1) && (val == 0)' "$utils_c" || {
    echo "ED2 C warning patch was not applied to: $utils_c" >&2
    exit 1
  }

  grep -Fq 'defined(SUNHPC) || defined(__APPLE__) || defined(_WIN32)' "$utils_c" || {
    echo "ED2 Windows CPU helper patch was not applied to: $utils_c" >&2
    exit 1
  }

  grep -Fq 'Sleep((DWORD)(*seconds) * 1000U)' "$utils_c" || {
    echo "ED2 Windows sleep patch was not applied to: $utils_c" >&2
    exit 1
  }

  grep -Fq 'defined(ODYSSEY) || defined(SUNHPC) || defined(PC_INTEL) || defined(__INTEL_COMPILER) || defined(__INTEL_LLVM_COMPILER)' "${ed2_dir}/ED/src/utils/random_utils.F90" || {
    echo "ED2 Intel getpid patch was not applied to: ${ed2_dir}/ED/src/utils/random_utils.F90" >&2
    exit 1
  }

  grep -Fq 'defined(CRAY) || defined(_WIN32)' "$rsys" || {
    echo "ED2 Windows timing patch was not applied to: $rsys" >&2
    exit 1
  }
}

require_file "$edmain" "ED2 driver source"
require_file "$utils_c" "ED2 C utility source"

patch_fortran_argument_handling
remove_legacy_inline_scandir_patch
include_c_compat_header
patch_c_pointer_width
patch_c_warning_fixes
patch_windows_cpu_helper
patch_windows_sleep_helper
patch_intel_getpid
patch_windows_timing
verify_patches
