# rED2

R package for compiling and running the Ecosystem Demography model
([ED2](https://github.com/EDmodel/ED2)). rED2 vendors ED2 `v.2.2.0` and
installs the `edmain` executable inside the package.

## Install

```r
pak::pak("caiohamamuraIFSP/rED2")
```

The package `configure` script prepares ED2, applies portability patches, finds
or builds HDF5, and builds `edmain` during installation.

## Build Options

Default builds use the platform Fortran compiler and HDF5 detected by
`pkg-config`. Intel builds use vcpkg to build an Intel-compatible HDF5 when one
is not already available.

For MPI:

```r
Sys.setenv(RED2_ENABLE_MPI = "yes")
pak::pak("caiohamamuraIFSP/rED2")
```

For Intel compilers on Windows:

```r
Sys.setenv(
  RED2_WINDOWS_TOOLCHAIN = "intel"
)
pak::pak("caiohamamuraIFSP/rED2")
```

For Intel compilers on Linux/WSL:

```r
Sys.setenv(CC = "icx", CXX = "icpx", FC = "ifx", F77 = "ifx")
pak::pak("caiohamamuraIFSP/rED2")
```

To use an existing HDF5 build instead of vcpkg:

```r
Sys.setenv(RED2_HDF5_ROOT = "/path/to/hdf5-prefix")
```

## Run

```r
rED2::edInit()
```

ED2 expects its normal runtime files, including `ED2IN`, in the working
directory.

If ED2 was compiled with MPI:

```r
rED2::edInit(cores = 2)
rED2::edInit(cores = 2, mpi = "yes")
rED2::edInit(mpi = "no")
```

## Development

Local matrix checks are for maintainers:

```sh
sh tools/check_matrix.sh
```
