#!/bin/sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LOG_DIR="${RED2_MATRIX_LOG_DIR:-$ROOT/build/matrix-logs}"
R_SCRIPT="${RED2_RSCRIPT:-}"

find_rscript() {
  if [ -n "$R_SCRIPT" ]; then
    printf '%s\n' "$R_SCRIPT"
    return 0
  fi

  if command -v Rscript >/dev/null 2>&1; then
    command -v Rscript
    return 0
  fi

  if [ -n "${R_HOME:-}" ] && [ -x "$R_HOME/bin/Rscript" ]; then
    printf '%s\n' "$R_HOME/bin/Rscript"
    return 0
  fi

  for candidate in \
    /c/Program\ Files/R/R-*/bin/Rscript.exe \
    /c/Program\ Files/R/R-*/bin/x64/Rscript.exe
  do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

run_lane() {
  lane=$1
  toolchain=${lane%%-*}
  mode=${lane#*-}
  log="$LOG_DIR/$lane.log"

  case "$toolchain" in
    gfortran|intel) ;;
    *)
      printf 'Unknown toolchain in lane: %s\n' "$lane" >&2
      return 1
      ;;
  esac

  case "$mode" in
    serial|mpi) ;;
    *)
      printf 'Unknown mode in lane: %s\n' "$lane" >&2
      return 1
      ;;
  esac

  printf '\n==> %s\n' "$lane"
  printf 'Log: %s\n' "$log"

  if RED2_MATRIX_ROOT="$ROOT" \
    RED2_MATRIX_LANE="$lane" \
    RED2_MATRIX_TOOLCHAIN="$toolchain" \
    RED2_MATRIX_MPI="$mode" \
    "$R_SCRIPT" --vanilla - >"$log" 2>&1 <<'RSCRIPT'
repo <- normalizePath(Sys.getenv("RED2_MATRIX_ROOT"), winslash = "/", mustWork = TRUE)
lane <- Sys.getenv("RED2_MATRIX_LANE")
toolchain <- Sys.getenv("RED2_MATRIX_TOOLCHAIN")
mpi_mode <- Sys.getenv("RED2_MATRIX_MPI")

setwd(repo)
options(repos = c(CRAN = "https://cloud.r-project.org"))

say <- function(...) cat(sprintf(...), "\n", sep = "")
path_prepend <- function(paths) {
  paths <- paths[nzchar(paths) & dir.exists(paths)]
  if (length(paths)) {
    Sys.setenv(PATH = paste(c(paths, Sys.getenv("PATH")), collapse = .Platform$path.sep))
  }
}

import_oneapi_linux_env <- function() {
  if (.Platform$OS.type == "windows") return(invisible(FALSE))
  if (!file.exists("/opt/intel/oneapi/setvars.sh")) return(invisible(FALSE))

  oneapi_env <- system2(
    "bash",
    c("-lc", shQuote("source /opt/intel/oneapi/setvars.sh >/dev/null && env")),
    stdout = TRUE
  )
  if (!length(oneapi_env)) return(invisible(FALSE))

  oneapi_env <- strsplit(oneapi_env, "=", fixed = TRUE)
  oneapi_env <- oneapi_env[lengths(oneapi_env) >= 2]
  values <- lapply(oneapi_env, function(x) paste(x[-1], collapse = "="))
  names(values) <- vapply(oneapi_env, `[[`, character(1), 1)
  do.call(Sys.setenv, values)
  invisible(TRUE)
}

configure_readme_lane <- function(toolchain, mpi_mode) {
  Sys.unsetenv(c(
    "RED2_ENABLE_MPI", "RED2_WINDOWS_TOOLCHAIN",
    "CC", "CXX", "FC", "F77"
  ))

  if (mpi_mode == "mpi") {
    Sys.setenv(RED2_ENABLE_MPI = "yes")
  }

  if (toolchain == "intel") {
    if (.Platform$OS.type == "windows") {
      path_prepend(c(
        "C:/Program Files (x86)/Intel/oneAPI/compiler/latest/bin",
        Sys.glob("C:/Program Files (x86)/Intel/oneAPI/compiler/*/bin"),
        "C:/Program Files/Intel/oneAPI/compiler/latest/bin",
        Sys.glob("C:/Program Files/Intel/oneAPI/compiler/*/bin")
      ))
      Sys.setenv(RED2_WINDOWS_TOOLCHAIN = "intel")
    } else {
      import_oneapi_linux_env()
      Sys.setenv(CC = "icx", CXX = "icpx", FC = "ifx", F77 = "ifx")
    }
  }
}

verify_install <- function(lib) {
  exe_name <- if (.Platform$OS.type == "windows") "edmain.exe" else "edmain"
  exe <- system.file("bin", exe_name, package = "rED2", lib.loc = lib)
  say("EXE=%s", exe)
  stopifnot(nzchar(exe), file.exists(exe))

  if (nzchar(Sys.which("nm"))) {
    nm <- system2("nm", exe, stdout = TRUE, stderr = TRUE)
    say("NM_GFORTRAN=%d", length(grep("gfortran", nm, ignore.case = TRUE)))
    say("NM_INTEL=%d", length(grep("intel|ifcore|ifport", nm, ignore.case = TRUE)))
  }

  run <- system2(exe, stdout = TRUE, stderr = TRUE)
  say("EDMAIN_HAS_ED2IN=%s", any(grepl("ED2IN", run)))
  say("EDMAIN_HAS_MISSING_INTEL_DLL=%s", any(grepl("libifcoremd|libifportmd", run, ignore.case = TRUE)))
  if (any(grepl("libifcoremd|libifportmd", run, ignore.case = TRUE))) {
    stop("edmain failed before ED2 runtime because an Intel runtime DLL was missing", call. = FALSE)
  }

  .libPaths(c(lib, .libPaths()))
  init <- tryCatch(
    utils::capture.output(rED2::edInit(), type = "output"),
    error = function(e) conditionMessage(e)
  )
  text <- paste(init, collapse = "\n")
  say("EDINIT_REACHED_ED_RUNTIME=%s", grepl("ED2IN|fatal_error", text, ignore.case = TRUE))
  say("EDINIT_HAS_MISSING_INTEL_DLL=%s", grepl("libifcoremd|libifportmd", text, ignore.case = TRUE))
  if (grepl("libifcoremd|libifportmd", text, ignore.case = TRUE)) {
    stop("edInit failed before ED2 runtime because an Intel runtime DLL was missing", call. = FALSE)
  }
}

say("LANE=%s", lane)
say("TOOLCHAIN=%s", toolchain)
say("MPI=%s", mpi_mode)

configure_readme_lane(toolchain, mpi_mode)

if (toolchain == "intel") {
  say("ICX=%s", Sys.which("icx"))
  say("IFX=%s", Sys.which("ifx"))
}

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

lib <- file.path(tempdir(), paste0("red2-matrix-", lane))
unlink(lib, recursive = TRUE, force = TRUE)
dir.create(lib, recursive = TRUE, showWarnings = FALSE)

if (tolower(Sys.getenv("RED2_MATRIX_CLEAR_CACHE", "true")) %in% c("1", "true", "yes", "y", "on")) {
  pak::cache_delete()
}

pak::pak("local::.", lib = lib, ask = FALSE, upgrade = FALSE)
verify_install(lib)
RSCRIPT
  then
    printf 'PASS %s\n' "$lane"
    return 0
  fi

  printf 'FAIL %s\n' "$lane"
  tail -n 80 "$log" || true
  return 1
}

usage() {
  cat <<'EOF'
Usage: sh tools/check_matrix.sh

Installs the package with pak::pak("local::.") in the same style documented in
README.md, then runs edmain and rED2::edInit() far enough to verify the ED2
runtime is reached.

Default lanes:
  gfortran-serial
  gfortran-mpi
  intel-serial
  intel-mpi

Environment:
  RED2_RSCRIPT             Rscript executable to use.
  RED2_MATRIX_LOG_DIR      Directory for per-lane logs.
  RED2_MATRIX_LANES        Space-separated lane list to run.
  RED2_MATRIX_CLEAR_CACHE  Delete pak cache before each lane. Default: true.

Example:
  RED2_MATRIX_LANES="gfortran-serial intel-serial" sh tools/check_matrix.sh
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

R_SCRIPT=$(find_rscript) || {
  printf 'Rscript was not found. Set RED2_RSCRIPT=/path/to/Rscript.\n' >&2
  exit 1
}

mkdir -p "$LOG_DIR"
cd "$ROOT"

lanes="${RED2_MATRIX_LANES:-gfortran-serial gfortran-mpi intel-serial intel-mpi}"
failed=0

printf 'Using Rscript: %s\n' "$R_SCRIPT"
printf 'Logs: %s\n' "$LOG_DIR"

for lane in $lanes; do
  run_lane "$lane" || failed=1
done

if [ "$failed" -eq 0 ]; then
  printf '\nAll matrix lanes passed.\n'
else
  printf '\nOne or more matrix lanes failed. See %s.\n' "$LOG_DIR" >&2
fi

exit "$failed"
