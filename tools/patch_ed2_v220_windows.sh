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
    "$utils_c"
}

patch_windows_cpu_helper() {
  # The Linux sched_getcpu path is not available on Windows.  Keep the original
  # ED2 behavior for SUNHPC/macOS and add Windows to that fallback branch.
  perl -0pi \
    -e 's/#if defined\(SUNHPC\) \|\| defined\(__APPLE__\)(?: \|\| defined\(_WIN32\))*/#if defined(SUNHPC) || defined(__APPLE__) || defined(_WIN32)/;' \
    "$utils_c"
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

  grep -Fq 'defined(SUNHPC) || defined(__APPLE__) || defined(_WIN32)' "$utils_c" || {
    echo "ED2 Windows CPU helper patch was not applied to: $utils_c" >&2
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
verify_patches
