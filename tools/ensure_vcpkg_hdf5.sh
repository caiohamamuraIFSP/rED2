#!/bin/sh

set -eu

triplet=${1:?triplet is required}
overlay=${2:?overlay triplets directory is required}

case "$(uname -s 2>/dev/null || printf unknown)" in
  MINGW*|MSYS*|CYGWIN*) os=windows ;;
  *) os=unix ;;
esac

if [ "$os" != windows ] && [ -d /opt/intel/oneapi/compiler/latest ]; then
  PATH="/opt/intel/oneapi/compiler/latest/bin:$PATH"
  export PATH
  LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/lib:${LD_LIBRARY_PATH:-}"
  export LD_LIBRARY_PATH
fi

find_vcpkg_root() {
  if [ -n "${RED2_VCPKG_ROOT:-}" ]; then
    printf '%s\n' "$RED2_VCPKG_ROOT"
    return
  fi
  if [ -n "${VCPKG_ROOT:-}" ] && { [ "$os" = windows ] || ! printf '%s\n' "$VCPKG_ROOT" | grep -q '^/mnt/'; }; then
    printf '%s\n' "$VCPKG_ROOT"
    return
  fi
  if command -v vcpkg >/dev/null 2>&1; then
    vcpkg_cmd=$(command -v vcpkg)
    if [ "$os" = windows ] || ! printf '%s\n' "$vcpkg_cmd" | grep -q '^/mnt/'; then
      dirname "$vcpkg_cmd"
      return
    fi
  fi
  if command -v vcpkg.exe >/dev/null 2>&1; then
    vcpkg_cmd=$(command -v vcpkg.exe)
    if [ "$os" = windows ] || ! printf '%s\n' "$vcpkg_cmd" | grep -q '^/mnt/'; then
      dirname "$vcpkg_cmd"
      return
    fi
  fi

  if [ "$os" = windows ]; then
    local_data=${LOCALAPPDATA:-"$HOME/AppData/Local"}
    if command -v cygpath >/dev/null 2>&1; then
      local_data=$(cygpath -u "$local_data")
    fi
    printf '%s\n' "$local_data/rED2/vcpkg"
  else
    cache=${XDG_CACHE_HOME:-"$HOME/.cache"}
    printf '%s\n' "$cache/rED2/vcpkg"
  fi
}

bootstrap_vcpkg() {
  root=$1
  if [ "$os" = windows ]; then
    if [ -x "$root/vcpkg.exe" ]; then
      return
    fi
    (cd "$root" && cmd //c bootstrap-vcpkg.bat >/dev/null)
  else
    if [ -x "$root/vcpkg" ]; then
      return
    fi
    (cd "$root" && ./bootstrap-vcpkg.sh -disableMetrics >/dev/null)
  fi
}

vcpkg_root=$(find_vcpkg_root)

if [ ! -d "$vcpkg_root/.git" ]; then
  mkdir -p "$(dirname "$vcpkg_root")"
  git clone https://github.com/microsoft/vcpkg "$vcpkg_root" >/dev/null
fi

bootstrap_vcpkg "$vcpkg_root"

if [ "$os" = windows ]; then
  vcpkg_exe="$vcpkg_root/vcpkg.exe"
else
  vcpkg_exe="$vcpkg_root/vcpkg"
fi

if [ ! -x "$vcpkg_exe" ]; then
  echo "vcpkg executable was not found after bootstrap" >&2
  exit 1
fi

if [ ! -f "$vcpkg_root/installed/$triplet/include/hdf5.mod" ]; then
  "$vcpkg_exe" install "hdf5[fortran]:$triplet" --overlay-triplets="$overlay" >&2
fi

printf '%s\n' "$vcpkg_root/installed/$triplet"
