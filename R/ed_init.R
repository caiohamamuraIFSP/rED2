#' Initialize and run the ED2 executable.
#' This function initializes and runs the ED2 executable with the specified
#' number of cores and MPI
#'
#' @param cores An integer specifying the number of CPU cores to use. If NULL,
#'   the function will attempt to detect the number of cores available on the
#'   system.
#' @param mpi One of "auto", "yes", or "no". Use "auto" to run with MPI when
#'   the ED2 executable is MPI-linked and an MPI launcher is available. Use
#'   "yes" to require MPI and error if it cannot be used. Use "no" to run
#'   without MPI.
#' @param args A character vector of additional command-line arguments to pass to
#'   the ED2 executable.
#' @param mpiexec An optional character string specifying the path to the MPI
#'   launcher (e.g., "mpiexec" or "mpirun").
#'
#'
#' @export
edInit <- function(cores = NULL,
                   mpi = c("auto", "yes", "no"),
                   args = character(),
                   mpiexec = NULL) {
  mpi <- match.arg(mpi)
  exe <- ed_executable()
  cores <- ed_cores(cores)

  use_mpi <- mpi != "no" && cores > 1L

  if (use_mpi) {
    mpi_linked <- ed_has_mpi(exe)
    launcher <- ed_mpiexec(mpiexec)

    if (mpi_linked && nzchar(launcher)) {
      return(system2(launcher, c("-n", as.character(cores), exe, args)))
    }

    if (mpi == "yes") {
      stop(
        "MPI was requested, but the ED2 executable is not MPI-linked ",
        "or no MPI launcher was found.",
        call. = FALSE
      )
    }
  }

  system2(exe, args)
}

ed_executable <- function() {
  bin <- system.file("bin", package = "rED2")
  exe <- if (.Platform$OS.type == "windows") "edmain.exe" else "edmain"
  path <- file.path(bin, exe)

  if (!file.exists(path)) {
    stop("ED2 executable was not found in the installed package.", call. = FALSE)
  }

  path
}

ed_cores <- function(cores = NULL) {
  if (!is.null(cores)) {
    cores <- suppressWarnings(as.integer(cores[[1L]]))
    if (is.na(cores) || cores < 1L) {
      stop("`cores` must be a positive integer.", call. = FALSE)
    }

    return(cores)
  }

  env_names <- c("RED2_CORES", "SLURM_NTASKS", "PBS_NP", "NSLOTS")
  env <- Sys.getenv(env_names, unset = NA_character_)
  env <- suppressWarnings(as.integer(env[!is.na(env) & nzchar(env)]))
  env <- env[!is.na(env) & env > 0L]

  if (length(env)) {
    return(max(1L, env[[1L]]))
  }

  cores <- parallel::detectCores(logical = FALSE)
  if (is.na(cores)) {
    cores <- 1L
  }

  max(1L, as.integer(cores))
}

ed_mpiexec <- function(mpiexec = NULL) {
  candidates <- character()

  if (!is.null(mpiexec)) {
    candidates <- c(candidates, mpiexec)
  }

  candidates <- c(
    candidates,
    Sys.getenv(c("RED2_MPIEXEC", "MPIEXEC"), unset = ""),
    unname(Sys.which(c("mpiexec", "mpirun")))
  )

  if (.Platform$OS.type == "windows") {
    candidates <- c(
      candidates,
      "C:/Program Files/Microsoft MPI/Bin/mpiexec.exe",
      file.path(Sys.getenv("MSMPI_BIN", unset = ""), "mpiexec.exe")
    )
  }

  candidates <- unique(candidates[nzchar(candidates)])
  candidates <- candidates[file.exists(candidates)]

  if (length(candidates)) {
    return(normalizePath(candidates[[1L]], winslash = "/", mustWork = FALSE))
  }

  ""
}

ed_has_mpi <- function(exe) {
  if (.Platform$OS.type == "windows") {
    return(ed_binary_contains(exe, c("msmpi.dll", "impi.dll")))
  }

  ldd <- Sys.which("ldd")
  if (nzchar(ldd)) {
    libs <- suppressWarnings(system2(ldd, exe, stdout = TRUE, stderr = TRUE))
    if (any(grepl("libmpi|libmpich|libhdf5_.*mpi", libs, ignore.case = TRUE))) {
      return(TRUE)
    }
  }

  otool <- Sys.which("otool")
  if (nzchar(otool)) {
    libs <- suppressWarnings(system2(otool, c("-L", exe), stdout = TRUE, stderr = TRUE))
    if (any(grepl("libmpi|libmpich|libhdf5_.*mpi", libs, ignore.case = TRUE))) {
      return(TRUE)
    }
  }

  ed_binary_contains(exe, c("libmpi", "libmpich", "msmpi.dll", "impi.dll"))
}

ed_binary_contains <- function(path, patterns) {
  info <- file.info(path)
  if (is.na(info$size) || info$size <= 0) {
    return(FALSE)
  }

  con <- file(path, "rb")
  on.exit(close(con), add = TRUE)

  bytes <- readBin(con, "raw", n = info$size)
  any(vapply(patterns, ed_raw_contains, logical(1L), bytes = bytes))
}

ed_raw_contains <- function(pattern, bytes) {
  needle <- charToRaw(pattern)
  n <- length(needle)

  if (length(bytes) < n) {
    return(FALSE)
  }

  starts <- which(bytes == needle[[1L]])
  starts <- starts[starts + n - 1L <= length(bytes)]

  any(vapply(starts, function(i) {
    identical(bytes[i:(i + n - 1L)], needle)
  }, logical(1L)))
}
