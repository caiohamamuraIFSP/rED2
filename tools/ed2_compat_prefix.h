#ifndef RED2_ED2_COMPAT_PREFIX_H
#define RED2_ED2_COMPAT_PREFIX_H

#include <stdint.h>

#if defined(_WIN32)
#include <stdlib.h>
#include <string.h>
#include <windows.h>

struct dirent {
  char d_name[MAX_PATH];
};

#if defined(__INTEL_LLVM_COMPILER)
#define filelist_c_ FILELIST_C
#define findmycpu_ FINDMYCPU
#endif

/*
 * ED2 v2.2.0 assumes POSIX scandir/alphasort are available.  Rtools provides
 * dirent-compatible directory iteration, but Intel/MSVC does not.  Keep the
 * small Windows fallback here instead of pasting it into downloaded ED2 sources.
 */
static int alphasort(const struct dirent **a, const struct dirent **b)
{
  return strcmp((*a)->d_name, (*b)->d_name);
}

static int scandir(const char *dirname, struct dirent ***namelist,
                   int (*select)(const struct dirent *),
                   int (*compar)(const struct dirent **,
                                 const struct dirent **))
{
  HANDLE find_handle;
  WIN32_FIND_DATAA find_data;
  char pattern[MAX_PATH];
  struct dirent **entries = NULL;
  int count = 0;
  int capacity = 0;

  if (snprintf(pattern, sizeof(pattern), "%s\\*", dirname) < 0) return -1;

  find_handle = FindFirstFileA(pattern, &find_data);
  if (find_handle == INVALID_HANDLE_VALUE) return -1;

  do {
    struct dirent **new_entries;
    struct dirent *copy;
    struct dirent entry;
    size_t name_len;

    name_len = strlen(find_data.cFileName);
    if (name_len >= sizeof(entry.d_name)) name_len = sizeof(entry.d_name) - 1;
    memcpy(entry.d_name, find_data.cFileName, name_len);
    entry.d_name[name_len] = '\0';

    if (select != NULL && !select(&entry)) continue;

    if (count == capacity) {
      capacity = capacity == 0 ? 16 : capacity * 2;
      new_entries = realloc(entries, capacity * sizeof(*entries));
      if (new_entries == NULL) {
        FindClose(find_handle);
        while (count > 0) free(entries[--count]);
        free(entries);
        return -1;
      }
      entries = new_entries;
    }

    copy = malloc(sizeof(*copy));
    if (copy == NULL) {
      FindClose(find_handle);
      while (count > 0) free(entries[--count]);
      free(entries);
      return -1;
    }

    memcpy(copy, &entry, sizeof(*copy));
    entries[count++] = copy;
  } while (FindNextFileA(find_handle, &find_data));

  FindClose(find_handle);
  if (compar != NULL) {
    qsort(entries, count, sizeof(*entries),
          (int (*)(const void *, const void *))compar);
  }

  *namelist = entries;
  return count;
}
#endif

#endif
