#!/bin/sh

set -eu

prefix=${1:?installation prefix is required}
version=${HDF5_VERSION:-1.14.6}
cache=${HDF5_BUILD_CACHE:-"${TMPDIR:-/tmp}/red2-hdf5"}
src="$cache/hdf5-hdf5_$version"
tarball="$cache/hdf5-$version.tar.gz"
build="$cache/build-$version-$(basename "$prefix")"

if [ -f "$prefix/include/hdf5.mod" ]; then
  printf '%s\n' "$prefix"
  exit 0
fi

mkdir -p "$cache" "$prefix"

if [ ! -d "$src" ]; then
  if [ ! -f "$tarball" ]; then
    curl -L "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_$version.tar.gz" -o "$tarball"
  fi
  tar -xzf "$tarball" -C "$cache"
fi

rm -rf "$build"
mkdir -p "$build"

: "${HDF5_FC:=gfortran}"
: "${HDF5_CC:=clang}"
: "${HDF5_FFLAGS:=}"

cmake -S "$src" -B "$build" \
  -DCMAKE_INSTALL_PREFIX="$prefix" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$HDF5_CC" \
  -DCMAKE_Fortran_COMPILER="$HDF5_FC" \
  -DCMAKE_Fortran_FLAGS="$HDF5_FFLAGS" \
  -DBUILD_SHARED_LIBS=ON \
  -DHDF5_BUILD_FORTRAN=ON \
  -DHDF5_BUILD_HL_LIB=ON \
  -DHDF5_BUILD_CPP_LIB=OFF \
  -DHDF5_BUILD_EXAMPLES=OFF \
  -DHDF5_BUILD_TOOLS=OFF \
  -DHDF5_BUILD_UTILS=OFF \
  -DHDF5_ENABLE_Z_LIB_SUPPORT=OFF \
  -DHDF5_ENABLE_SZIP_SUPPORT=OFF \
  -DBUILD_TESTING=OFF

cmake --build "$build" --parallel 2
cmake --install "$build"

printf '%s\n' "$prefix"
