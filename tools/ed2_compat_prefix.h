#ifndef RED2_ED2_COMPAT_PREFIX_H
#define RED2_ED2_COMPAT_PREFIX_H

#include <stdint.h>

#if defined(_WIN32)
#include <dirent.h>
#include <stdlib.h>
#include <string.h>

/*
 * ED2 v2.2.0 assumes POSIX scandir/alphasort are available.  Rtools provides
 * dirent-compatible directory iteration, but not these helpers, so rED2 keeps
 * the small Windows fallback here instead of pasting it into downloaded ED2
 * sources.
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
  DIR *dirp;
  struct dirent *entry;
  struct dirent **entries = NULL;
  int count = 0;
  int capacity = 0;

  dirp = opendir(dirname);
  if (dirp == NULL) return -1;

  while ((entry = readdir(dirp)) != NULL) {
    struct dirent **new_entries;
    struct dirent *copy;

    if (select != NULL && !select(entry)) continue;

    if (count == capacity) {
      capacity = capacity == 0 ? 16 : capacity * 2;
      new_entries = realloc(entries, capacity * sizeof(*entries));
      if (new_entries == NULL) {
        closedir(dirp);
        while (count > 0) free(entries[--count]);
        free(entries);
        return -1;
      }
      entries = new_entries;
    }

    copy = malloc(sizeof(*copy));
    if (copy == NULL) {
      closedir(dirp);
      while (count > 0) free(entries[--count]);
      free(entries);
      return -1;
    }

    memcpy(copy, entry, sizeof(*copy));
    entries[count++] = copy;
  }

  closedir(dirp);
  if (compar != NULL) {
    qsort(entries, count, sizeof(*entries),
          (int (*)(const void *, const void *))compar);
  }

  *namelist = entries;
  return count;
}
#endif

#endif
