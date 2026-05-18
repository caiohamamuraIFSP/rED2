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
  toolchain=$1
  mpi=$2
  label="$toolchain"
  args="--toolchain=$toolchain --check --yes --install-intel=no --build-hdf5=no"

  if [ "$mpi" = yes ]; then
    label="${label}-mpi"
    args="$args --mpi"
    mpi_env=yes
  else
    label="${label}-serial"
    mpi_env=no
  fi

  log="$LOG_DIR/$label.log"
  printf '\n==> %s\n' "$label"
  printf 'Log: %s\n' "$log"

  # shellcheck disable=SC2086
  if RED2_ENABLE_MPI="$mpi_env" "$R_SCRIPT" "$ROOT/tools/build_package.R" $args >"$log" 2>&1; then
    if [ -d "$ROOT/rED2.Rcheck" ]; then
      rm -rf "$LOG_DIR/$label.Rcheck"
      cp -R "$ROOT/rED2.Rcheck" "$LOG_DIR/$label.Rcheck"
    fi
    printf 'PASS %s\n' "$label"
    return 0
  fi

  if [ -d "$ROOT/rED2.Rcheck" ]; then
    rm -rf "$LOG_DIR/$label.Rcheck"
    cp -R "$ROOT/rED2.Rcheck" "$LOG_DIR/$label.Rcheck"
  fi

  printf 'FAIL %s\n' "$label"
  tail -n 80 "$log" || true
  return 1
}

usage() {
  cat <<'EOF'
Usage: sh tools/check_matrix.sh

Runs local R CMD check lanes:
  gfortran-serial
  gfortran-mpi
  intel-serial
  intel-mpi

Environment:
  RED2_RSCRIPT          Rscript executable to use.
  RED2_MATRIX_LOG_DIR   Directory for per-lane logs.
  RED2_MATRIX_LANES     Space-separated lane list to run.

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
  case "$lane" in
    gfortran-serial) run_lane gfortran no || failed=1 ;;
    gfortran-mpi) run_lane gfortran yes || failed=1 ;;
    intel-serial) run_lane intel no || failed=1 ;;
    intel-mpi) run_lane intel yes || failed=1 ;;
    *)
      printf 'Unknown lane: %s\n' "$lane" >&2
      failed=1
      ;;
  esac
done

if [ "$failed" -eq 0 ]; then
  printf '\nAll matrix lanes passed.\n'
else
  printf '\nOne or more matrix lanes failed. See %s.\n' "$LOG_DIR" >&2
fi

exit "$failed"
