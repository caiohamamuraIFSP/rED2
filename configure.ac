AC_INIT([rED2],[0.0.0.9000])

MAIN="edmain"
os_name=`"${R_HOME}/bin/Rscript" -e "cat(Sys.info()[['sysname']])"`
CC=`${R_HOME}/bin/R CMD config CC`
R_FC=`${R_HOME}/bin/R CMD config FC`
CFLAGS=`${R_HOME}/bin/R CMD config CFLAGS`
FCFLAGS=`${R_HOME}/bin/R CMD config FCFLAGS`
R_LAPACK_LIBS=`${R_HOME}/bin/R CMD config LAPACK_LIBS`
R_BLAS_LIBS=`${R_HOME}/bin/R CMD config BLAS_LIBS`
SHLIB="rED2.so"

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

AS_IF([test "x$downloaded_ed2" = "xyes"],
  [
    AC_MSG_NOTICE([pruning downloaded ED2 tree to compiled sources])
    find "${ED2_DIR}" -mindepth 1 -maxdepth 1 ! -name ED -exec rm -rf {} +
    find "${ED2_DIR}/ED" -mindepth 1 -maxdepth 1 ! -name src -exec rm -rf {} +
  ])

AC_MSG_NOTICE([applying ED2 Windows compatibility patches])
sh tools/patch_ed2_v220_windows.sh "${ED2_DIR}" || AC_MSG_ERROR([failed to patch ED2 v.2.2.0 for Windows])

AC_MSG_NOTICE([regenerating ED2 source and dependency makefiles])
(cd src && sh build_dependency.sh) || AC_MSG_ERROR([failed to regenerate ED2 dependency makefiles])

CFLAGS="${CFLAGS} -I\"ED2/ED/src/include\""

output_files="src/Makefile"
AS_IF([test "x$os_name" = "xWindows"],
  [
    CFLAGS="${CFLAGS} -D_WIN32"
    FCFLAGS="${FCFLAGS} -D_WIN32 -DGNU -mcmodel=medium"

    MAIN="edmain.exe"
    output_files="src/Makefile.ucrt"
    SHLIB="rED2.dll"
  ]
)


AC_PROG_CC
AC_PROG_RANLIB
AC_LANG([Fortran])
AC_PROG_FC([ifx ifort mpif90 ${R_FC} gfortran])
AC_MSG_RESULT([$FC])
PKG_PROG_PKG_CONFIG()

AS_IF([test "x$os_name" = "xWindows"],
  [
    LIBS="${LIBS} ${R_LAPACK_LIBS} ${R_BLAS_LIBS}"
  ]
)

PKG_CHECK_MODULES([hdf5_fortran], [hdf5_fortran], [have_hdf5=yes], [have_hdf5=no])

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

AS_IF([test "x$FC" = "xmpif90"],
  [
    AS_IF([test "x$os_name" != "xDarwin" -a "x$os_name" != "xLinux"],
      [
        PKG_CHECK_MODULES([MPI], [msmpi], [have_mpi=yes], [have_mpi=no])
      ],
      [
        PKG_CHECK_MODULES([MPI], [mpi-fort], [have_mpi=yes], [have_mpi=no])
      ]
    )

    AS_IF([test "x$have_mpi" = "xyes"],
      [
        FCFLAGS="${FCFLAGS} ${MPI_CFLAGS}  -DRAMS_MPI -fallow-invalid-boz -fallow-argument-mismatch"
        LIBS="${LIBS} ${MPI_LIBS}"
        AC_PROG_FC([mpiifort ifx ifort mpifort mpif90 ${R_FC}])
      ],
      [
        AC_PROG_FC([ifx ifort])
      ]
    )
  ]
)


AS_IF([test "x$have_hdf5" = "xyes"],
  [
    LIBS="${LIBS} ${hdf5_fortran_LIBS} ${MPILIBS}"
    FCFLAGS="${FCFLAGS} ${hdf5_fortran_CFLAGS}"
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
AC_SUBST([SHLIB])
AC_SUBST([MAIN])
AC_SUBST([LIBS])
AC_SUBST([FCFLAGS])
AC_SUBST([CFLAGS])
AC_CONFIG_FILES([${output_files}:src/Makefile.in])
AC_OUTPUT
