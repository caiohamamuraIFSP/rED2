# rED2

R package for compiling and running the Ecosystem Demography model
([ED2](https://github.com/EDmodel/ED2)).

The package currently builds ED2 `v.2.2.0` during installation and installs the
`edmain` executable under the package `bin` directory.

## Requirements

- R
- C and Fortran compilers
- HDF5 Fortran development files available through `pkg-config`
- Windows: Rtools/UCRT toolchain

## Install

```r
pak::pak("caiohamamura/rED2")
```

During `configure`, rED2 downloads ED2 `v.2.2.0`, applies small portability
patches, builds the model, and bundles the executable.

## Run

```r
rED2::edInit()
```

ED2 expects its usual runtime files, including `ED2IN`, in the working
directory.


