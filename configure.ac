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

AS_IF([test "x$os_name" = "xWindows" -a "x$RED2_WINDOWS_TOOLCHAIN" = "xintel"],
  [
    red2_vs_bin=${RED2_VS_BIN:-}
    AS_IF([test -z "$red2_vs_bin" -a -n "$VCToolsInstallDir" -a -d "${VCToolsInstallDir}/bin/Hostx64/x64"],
      [red2_vs_bin="${VCToolsInstallDir}/bin/Hostx64/x64"])

    AS_IF([test -n "$red2_vs_bin" -a -d "$red2_vs_bin"],
      [
        red2_vs_bin=`cygpath -u "$red2_vs_bin" 2>/dev/null || printf '%s' "$red2_vs_bin"`
        TOOLPATH="$red2_vs_bin"
      ])
    red2_ifx_bin=`dirname "$(command -v ifx 2>/dev/null || printf ifx)"`
    AS_IF([test -d "$red2_ifx_bin"],
      [
        red2_ifx_bin=`cygpath -u "$red2_ifx_bin" 2>/dev/null || printf '%s' "$red2_ifx_bin"`
        red2_ifx_root=`dirname "$red2_ifx_bin"`
        red2_ifx_lib=`cygpath -m "$red2_ifx_root/lib" 2>/dev/null || printf '%s' "$red2_ifx_root/lib"`
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

ED2_URL="https://github.com/EDmodel/ED2/archive/refs/tags/v.2.2.0.zip"
ED2_ZIP="src/ED2-v.2.2.0.zip"
ED2_DIR="src/ED2"
ED2_UNPACKED="src/ED2-v.2.2.0"
downloaded_ed2=no

AC_MSG_NOTICE([preparing ED2 v.2.2.0 sources])
AS_IF([test ! -f "${ED2_DIR}/ED/src/driver/edmain.F90"],
  [
    AC_MSG_NOTICE([downloading ED2 from ${ED2_URL}])
    rm -rf "${ED2_DIR}" "${ED2_UNPACKED}" "${ED2_ZIP}"
    ${CURL:-curl} -L -o "${ED2_ZIP}" "${ED2_URL}" || AC_MSG_ERROR([failed to download ED2 v.2.2.0])
    unzip -q "${ED2_ZIP}" -d src || AC_MSG_ERROR([failed to unpack ED2 v.2.2.0])
    mv "${ED2_UNPACKED}" "${ED2_DIR}" || AC_MSG_ERROR([failed to move ED2 sources into place])
    rm -f "${ED2_ZIP}"
    downloaded_ed2=yes
  ])

AC_MSG_NOTICE([applying ED2 Windows compatibility patches])
sh tools/patch_ed2_v220_windows.sh "${ED2_DIR}" || AC_MSG_ERROR([failed to patch ED2 v.2.2.0 for Windows])

AC_MSG_NOTICE([regenerating ED2 source and dependency makefiles])
(cd src && sh build_dependency.sh) || AC_MSG_ERROR([failed to regenerate ED2 dependency makefiles])

CFLAGS="${CFLAGS} -I\"ED2/ED/src/include\""

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
            hdf5_fortran_LIBS="-L$red2_hdf5_root/lib -lhdf5_fortran -lhdf5"
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
AC_CONFIG_FILES([${output_files}:src/ed2.mk.in])
AC_OUTPUT
