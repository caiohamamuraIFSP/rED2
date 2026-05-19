# AGENTS.md

> Session context and checkpoint: see [MEMORY.md](MEMORY.md).

## What this is
An R package that vendors ED2 v2.2.0 (Fortran ecosystem model) and installs the
`edmain` binary inside the package. The R side is thin: one exported function
(`edInit`) that shells out to the compiled Fortran executable.

## Build system (Autoconf → make)

- **configure.ac** is the source of truth for the build. After editing it, run
  `make preprocess` (which runs `autoreconf` and copies `configure` to
  `configure.ucrt`). The copy step is required — `configure.ucrt` is the
  Windows build script that `R CMD INSTALL` picks up on Windows.

- **Do not hand-edit `configure`.** It is generated from `configure.ac`.

- **Do not hand-edit `src/ed2.mk`.** It is generated from `src/ed2.mk.in` by
  the configure script (autoconf `@VAR@` substitutions).

- `R CMD INSTALL` runs the configure script, which discovers compilers, locates
  or builds HDF5, emits `src/ed2.mk`, and compiles everything under `src/ED2/`.

## Commands

| Task | Command |
|------|---------|
| Regenerate configure scripts | `make preprocess` |
| Clean build artifacts | `./cleanup` |
| Local matrix testing (all toolchains) | `sh tools/check_matrix.sh` |
| Matrix subset | `RED2_MATRIX_LANES="gfortran-serial intel-serial" sh tools/check_matrix.sh` |
| Interactive local build | `Rscript tools/build_package.R` |
| Build + check (not just install) | `Rscript tools/build_package.R --check` |
| Smoke-test installed binary pkg | `Rscript tools/smoke_test_binary_package.R` |
| Install from source | `R CMD INSTALL .` |

## Key environment variables

- `RED2_ENABLE_MPI=yes` — build with MPI support
- `RED2_WINDOWS_TOOLCHAIN=intel` — use Intel ifx/icx + MSVC on Windows
- `RED2_HDF5_ROOT=/path/to/hdf5-prefix` — use existing HDF5 instead of building
- `CC`, `FC`, `CXX`, `F77` — override compiler selection

## Architecture notes

- **Source layout:** R functions in `R/`, vendored ED2 in `src/ED2/`,
  build tooling in `tools/`, and autoconf files at the repo root.
- **NAMESPACE** is roxygen2-generated (`RoxygenNote: 7.3.1`); use `roxygen2::roxygenise()` to regenerate.
- **`ByteCompile: false`** is set in DESCRIPTION to avoid `R CMD INSTALL` byte-compiling the package (the R code is minimal).
- The package has **no `tests/` directory** and no `testthat` dependency.
  QA is done via `sh tools/check_matrix.sh` (install + verify `edInit` reaches
  the ED2 runtime) and CI smoke tests.
- `src/sources.mk` and `src/dependency.mk` list all vendored ED2 source files
  and their Fortran module dependencies. These may need updating if ED2 sources
  change.

## Windows quirks

- Intel Windows builds use `lib.exe` instead of Unix `ar` to create the static
  library. The toolchain is discovered by probing for Visual Studio, Intel
  oneAPI, and Windows SDK paths.
- MSVC `LIB` and `INCLUDE` environment variables are set by the configure script
  when using Intel on Windows.

## CI

- GitHub Actions use r-hub (`rhub.yaml`). The matrix runs across Linux
  containers and macOS/Windows (via `r-hub/actions`) with serial and MPI
  variants for each platform/toolchain combo.
- CI smoke-tests the installed binary package with
  `tools/smoke_test_binary_package.R` after each install.
- Tagged releases (`v*`) trigger binary package upload to GitHub Releases.
