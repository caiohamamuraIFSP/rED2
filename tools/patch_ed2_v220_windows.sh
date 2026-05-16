#!/bin/sh

set -eu

ed2_dir="${1:-src/ED2}"
edmain="${ed2_dir}/ED/src/driver/edmain.F90"
utils_c="${ed2_dir}/ED/src/utils/utils_c.c"

test -f "$edmain" || {
  echo "ED2 driver source not found: $edmain" >&2
  exit 1
}

test -f "$utils_c" || {
  echo "ED2 C utility source not found: $utils_c" >&2
  exit 1
}

perl -0pi -e 's/\n\s*integer\s+::\s+iargc\s*\n/\n/; s/numarg=iargc\(\)/numarg=command_argument_count()/; s/call ugetarg\(n,cargx\)/call get_command_argument(n,cargx)/; s/cargs\(n\)=trim\(cargx\)\/\/char\(0\)/cargs(n)=trim(cargx)/; s/\n\s*numarg=numarg\+1\s*\n/\n/; s/name_name = cargs\(n\+1\)\(1:len_trim\(cargs\(n\+1\)\)-1\)/if (n < numarg) name_name = trim(cargs(n+1))/' "$edmain"

perl -0pi -e 's/#include <math\.h>/#include <math.h>\n#include <stdint.h>/; s/int n, ifaddr, imaddr;/int n;\n  intptr_t ifaddr, imaddr;/; s/\(int\s*\)ia/(intptr_t)ia/g; s/\(int\s*\)iaddr/(intptr_t)iaddr/g; s/fread\(a,1,\*numbytes,ramsfile\);/if (fread(a,1,*numbytes,ramsfile) != (size_t)*numbytes) return -1;/g; s/fread\(b,1,80,\s*ramsfile\);/if (fread(b,1,80,ramsfile) != 80) return;/; s/fread\(b,1,\*n \* nchs,ramsfile\);/if (fread(b,1,*n * nchs,ramsfile) != (size_t)(*n * nchs)) return;/; s/token != '\''\\0'\''/token != NULL/g' "$utils_c"

if ! grep -q 'rED2 Windows scandir fallback' "$utils_c"; then
  perl -0pi -e 's/#include <dirent\.h>\s*\n#include <string\.h>\s*/#include <dirent.h>\n#include <string.h>\n\n#if defined(_WIN32)\n\/\* rED2 Windows scandir fallback \*\/\nstatic int alphasort(const struct dirent **a, const struct dirent **b)\n{\n  return strcmp((*a)->d_name, (*b)->d_name);\n}\n\nstatic int scandir(const char *dirname, struct dirent ***namelist,\n                   int (*select)(const struct dirent *),\n                   int (*compar)(const struct dirent **, const struct dirent **))\n{\n  DIR *dirp;\n  struct dirent *entry;\n  struct dirent **entries = NULL;\n  int count = 0;\n  int capacity = 0;\n\n  dirp = opendir(dirname);\n  if (dirp == NULL) return -1;\n\n  while ((entry = readdir(dirp)) != NULL) {\n    struct dirent **new_entries;\n    struct dirent *copy;\n\n    if (select != NULL && !select(entry)) continue;\n\n    if (count == capacity) {\n      capacity = capacity == 0 ? 16 : capacity * 2;\n      new_entries = realloc(entries, capacity * sizeof(*entries));\n      if (new_entries == NULL) {\n        closedir(dirp);\n        while (count > 0) free(entries[--count]);\n        free(entries);\n        return -1;\n      }\n      entries = new_entries;\n    }\n\n    copy = malloc(sizeof(*copy));\n    if (copy == NULL) {\n      closedir(dirp);\n      while (count > 0) free(entries[--count]);\n      free(entries);\n      return -1;\n    }\n    memcpy(copy, entry, sizeof(*copy));\n    entries[count++] = copy;\n  }\n\n  closedir(dirp);\n  if (compar != NULL) qsort(entries, count, sizeof(*entries),\n                            (int (*)(const void *, const void *))compar);\n  *namelist = entries;\n  return count;\n}\n#endif\n\n/' "$utils_c"
fi

perl -0pi -e 's/#if defined\(SUNHPC\) \|\| defined\(__APPLE__\)/#if defined(SUNHPC) || defined(__APPLE__) || defined(_WIN32)/' "$utils_c"

grep -q 'rED2 Windows scandir fallback' "$utils_c" || {
  echo "ED2 Windows scandir patch was not applied to: $utils_c" >&2
  exit 1
}

grep -q 'defined(SUNHPC) || defined(__APPLE__) || defined(_WIN32)' "$utils_c" || {
  echo "ED2 Windows CPU helper patch was not applied to: $utils_c" >&2
  exit 1
}

grep -q 'command_argument_count()' "$edmain" || {
  echo "ED2 argument parsing patch was not applied to: $edmain" >&2
  exit 1
}
