AC_INIT([rED2],[m4_esyscmd_s([sed -n 's/.*ED_VERSION=\(.*\)/\1/p' src/ED2/ED/build/make/paths.mk])])

MAIN="edmain"
os_name=`"${R_HOME}/bin/Rscript" -e "cat(Sys.info()[['sysname']])"`
CC=`${R_HOME}/bin/R CMD config CC`
R_FC=`${R_HOME}/bin/R CMD config FC`
CFLAGS=`${R_HOME}/bin/R CMD config CFLAGS`
FCFLAGS=`${R_HOME}/bin/R CMD config FCFLAGS`
SHLIB="rED2.so"

CFLAGS="${CFLAGS} -I\"ED2/ED/src/include\""

output_files="src/Makefile"
AS_IF([test "x$os_name" = "xWindows"],
  [
    mv /ucrt64 /ucrt64.bak
    mkdir /ucrt64
    pacman -S mingw-w64-ucrt-x86_64-hdf5 --noconfirm
    cp -R /ucrt64/* /x86_64-w64-mingw32.static.posix
    rm -rf /ucrt64 && mv /ucrt64.bak /ucrt64

    CFLAGS="${CFLAGS} -D_WIN32"
    FCFLAGS="${FCFLAGS} -D_WIN32"

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

PKG_CHECK_MODULES([hdf5_fortran], [hdf5_fortran], [have_hdf5=yes], [have_hdf5=no])

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