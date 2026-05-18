AC_INIT([rED2],[0.0.0.9000])

MAIN="edmain"
R_HOME_SH=`cygpath -u "$R_HOME" 2>/dev/null || printf '%s' "$R_HOME"`
R_BIN="${R_HOME_SH}/bin/R"
R_SCRIPT="${R_HOME_SH}/bin/Rscript"
os_name=`"${R_SCRIPT}" -e "cat(Sys.info()[['sysname']])"`
R_FC=`"${R_BIN}" CMD config FC`
R_LAPACK_LIBS=`"${R_BIN}" CMD config LAPACK_LIBS`
R_BLAS_LIBS=`"${R_BIN}" CMD config BLAS_LIBS`
SHLIB="rED2.so"
RED2_WINDOWS_TOOLCHAIN=${RED2_WINDOWS_TOOLCHAIN:-}
TOOLPATH=""
TOOL_ENV=""
TOOL_LIB=""
TOOL_INCLUDE=""
TOOL_DLL_DIR=""
red2_windows_intel_requested=no

AS_IF([test "x$os_name" = "xWindows" -a "x$RED2_WINDOWS_TOOLCHAIN" = "xintel"],
  [
    red2_windows_intel_requested=yes
    red2_vs_bin=${RED2_VS_BIN:-}
    red2_vs_root=${RED2_VS_ROOT:-}

    AS_IF([test -z "$red2_vs_root"],
      [
        for red2_vswhere in "/c/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe" "/c/Program Files/Microsoft Visual Studio/Installer/vswhere.exe"; do
          AS_IF([test -f "$red2_vswhere"],
            [
              red2_vs_root=`"$red2_vswhere" -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>/dev/null | tr -d '\r'`
              AS_IF([test -n "$red2_vs_root"], [break])
            ])
        done
      ])
    AS_IF([test -z "$red2_vs_root"],
      [
        for red2_candidate in "/c/Program Files/Microsoft Visual Studio/"*/* "/c/Program Files (x86)/Microsoft Visual Studio/"*/*; do
          AS_IF([test -f "$red2_candidate/VC/Auxiliary/Build/vcvars64.bat"], [red2_vs_root="$red2_candidate"])
        done
      ])

    AS_IF([test -n "$red2_vs_root" -a -f "$red2_vs_root/VC/Auxiliary/Build/vcvars64.bat"],
      [
        AC_MSG_NOTICE([importing Visual Studio build environment from $red2_vs_root])
        red2_vcvars=`cygpath -w "$red2_vs_root/VC/Auxiliary/Build/vcvars64.bat" 2>/dev/null || printf '%s' "$red2_vs_root/VC/Auxiliary/Build/vcvars64.bat"`
        red2_env_file=conftest.red2.vcvars.env
        cmd.exe //d //s //c "call \"$red2_vcvars\" >NUL && set" > "$red2_env_file" 2>/dev/null
        red2_imported_lib=`sed -n 's/^[Ll][Ii][Bb]=//p' "$red2_env_file" | head -n 1 | tr -d '\r'`
        red2_imported_include=`sed -n 's/^[Ii][Nn][Cc][Ll][Uu][Dd][Ee]=//p' "$red2_env_file" | head -n 1 | tr -d '\r'`
        red2_imported_vctools=`sed -n 's/^[Vv][Cc][Tt][Oo][Oo][Ll][Ss][Ii][Nn][Ss][Tt][Aa][Ll][Ll][Dd][Ii][Rr]=//p' "$red2_env_file" | head -n 1 | tr -d '\r'`
        rm -f "$red2_env_file"
        AS_IF([test -n "$red2_imported_lib"],
          [
            AS_IF([test -n "$LIB"], [LIB="${red2_imported_lib};${LIB}"], [LIB="$red2_imported_lib"])
            export LIB
          ])
        AS_IF([test -n "$red2_imported_include"],
          [
            AS_IF([test -n "$INCLUDE"], [INCLUDE="${red2_imported_include};${INCLUDE}"], [INCLUDE="$red2_imported_include"])
            export INCLUDE
          ])
        AS_IF([test -z "$red2_vs_bin" -a -n "$red2_imported_vctools"],
          [red2_vs_bin="${red2_imported_vctools}/bin/Hostx64/x64"])
      ])

    AS_IF([test -z "$red2_vs_bin" -a -n "$red2_vs_root"],
      [
        red2_msvc_dir=`ls -d "$red2_vs_root"/VC/Tools/MSVC/* 2>/dev/null | tail -n 1`
        AS_IF([test -n "$red2_msvc_dir" -a -d "$red2_msvc_dir/bin/Hostx64/x64"],
          [red2_vs_bin="$red2_msvc_dir/bin/Hostx64/x64"])
      ])

    AS_IF([test -z "$red2_vs_bin" -a -n "$VCToolsInstallDir" -a -d "${VCToolsInstallDir}/bin/Hostx64/x64"],
      [red2_vs_bin="${VCToolsInstallDir}/bin/Hostx64/x64"])

    AS_IF([test -n "$red2_vs_bin" -a -d "$red2_vs_bin"],
      [
        red2_vs_bin=`cygpath -u "$red2_vs_bin" 2>/dev/null || printf '%s' "$red2_vs_bin"`
        TOOLPATH="$red2_vs_bin"
      ])
    red2_msvc_root=`printf '%s\n' "$red2_vs_bin" | sed 's|/bin/Hostx64/x64$||'`
    AS_IF([test -n "$red2_msvc_root" -a -d "$red2_msvc_root/lib/x64"],
      [
        red2_msvc_lib=`cygpath -m "$red2_msvc_root/lib/x64" 2>/dev/null || printf '%s' "$red2_msvc_root/lib/x64"`
        red2_msvc_include=`cygpath -m "$red2_msvc_root/include" 2>/dev/null || printf '%s' "$red2_msvc_root/include"`
        AS_IF([test -n "$LIB"], [LIB="${red2_msvc_lib};${LIB}"], [LIB="$red2_msvc_lib"])
        AS_IF([test -n "$INCLUDE"], [INCLUDE="${red2_msvc_include};${INCLUDE}"], [INCLUDE="$red2_msvc_include"])
      ])
    red2_sdk_lib=`ls -d "/c/Program Files (x86)/Windows Kits/10/Lib/"* 2>/dev/null | tail -n 1`
    red2_sdk_include=`ls -d "/c/Program Files (x86)/Windows Kits/10/Include/"* 2>/dev/null | tail -n 1`
    AS_IF([test -n "$red2_sdk_lib" -a -d "$red2_sdk_lib/ucrt/x64" -a -d "$red2_sdk_lib/um/x64"],
      [
        red2_sdk_ucrt=`cygpath -m "$red2_sdk_lib/ucrt/x64" 2>/dev/null || printf '%s' "$red2_sdk_lib/ucrt/x64"`
        red2_sdk_um=`cygpath -m "$red2_sdk_lib/um/x64" 2>/dev/null || printf '%s' "$red2_sdk_lib/um/x64"`
        AS_IF([test -n "$LIB"], [LIB="${red2_sdk_ucrt};${red2_sdk_um};${LIB}"], [LIB="${red2_sdk_ucrt};${red2_sdk_um}"])
      ])
    AS_IF([test -n "$red2_sdk_include" -a -d "$red2_sdk_include/ucrt"],
      [
        red2_sdk_include_ucrt=`cygpath -m "$red2_sdk_include/ucrt" 2>/dev/null || printf '%s' "$red2_sdk_include/ucrt"`
        red2_sdk_include_um=`cygpath -m "$red2_sdk_include/um" 2>/dev/null || printf '%s' "$red2_sdk_include/um"`
        red2_sdk_include_shared=`cygpath -m "$red2_sdk_include/shared" 2>/dev/null || printf '%s' "$red2_sdk_include/shared"`
        red2_sdk_include_winrt=`cygpath -m "$red2_sdk_include/winrt" 2>/dev/null || printf '%s' "$red2_sdk_include/winrt"`
        AS_IF([test -n "$INCLUDE"],
          [INCLUDE="${red2_sdk_include_ucrt};${red2_sdk_include_um};${red2_sdk_include_shared};${red2_sdk_include_winrt};${INCLUDE}"],
          [INCLUDE="${red2_sdk_include_ucrt};${red2_sdk_include_um};${red2_sdk_include_shared};${red2_sdk_include_winrt}"])
      ])
    export LIB
    export INCLUDE

    red2_ifx_path=`command -v ifx 2>/dev/null || true`
    AS_IF([test -z "$red2_ifx_path"],
      [
        for red2_candidate in "/c/Program Files (x86)/Intel/oneAPI/compiler/"*/bin "/c/Program Files/Intel/oneAPI/compiler/"*/bin; do
          AS_IF([test -f "$red2_candidate/ifx.exe"], [red2_ifx_path="$red2_candidate/ifx.exe"])
        done
      ])
    red2_ifx_bin=`dirname "${red2_ifx_path:-ifx}"`
    AS_IF([test -d "$red2_ifx_bin"],
      [
        red2_ifx_bin=`cygpath -u "$red2_ifx_bin" 2>/dev/null || printf '%s' "$red2_ifx_bin"`
        red2_ifx_root=`dirname "$red2_ifx_bin"`
        red2_ifx_lib=`cygpath -m "$red2_ifx_root/lib" 2>/dev/null || printf '%s' "$red2_ifx_root/lib"`
        AS_IF([test -n "$LIB"], [LIB="${red2_ifx_lib};${LIB}"], [LIB="$red2_ifx_lib"])
        export LIB
        PATH="${red2_ifx_bin}:$PATH"
        AS_IF([test -n "$TOOLPATH"],
          [TOOLPATH="${TOOLPATH}:${red2_ifx_bin}"],
          [TOOLPATH="$red2_ifx_bin"])
      ])

    CC=${RED2_CC:-icx}
    FC=${RED2_FC:-ifx}
    CFLAGS=${RED2_CFLAGS:--O2}
    FCFLAGS=${RED2_FCFLAGS:--O2 -fpp}
    AS_IF([test -n "$RED2_AR"],
      [AR="$RED2_AR"],
      [
        AS_IF([test -n "$red2_vs_bin" -a -f "${red2_vs_bin}/lib.exe"],
          [AR=`cygpath -m "${red2_vs_bin}/lib.exe" 2>/dev/null || printf '%s' "${red2_vs_bin}/lib.exe"`],
          [AR=lib.exe])
      ])
    AR="\"$AR\""
    ARFLAGS=${RED2_ARFLAGS:--nologo}
    AROUT="-out:"
    TOOL_LIB="$LIB"
    TOOL_INCLUDE="$INCLUDE"
  ],
  [
    : ${CC:=`"${R_BIN}" CMD config CC`}
    : ${CFLAGS:=`"${R_BIN}" CMD config CFLAGS`}
    : ${FCFLAGS:=`"${R_BIN}" CMD config FCFLAGS`}
    : ${AR:=ar}
    : ${ARFLAGS:=rcs}
    AROUT=""
  ])

AC_ARG_ENABLE([mpi],
  [AS_HELP_STRING([--enable-mpi], [build ED2 with MPI support])],
  [enable_mpi=$enableval],
  [enable_mpi=${RED2_ENABLE_MPI:-no}])

AS_CASE([$enable_mpi],
  [yes|no], [],
  [AC_MSG_ERROR([--enable-mpi expects yes or no])])

ED2_DIR="src/ED2"

AC_MSG_NOTICE([preparing ED2 v.2.2.0 sources])
AS_IF([test ! -f "${ED2_DIR}/ED/src/driver/edmain.F90"],
  [AC_MSG_ERROR([vendored ED2 v.2.2.0 sources were not found under ${ED2_DIR}])])

#AC_MSG_NOTICE([regenerating ED2 source and dependency makefiles])
#(cd src && sh build_dependency.sh) || AC_MSG_ERROR([failed to regenerate ED2 dependency makefiles])

CFLAGS="${CFLAGS} -IED2/ED/src/include"

output_files="src/ed2.mk"
AS_IF([test "x$os_name" = "xWindows"],
  [
    CFLAGS="${CFLAGS} -D_WIN32"
    AS_IF([test "x$RED2_WINDOWS_TOOLCHAIN" = "xintel"],
      [FCFLAGS="${FCFLAGS} -D_WIN32 -DGNU"],
      [FCFLAGS="${FCFLAGS} -D_WIN32 -DGNU -mcmodel=medium"])

    MAIN="edmain.exe"
    output_files="src/Makefile.ucrt"
    SHLIB="rED2.dll"
  ]
)


AC_PROG_CC
AC_PROG_RANLIB
AC_LANG([Fortran])
AS_IF([test "x$enable_mpi" = "xyes" -a "x$os_name" != "xWindows"],
  [AC_PROG_FC([mpiifort mpifort mpif90 ifx ifort ${R_FC} gfortran])],
  [AC_PROG_FC([ifx ifort ${R_FC} gfortran])])
AC_MSG_RESULT([$FC])
PKG_PROG_PKG_CONFIG()

red2_windows_intel=no
red2_intel_compiler=no
FC_PROG=`printf '%s\n' "$FC" | sed 's/ .*//'`
FC_BASE=`basename "$FC_PROG" 2>/dev/null || printf '%s' "$FC_PROG"`
AS_IF([test "x$os_name" = "xWindows"],
  [AS_CASE([$FC_BASE], [ifx|ifx.exe|ifort|ifort.exe], [red2_windows_intel=yes])])
AS_CASE([$FC_BASE], [ifx|ifx.exe|ifort|ifort.exe], [red2_intel_compiler=yes])
AC_MSG_NOTICE([selected C compiler: $CC])
AC_MSG_NOTICE([selected Fortran compiler: $FC])

AS_IF([test "x$red2_windows_intel_requested" = "xyes" -a "x$red2_windows_intel" != "xyes"],
  [AC_MSG_ERROR([RED2_WINDOWS_TOOLCHAIN=intel was requested, but configure did not select ifx/ifort. Put Intel oneAPI compiler bin in PATH or set RED2_FC to ifx.])])

AS_IF([test "x$red2_windows_intel" = "xyes"],
  [TOOL_ENV="MSYS2_ARG_CONV_EXCL='*'"])

AS_IF([test "x$os_name" = "xWindows"],
  [
    AS_IF([test "x$red2_windows_intel" != "xyes"],
      [LIBS="${LIBS} ${R_LAPACK_LIBS} ${R_BLAS_LIBS}"])
  ]
)

have_hdf5=no
AS_IF([test "x$red2_windows_intel" = "xyes"],
  [
    red2_hdf5_root=${RED2_HDF5_ROOT:-}

    AS_IF([test -z "$red2_hdf5_root"],
      [
        red2_vcpkg=${VCPKG_ROOT:-}
        AS_IF([test -z "$red2_vcpkg"],
          [
            red2_vcpkg_cmd=`command -v vcpkg 2>/dev/null || command -v vcpkg.exe 2>/dev/null || true`
            AS_IF([test -n "$red2_vcpkg_cmd"],
              [red2_vcpkg=`dirname "$red2_vcpkg_cmd"`])
          ])
        AS_IF([test -n "$red2_vcpkg"],
          [red2_hdf5_root="${red2_vcpkg}/installed/x64-windows-ifx"])
      ])

    AS_IF([test -z "$red2_hdf5_root" -o ! -f "$red2_hdf5_root/include/hdf5.mod" -o ! -f "$red2_hdf5_root/lib/hdf5_fortran.lib"],
      [
        AC_MSG_NOTICE([building Intel-compatible HDF5 with vcpkg])
        red2_overlay=`cygpath -m "$PWD/tools/vcpkg-triplets" 2>/dev/null || printf '%s' "$PWD/tools/vcpkg-triplets"`
        red2_hdf5_root=`MSYS2_ARG_CONV_EXCL='*' sh tools/ensure_vcpkg_hdf5.sh x64-windows-ifx "$red2_overlay"` || AC_MSG_ERROR([failed to build HDF5 with vcpkg])
      ])

    AS_IF([test -n "$red2_hdf5_root"],
      [
        red2_hdf5_root=`cygpath -m "$red2_hdf5_root" 2>/dev/null || printf '%s' "$red2_hdf5_root"`
        AS_IF([test -f "$red2_hdf5_root/include/hdf5.mod" -a -f "$red2_hdf5_root/lib/hdf5_fortran.lib"],
          [
            hdf5_fortran_CFLAGS="-I\"$red2_hdf5_root/include\""
            hdf5_fortran_LIBS="/link /LIBPATH:\"$red2_ifx_lib\" /LIBPATH:\"$red2_hdf5_root/lib\" hdf5_fortran.lib hdf5_f90cstub.lib hdf5.lib z.lib szip.lib aec.lib"
            AS_IF([test -d "$red2_hdf5_root/bin"], [TOOL_DLL_DIR="$red2_hdf5_root/bin"])
            have_hdf5=yes
          ])
      ])
  ])

AS_IF([test "x$have_hdf5" != "xyes" -a "x$os_name" != "xWindows" -a "x$red2_intel_compiler" = "xyes"],
  [
    red2_hdf5_root=${RED2_HDF5_ROOT:-}

    AS_IF([test -z "$red2_hdf5_root" -o ! -f "$red2_hdf5_root/include/hdf5.mod"],
      [
        AC_MSG_NOTICE([building Intel-compatible HDF5 with vcpkg])
        red2_hdf5_root=`sh tools/ensure_vcpkg_hdf5.sh x64-linux-ifx "$PWD/tools/vcpkg-triplets"` || AC_MSG_ERROR([failed to build HDF5 with vcpkg])
      ])
  ])

AS_IF([test "x$have_hdf5" != "xyes" -a "x$os_name" != "xWindows"],
  [
    red2_hdf5_root=${RED2_HDF5_ROOT:-${red2_hdf5_root:-}}

    AS_IF([test -n "$red2_hdf5_root"],
      [
        AS_IF([test -f "$red2_hdf5_root/include/hdf5.mod" -a -f "$red2_hdf5_root/lib/libhdf5_fortran.so"],
          [
            hdf5_fortran_CFLAGS="-I$red2_hdf5_root/include"
            hdf5_fortran_LIBS="-L$red2_hdf5_root/lib -lhdf5_fortran -lhdf5 -Wl,-rpath,'\$\$ORIGIN'"
            TOOL_DLL_DIR="$red2_hdf5_root/lib"
            have_hdf5=yes
          ],
          [
            AS_IF([test -f "$red2_hdf5_root/include/hdf5.mod" -a -f "$red2_hdf5_root/lib/libhdf5_fortran.a"],
              [
                hdf5_fortran_CFLAGS="-I$red2_hdf5_root/include"
                hdf5_fortran_LIBS="-L$red2_hdf5_root/lib -lhdf5_fortran -lhdf5"
                have_hdf5=yes
              ])
          ])
      ])
  ])

AS_IF([test "x$have_hdf5" != "xyes"],
  [PKG_CHECK_MODULES([hdf5_fortran], [hdf5_fortran], [have_hdf5=yes], [have_hdf5=no])])

AS_IF([test "x$enable_mpi" = "xyes"],
  [
    AC_MSG_NOTICE([configuring ED2 with MPI support])
    have_mpi=no

    AS_IF([test "x$os_name" = "xWindows"],
      [
        AS_IF([test "x$red2_windows_intel" = "xyes"],
          [
            red2_mpi_root=${I_MPI_ROOT:-}

            AS_IF([test -z "$red2_mpi_root"],
              [
                red2_ifx_path=`command -v ifx 2>/dev/null || true`
                AS_IF([test -n "$red2_ifx_path"],
                  [
                    red2_oneapi_root=`dirname "$red2_ifx_path"`
                    red2_oneapi_root=`dirname "$red2_oneapi_root"`
                    red2_oneapi_root=`dirname "$red2_oneapi_root"`
                    red2_oneapi_root=`dirname "$red2_oneapi_root"`
                    AS_IF([test -d "$red2_oneapi_root/mpi"],
                      [
                        red2_mpi_candidate=`ls -d "$red2_oneapi_root"/mpi/* 2>/dev/null | sort | tail -n 1`
                        AS_IF([test -n "$red2_mpi_candidate"],
                          [red2_mpi_root="$red2_mpi_candidate"])
                      ])
                  ])
              ])

            AS_IF([test -n "$red2_mpi_root"],
              [
                red2_mpi_root=`cygpath -m "$red2_mpi_root" 2>/dev/null || printf '%s' "$red2_mpi_root"`
                AS_IF([test -f "$red2_mpi_root/include/mpi/mpi.mod" -a -f "$red2_mpi_root/lib/impi.lib"],
                  [
                    MPI_CFLAGS="-I\"$red2_mpi_root/include\" -I\"$red2_mpi_root/include/mpi\""
                    MPI_LIBS="/link /LIBPATH:\"$red2_mpi_root/lib\" impi.lib"
                    red2_mpi_bin=`cygpath -u "$red2_mpi_root/bin" 2>/dev/null || printf '%s' "$red2_mpi_root/bin"`
                    AS_IF([test -n "$TOOLPATH"],
                      [TOOLPATH="$TOOLPATH:$red2_mpi_bin"],
                      [TOOLPATH="$red2_mpi_bin"])
                    have_mpi=yes
                  ])
              ])
          ],
          [PKG_CHECK_MODULES([MPI], [msmpi], [have_mpi=yes], [have_mpi=no])])

        AS_IF([test "x$have_mpi" != "xyes"],
          [
            FC_PROG=`printf '%s\n' "$FC" | sed 's/ .*//'`
            FC_PATH=`command -v "$FC_PROG" 2>/dev/null || true`

            AS_IF([test -n "$FC_PATH"],
              [
                MPI_PREFIX=`dirname "$FC_PATH"`
                MPI_PREFIX=`dirname "$MPI_PREFIX"`

                AS_IF([test -f "$MPI_PREFIX/include/mpi.mod" -a -f "$MPI_PREFIX/lib/libmsmpi.a"],
                  [
                    MPI_CFLAGS="-I$MPI_PREFIX/include"
                    MPI_LIBS="$MPI_PREFIX/lib/libmsmpi.a"
                    have_mpi=yes
                  ])
              ])
          ])
      ],
      [
        AS_IF([test "x$red2_intel_compiler" = "xyes"],
          [
            red2_mpi_root=${I_MPI_ROOT:-}

            AS_IF([test -z "$red2_mpi_root"],
              [
                red2_mpi_candidate=`ls -d /opt/intel/oneapi/mpi/* 2>/dev/null | sort | tail -n 1`
                AS_IF([test -n "$red2_mpi_candidate"],
                  [red2_mpi_root="$red2_mpi_candidate"])
              ])

            AS_IF([test -n "$red2_mpi_root"],
              [
                AS_IF([test -f "$red2_mpi_root/include/mpif.h" -a -f "$red2_mpi_root/lib/libmpi.so"],
                  [
                    MPI_CFLAGS="-I$red2_mpi_root/include"
                    MPI_LIBS="-L$red2_mpi_root/lib -lmpifort -lmpi"
                    AS_IF([test -n "$TOOLPATH"],
                      [TOOLPATH="$TOOLPATH:$red2_mpi_root/bin"],
                      [TOOLPATH="$red2_mpi_root/bin"])
                    have_mpi=yes
                  ])
              ])
          ])

        AS_IF([test "x$have_mpi" != "xyes"],
          [
            MPI_FC=`command -v mpifort 2>/dev/null || command -v mpif90 2>/dev/null || true`

            AS_IF([test -n "$MPI_FC"],
              [
                MPI_CFLAGS=`$MPI_FC --showme:compile 2>/dev/null || true`
                MPI_LIBS=`$MPI_FC --showme:link 2>/dev/null || true`

                AS_IF([test -n "$MPI_LIBS"],
                  [have_mpi=yes])
              ])
          ])

        AS_IF([test "x$have_mpi" != "xyes"],
          [
            PKG_CHECK_MODULES([MPI], [mpi-fort], [have_mpi=yes], [have_mpi=no])
          ])
      ])

    AS_IF([test "x$have_mpi" = "xyes"],
      [
        AS_IF([test "x$red2_intel_compiler" = "xyes"],
          [FCFLAGS="${FCFLAGS} ${MPI_CFLAGS} -DRAMS_MPI"],
          [FCFLAGS="${FCFLAGS} ${MPI_CFLAGS} -DRAMS_MPI -fallow-invalid-boz -fallow-argument-mismatch -w"])
        LIBS="${LIBS} ${MPI_LIBS}"
      ],
      [AC_MSG_ERROR([MPI support was requested but MPI headers/libraries were not found])])
  ])

AS_IF([test "x$os_name" = "xWindows" -a "x$have_hdf5" = "xyes"],
  [
    hdf5_libdir=`$PKG_CONFIG --variable=libdir hdf5_fortran 2>/dev/null`
    AS_IF([test -n "$hdf5_libdir"],
      [
        AS_IF([test -f "$hdf5_libdir/libz.a"],
          [hdf5_fortran_LIBS=`printf '%s\n' "$hdf5_fortran_LIBS" | sed "s|-lz|$hdf5_libdir/libz.a|g"`])
        AS_IF([test -f "$hdf5_libdir/libsz.a"],
          [hdf5_fortran_LIBS=`printf '%s\n' "$hdf5_fortran_LIBS" | sed "s|-lsz|$hdf5_libdir/libsz.a|g"`])
        AS_IF([test -f "$hdf5_libdir/libaec.a"],
          [hdf5_fortran_LIBS=`printf '%s\n' "$hdf5_fortran_LIBS" | sed "s|-laec|$hdf5_libdir/libaec.a|g"`])
      ])
  ])

AS_IF([test "x$have_hdf5" = "xyes"],
  [
    LIBS="${LIBS} ${hdf5_fortran_LIBS} ${MPILIBS}"
    FCFLAGS="${FCFLAGS} ${hdf5_fortran_CFLAGS}"
    AS_IF([test "x$red2_windows_intel" = "xyes"],
      [CFLAGS="${CFLAGS} -D_CRT_SECURE_NO_WARNINGS"])
  ],
  [
    PKG_CHECK_MODULES([HDF5], [hdf5], [have_hdf5=yes], [have_hdf5=no])
    
    AS_IF([test "x$have_hdf5" = "xyes"],
      [
        LIBS="${LIBS} ${HDF5_LIBS} -lhdf5 -lhdf5_fortran"
        FCFLAGS="${FCFLAGS} ${HDF5_CFLAGS}"

        AC_MSG_CHECKING([for HDF5 support in Fortran])
        AC_LANG_PUSH([Fortran])

        AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
              use hdf5
              integer :: hdferr
              call h5open_f(hdferr)
              call h5close_f(hdferr)
        ]])],
        [AC_MSG_RESULT([yes])
        HDF5_OK=yes],
        [AC_MSG_RESULT([no])
        HDF5_OK=no])

        AC_LANG_POP([Fortran])
      ],
      [have_hdf5=no])
  ]
)

AS_IF([test "x$have_hdf5" = "xno"],[
      AC_MSG_ERROR([
HDF5 library not found!

Please install HDF5 library and try again:

    Debian: sudo apt-get install libhdf5-dev
    Fedora: sudo dnf install hdf5-devel
    CentOS: sudo yum install hdf5-devel
    MacOS: brew install hdf5
    Windows MinGW: pacman -S mingw-w64-x86_64-hdf5
      ])
])


AC_SUBST([CC])
AC_SUBST([FC])
AC_SUBST([AR])
AC_SUBST([ARFLAGS])
AC_SUBST([AROUT])
AC_SUBST([SHLIB])
AC_SUBST([MAIN])
AC_SUBST([LIBS])
AC_SUBST([FCFLAGS])
AC_SUBST([CFLAGS])
AC_SUBST([TOOLPATH])
AC_SUBST([TOOL_ENV])
AC_SUBST([TOOL_LIB])
AC_SUBST([TOOL_INCLUDE])
AC_SUBST([TOOL_DLL_DIR])
AC_CONFIG_FILES([${output_files}:src/ed2.mk.in])
AC_OUTPUT
