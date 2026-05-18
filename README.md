# rED2

R package for compiling and running the Ecosystem Demography model
([ED2](https://github.com/EDmodel/ED2)). rED2 vendors ED2 `v.2.2.0` and
installs the `edmain` executable inside the package.

## Install

```r
pak::pak("caiohamamuraIFSP/rED2")
```

The package `configure` script uses the vendored ED2 sources in `src/`, finds or
builds HDF5, and builds `edmain` during installation.

## Build Options

Default builds use the platform Fortran compiler and HDF5 detected by
`pkg-config`. Intel builds use vcpkg to build an Intel-compatible HDF5 when one
is not already available.

For MPI:

```r
Sys.setenv(RED2_ENABLE_MPI = "yes")
pak::pak("caiohamamuraIFSP/rED2")
```

For Intel compilers on Windows, install Intel oneAPI and MSVC build tools first.
The Base Toolkit provides `icx`; the HPC Toolkit provides the Fortran compiler
`ifx`, which ED2 needs.

```powershell
winget install --id Intel.OneAPI.BaseToolkit -e
winget install --id Intel.OneAPI.HPCToolkit -e
winget install Microsoft.VisualStudio.BuildTools --force --override "--wait --passive --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100 --includeRecommended"
```

Then install from R:

```r
Sys.setenv(
  RED2_WINDOWS_TOOLCHAIN = "intel"
)
pak::pak("caiohamamuraIFSP/rED2")
```

The installer finds the default oneAPI, Visual Studio, Windows SDK, and vcpkg
locations. If oneAPI is installed somewhere else, add its compiler `bin`
directory:

```r
oneapi_bin <- "C:/path/to/Intel/oneAPI/compiler/latest/bin"
Sys.setenv(
  PATH = paste(oneapi_bin, Sys.getenv("PATH"), sep = .Platform$path.sep),
  CC = "icx",
  CXX = "icpx",
  FC = "ifx",
  F77 = "ifx",
  RED2_WINDOWS_TOOLCHAIN = "intel"
)
pak::pak("caiohamamuraIFSP/rED2")
```

For Intel compilers on Ubuntu or WSL, install oneAPI using Intel's apt
repository:

```sh
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
sudo apt update
sudo apt install intel-oneapi-compiler-dpcpp-cpp intel-oneapi-compiler-fortran git cmake ninja-build pkg-config build-essential
```

Then import oneAPI's environment inside R before installing:

```r
oneapi_env <- system2(
  "bash",
  c("-lc", shQuote("source /opt/intel/oneapi/setvars.sh >/dev/null && env")),
  stdout = TRUE
)
stopifnot(length(oneapi_env) > 0)
oneapi_env <- strsplit(oneapi_env, "=", fixed = TRUE)
oneapi_env <- oneapi_env[lengths(oneapi_env) >= 2]
do.call(Sys.setenv, stats::setNames(
  lapply(oneapi_env, \(x) paste(x[-1], collapse = "=")),
  vapply(oneapi_env, `[[`, character(1), 1)
))

Sys.setenv(CC = "icx", CXX = "icpx", FC = "ifx", F77 = "ifx")
pak::pak("caiohamamuraIFSP/rED2")
```

Use the same oneAPI environment block before `rED2::edInit()` in a fresh Linux
session.

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
