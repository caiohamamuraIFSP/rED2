set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED LIB PATH)

set(_red2_intel_oneapi_root "C:/Program Files (x86)/Intel/oneAPI")

file(GLOB _red2_ifx_candidates
  "${_red2_intel_oneapi_root}/compiler/*/bin/ifx.exe"
  "C:/Program Files/Intel/oneAPI/compiler/*/bin/ifx.exe")
list(SORT _red2_ifx_candidates)
list(REVERSE _red2_ifx_candidates)
list(GET _red2_ifx_candidates 0 _red2_ifx)

get_filename_component(_red2_ifx_bin "${_red2_ifx}" DIRECTORY)
get_filename_component(_red2_ifx_version_dir "${_red2_ifx_bin}" DIRECTORY)
set(_red2_ifx_lib "${_red2_ifx_version_dir}/lib")

string(APPEND VCPKG_LINKER_FLAGS " /LIBPATH:\"${_red2_ifx_lib}\"")

list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_Fortran_COMPILER=${_red2_ifx}")
