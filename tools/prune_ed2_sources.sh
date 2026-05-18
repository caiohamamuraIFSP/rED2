#!/bin/sh

set -eu

ed2_dir="${1:-src/ED2}"
sources_mk="${2:-src/sources.mk}"
sources_root=$(dirname "$sources_mk")
ed_dir="${ed2_dir}/ED"
ed_src="${ed_dir}/src"

require_dir() {
  if [ ! -d "$1" ]; then
    echo "Required directory not found: $1" >&2
    exit 1
  fi
}

require_file() {
  if [ ! -f "$1" ]; then
    echo "Required file not found: $1" >&2
    exit 1
  fi
}

keep_file_list() {
  sed 's/^SOURCES[[:space:]]*=[[:space:]]*//' "$sources_mk" \
    | tr ' ' '\n' \
    | sed '/^$/d'
  printf '%s\n' 'ED2/ED/src/driver/edmain.F90'
}

prune_non_source_dirs() {
  find "$ed2_dir" -mindepth 1 -maxdepth 1 ! -name ED -exec rm -rf {} +
  find "$ed_dir" -mindepth 1 -maxdepth 1 ! -name src -exec rm -rf {} +

  for dir in doc preproc test_cases; do
    rm -rf "${ed_src}/${dir}"
  done
}

prune_unlisted_compile_files() {
  tmp_keep="${TMPDIR:-/tmp}/red2-ed2-keep.$$"
  trap 'rm -f "$tmp_keep"' EXIT

  keep_file_list > "$tmp_keep"

  find "$ed_src" -type f | while IFS= read -r path; do
    rel_path=${path#${sources_root}/}

    case "$rel_path" in
      ED2/ED/src/include/*)
        continue
        ;;
    esac

    if ! grep -Fxq "$rel_path" "$tmp_keep"; then
      rm -f "$path"
    fi
  done

  find "$ed_src" -type d -empty -delete
}

require_dir "$ed_dir"
require_dir "$ed_src"
require_file "$sources_mk"

prune_non_source_dirs
prune_unlisted_compile_files
