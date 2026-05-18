#!/usr/bin/env Rscript

truthy <- function(x) tolower(x %||% "") %in% c("1", "true", "yes", "y", "on")
`%||%` <- function(x, y) if (length(x) && !is.na(x) && nzchar(x)) x else y

args <- commandArgs(trailingOnly = TRUE)
all_args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", all_args, value = TRUE)
script_path <- if (length(script_arg)) {
  sub("^--file=", "", script_arg[[length(script_arg)]])
} else {
  sys.frame(1)$ofile %||% "tools/build_package.R"
}
running_under_rscript <- length(script_arg) > 0L
can_prompt <- interactive() || isatty(stdin())

opts <- list(
  toolchain = "auto",
  mpi = FALSE,
  check = FALSE,
  hdf5_root = Sys.getenv("RED2_HDF5_ROOT"),
  yes = FALSE,
  install_intel = "ask",
  build_hdf5 = "ask"
)

read_opt <- function(prefix) {
  hit <- grep(paste0("^", prefix, "="), args, value = TRUE)
  if (length(hit)) sub(paste0("^", prefix, "="), "", hit[[length(hit)]]) else NULL
}

if ("--help" %in% args || "-h" %in% args) {
  cat(
    "Usage: Rscript tools/build_package.R [options]\n\n",
    "Options:\n",
    "  --toolchain=auto|intel|gfortran   Prefer Intel when available by default.\n",
    "  --mpi                             Build ED2 with MPI support.\n",
    "  --check                           Run R CMD check --as-cran --no-manual.\n",
    "  --hdf5-root=PATH                  Existing HDF5 prefix to use.\n",
    "  --install-intel=yes|no|ask        What to do when Intel compilers are missing.\n",
    "  --build-hdf5=yes|no|ask           Build Intel-compatible HDF5 when missing.\n",
    "  --yes                             Accept build/install prompts.\n",
    sep = ""
  )
  quit(status = 0)
}

opts$toolchain <- read_opt("--toolchain") %||% opts$toolchain
opts$hdf5_root <- read_opt("--hdf5-root") %||% opts$hdf5_root
opts$install_intel <- read_opt("--install-intel") %||% opts$install_intel
opts$build_hdf5 <- read_opt("--build-hdf5") %||% opts$build_hdf5
opts$mpi <- "--mpi" %in% args
opts$check <- "--check" %in% args
opts$yes <- "--yes" %in% args

valid_or_stop <- function(value, choices, name) {
  if (!value %in% choices) {
    stop(sprintf("%s must be one of: %s", name, paste(choices, collapse = ", ")), call. = FALSE)
  }
}

valid_or_stop(opts$toolchain, c("auto", "intel", "gfortran"), "--toolchain")
valid_or_stop(opts$install_intel, c("yes", "no", "ask"), "--install-intel")
valid_or_stop(opts$build_hdf5, c("yes", "no", "ask"), "--build-hdf5")

repo <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
setwd(repo)

is_windows <- .Platform$OS.type == "windows"
is_macos <- Sys.info()[["sysname"]] == "Darwin"

say <- function(...) cat(sprintf(...), "\n", sep = "")

ask_yes_no <- function(question, default = FALSE) {
  if (opts$yes) return(default)
  if (!can_prompt) {
    stop("This action needs confirmation. Re-run interactively or pass --yes.", call. = FALSE)
  }
  suffix <- if (default) " [Y/n] " else " [y/N] "
  cat(paste0(question, suffix))
  answer <- readLines(stdin(), n = 1L, warn = FALSE)
  if (!nzchar(answer)) return(default)
  tolower(substr(answer, 1, 1)) == "y"
}

ask_choice <- function(question, choices, default = 1L) {
  if (opts$yes) return(default)
  if (!can_prompt) {
    say("%s", question)
    for (i in seq_along(choices)) say("  %d. %s", i, choices[[i]])
    stop("This choice needs input. Re-run interactively or pass --yes.", call. = FALSE)
  }
  say("%s", question)
  for (i in seq_along(choices)) say("  %d. %s", i, choices[[i]])
  cat(sprintf("Choose [%d]: ", default))
  answer <- suppressWarnings(as.integer(readLines(stdin(), n = 1L, warn = FALSE)))
  if (is.na(answer) || answer < 1L || answer > length(choices)) default else answer
}

command_line <- function(command, args = character()) {
  paste(c(shQuote(command), shQuote(args)), collapse = " ")
}

run <- function(command, args = character(), env = character(), ask = FALSE) {
  line <- command_line(command, args)
  if (length(env)) line <- paste(paste(env, collapse = " "), line)
  say("$ %s", line)
  if (ask && !ask_yes_no("Run this command?", default = TRUE)) {
    stop("Aborted by user.", call. = FALSE)
  }
  status <- system2(command, args, env = env)
  if (!identical(status, 0L)) stop(sprintf("Command failed: %s", line), call. = FALSE)
}

first_existing <- function(paths) {
  paths <- paths[nzchar(paths)]
  hit <- paths[file.exists(paths)]
  if (length(hit)) normalizePath(hit[[1]], winslash = "/", mustWork = TRUE) else ""
}

which1 <- function(program) {
  hit <- Sys.which(program)
  if (nzchar(hit)) normalizePath(hit, winslash = "/", mustWork = FALSE) else ""
}

prepend_path <- function(paths) {
  paths <- paths[nzchar(paths) & dir.exists(paths)]
  if (!length(paths)) return(invisible())
  Sys.setenv(PATH = paste(c(paths, Sys.getenv("PATH")), collapse = .Platform$path.sep))
}

prepend_env_paths <- function(name, paths) {
  paths <- unique(normalizePath(paths[nzchar(paths) & dir.exists(paths)],
    winslash = "/", mustWork = TRUE))
  if (!length(paths)) return(invisible())
  old <- Sys.getenv(name)
  value <- if (nzchar(old)) paste(c(paths, old), collapse = .Platform$path.sep) else
    paste(paths, collapse = .Platform$path.sep)
  do.call(Sys.setenv, stats::setNames(list(value), name))
}

intel_bins <- function() {
  known <- character()
  if (is_windows) {
    roots <- c(
      "C:/Program Files (x86)/Intel/oneAPI/compiler",
      "C:/Program Files/Intel/oneAPI/compiler"
    )
    known <- unlist(lapply(roots, function(root) {
      Sys.glob(file.path(root, "*", "bin"))
    }), use.names = FALSE)
  } else {
    known <- Sys.glob("/opt/intel/oneapi/compiler/*/bin")
  }
  known <- rev(sort(unique(known)))
  prepend_path(known)
  known
}

find_intel <- function() {
  intel_bins()
  list(ifx = which1("ifx"), icx = which1("icx"), icpx = which1("icpx"))
}

print_intel_env_help <- function() {
  say("")
  say("To use an existing Intel installation, start R with these available:")
  say("  PATH: directory containing ifx, icx, and icpx")
  say("  CC=icx")
  say("  CXX=icpx")
  say("  FC=ifx")
  say("  F77=ifx")
  say("  RED2_HDF5_ROOT=/path/to/HDF5-built-with-ifx")
  if (is_windows) {
    say("  RED2_WINDOWS_TOOLCHAIN=intel")
    say("  RED2_VS_BIN=C:/path/to/VC/Tools/MSVC/<version>/bin/Hostx64/x64")
    say("  LIB and INCLUDE from Intel oneAPI, MSVC, and the Windows SDK")
  } else {
    say("  LD_LIBRARY_PATH should include RED2_HDF5_ROOT/lib when HDF5 is not in a system path")
  }
  say("")
}

package_manager <- function() {
  if (is_windows && nzchar(which1("winget"))) return("winget")
  if (!is_windows && nzchar(which1("apt-get"))) return("apt")
  if (!is_windows && nzchar(which1("dnf"))) return("dnf")
  if (!is_windows && nzchar(which1("pacman"))) return("pacman")
  if (is_macos && nzchar(which1("brew"))) return("brew")
  ""
}

install_intel <- function() {
  pm <- package_manager()
  if (!nzchar(pm)) {
    say("No supported package manager was detected.")
    print_intel_env_help()
    return(FALSE)
  }
  say("Intel oneAPI compilers will be installed with %s.", pm)
  say("Some commands may request administrator or sudo credentials.")

  switch(pm,
    winget = {
      run("winget", c("install", "--id", "Intel.oneAPI.BaseToolkit", "-e"), ask = TRUE)
      run("winget", c("install", "--id", "Intel.oneAPI.HPCToolkit", "-e"), ask = TRUE)
    },
    apt = {
      run("sudo", c("apt-get", "update"), ask = TRUE)
      run("sudo", c("apt-get", "install", "-y", "wget", "gnupg", "ca-certificates"), ask = TRUE)
      run("bash", c("-lc", paste(
        "wget -qO- https://apt.repos.intel.com/oneapi/gpgkey",
        "| sudo gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg"
      )), ask = TRUE)
      run("bash", c("-lc", paste(
        "echo 'deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg]'",
        "https://apt.repos.intel.com/oneapi all main",
        "| sudo tee /etc/apt/sources.list.d/oneAPI.list"
      )), ask = TRUE)
      run("sudo", c("apt-get", "update"), ask = TRUE)
      run("sudo", c("apt-get", "install", "-y",
        "intel-oneapi-compiler-fortran", "intel-oneapi-compiler-dpcpp-cpp"), ask = TRUE)
    },
    dnf = {
      run("sudo", c("dnf", "config-manager", "--add-repo",
        "https://yum.repos.intel.com/oneapi"), ask = TRUE)
      run("sudo", c("dnf", "install", "-y",
        "intel-oneapi-compiler-fortran", "intel-oneapi-compiler-dpcpp-cpp"), ask = TRUE)
    },
    pacman = {
      say("pacman does not provide the official Intel oneAPI compiler packages.")
      say("Install from Intel or use an AUR helper, then set the environment below.")
      print_intel_env_help()
      return(FALSE)
    },
    brew = {
      say("Homebrew does not provide Intel oneAPI Fortran in a portable formula.")
      say("Install oneAPI from Intel, then set the environment below.")
      print_intel_env_help()
      return(FALSE)
    }
  )
  intel <- find_intel()
  nzchar(intel$ifx) && nzchar(intel$icx)
}

choose_toolchain <- function() {
  if (opts$toolchain == "gfortran") return("gfortran")
  intel <- find_intel()
  if (nzchar(intel$ifx) && nzchar(intel$icx)) return("intel")
  if (opts$toolchain == "intel" && opts$install_intel == "no") {
    print_intel_env_help()
    stop("Intel compilers were requested but not found.", call. = FALSE)
  }

  say("Intel compilers were not found.")
  say("Using Intel-built ED2 is highly recommended for this package, especially for Windows.")

  if (opts$install_intel == "yes") {
    if (install_intel()) return("intel")
  } else if (opts$install_intel == "ask") {
    choice <- ask_choice(
      "How do you want to continue?",
      c(
        "Install Intel oneAPI compilers now",
        "Continue with gfortran",
        "Abort and show the required Intel environment variables"
      ),
      default = if (opts$toolchain == "intel") 1L else 2L
    )
    if (choice == 1L && install_intel()) return("intel")
    if (choice == 2L) return("gfortran")
  }

  print_intel_env_help()
  stop("Intel compilers are not configured.", call. = FALSE)
}

find_vs_bin <- function() {
  env <- Sys.getenv("RED2_VS_BIN")
  if (dir.exists(env)) return(normalizePath(env, winslash = "/", mustWork = TRUE))
  candidates <- Sys.glob(file.path(
    "C:/Program Files (x86)/Microsoft Visual Studio/2022",
    "*", "VC/Tools/MSVC/*/bin/Hostx64/x64"
  ))
  first_existing(rev(sort(candidates)))
}

windows_sdk_paths <- function() {
  root <- "C:/Program Files (x86)/Windows Kits/10"
  versions <- Sys.glob(file.path(root, "Include", "*"))
  versions <- versions[dir.exists(file.path(versions, "um"))]
  if (!length(versions)) return(list(include = character(), lib = character()))
  version <- rev(sort(versions))[[1]]
  sdk_version <- basename(version)
  list(
    include = file.path(root, "Include", sdk_version, c("ucrt", "shared", "um", "winrt")),
    lib = file.path(root, "Lib", sdk_version, c("ucrt/x64", "um/x64"))
  )
}

configure_windows_link_env <- function(intel, vs_bin) {
  icx_bin <- dirname(intel$icx)
  compiler_root <- normalizePath(file.path(icx_bin, ".."), winslash = "/", mustWork = TRUE)
  intel_include <- file.path(compiler_root, c("include", "opt/compiler/include"))
  intel_lib <- file.path(compiler_root, c("lib", "opt/compiler/lib"))

  include_paths <- intel_include
  lib_paths <- intel_lib

  if (nzchar(vs_bin)) {
    msvc_root <- normalizePath(file.path(vs_bin, "../../.."), winslash = "/", mustWork = TRUE)
    include_paths <- c(include_paths, file.path(msvc_root, "include"))
    lib_paths <- c(lib_paths, file.path(msvc_root, "lib/x64"))
  }

  sdk <- windows_sdk_paths()
  include_paths <- c(include_paths, sdk$include)
  lib_paths <- c(lib_paths, sdk$lib)

  prepend_env_paths("INCLUDE", include_paths)
  prepend_env_paths("LIB", lib_paths)
}

find_intel_mpi_root <- function() {
  env <- Sys.getenv("I_MPI_ROOT")
  if (dir.exists(env)) return(normalizePath(env, winslash = "/", mustWork = TRUE))
  roots <- c(
    "C:/Program Files (x86)/Intel/oneAPI/mpi",
    "C:/Program Files/Intel/oneAPI/mpi"
  )
  candidates <- unlist(lapply(roots, function(root) Sys.glob(file.path(root, "*"))), use.names = FALSE)
  candidates <- candidates[dir.exists(file.path(candidates, "include", "mpi"))]
  if (length(candidates)) normalizePath(rev(sort(candidates))[[1]], winslash = "/", mustWork = TRUE) else ""
}

configure_windows_intel_mpi_env <- function() {
  mpi_root <- find_intel_mpi_root()
  if (!nzchar(mpi_root)) return(invisible())
  Sys.setenv(I_MPI_ROOT = mpi_root)
  prepend_path(file.path(mpi_root, "bin"))
  prepend_env_paths("INCLUDE", file.path(mpi_root, "include", "mpi"))
  prepend_env_paths("LIB", file.path(mpi_root, "lib"))
}

configure_intel_env <- function() {
  intel <- find_intel()
  if (!nzchar(intel$ifx) || !nzchar(intel$icx)) {
    stop("Intel compiler detection failed after setup.", call. = FALSE)
  }
  Sys.setenv(CC = "icx", CXX = "icpx", FC = "ifx", F77 = "ifx")
  if (!is_windows) {
    setvars <- "/opt/intel/oneapi/setvars.sh"
    if (file.exists(setvars)) {
      say("Detected %s. Source it before R if your shell still misses Intel libraries.", setvars)
    }
    compiler_roots <- Sys.glob("/opt/intel/oneapi/compiler/*")
    compiler_roots <- compiler_roots[dir.exists(file.path(compiler_roots, "lib"))]
    if (length(compiler_roots)) {
      compiler_root <- normalizePath(rev(sort(compiler_roots))[[1]], winslash = "/", mustWork = TRUE)
      prepend_path(file.path(compiler_root, "bin"))
      Sys.setenv(LD_LIBRARY_PATH = paste(file.path(compiler_root, "lib"), Sys.getenv("LD_LIBRARY_PATH"),
        sep = .Platform$path.sep))
    }
    mpi_roots <- Sys.glob("/opt/intel/oneapi/mpi/*")
    mpi_roots <- mpi_roots[dir.exists(file.path(mpi_roots, "bin"))]
    if (length(mpi_roots)) {
      mpi_root <- normalizePath(rev(sort(mpi_roots))[[1]], winslash = "/", mustWork = TRUE)
      Sys.setenv(I_MPI_ROOT = Sys.getenv("I_MPI_ROOT") %||% mpi_root)
      prepend_path(file.path(mpi_root, "bin"))
      Sys.setenv(LD_LIBRARY_PATH = paste(file.path(mpi_root, "lib"), Sys.getenv("LD_LIBRARY_PATH"),
        sep = .Platform$path.sep))
    }
    return(invisible())
  }

  Sys.setenv(RED2_WINDOWS_TOOLCHAIN = "intel")
  vs_bin <- find_vs_bin()
  if (!nzchar(vs_bin)) {
    say("Visual Studio Build Tools were not detected. Intel on Windows needs MSVC link.exe/lib.exe.")
    if (ask_yes_no("Install Visual Studio Build Tools with winget?", default = TRUE)) {
      run("winget", c("install", "--id", "Microsoft.VisualStudio.2022.BuildTools", "-e",
        "--override", "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools"), ask = TRUE)
      vs_bin <- find_vs_bin()
    }
  }
  if (nzchar(vs_bin)) {
    Sys.setenv(RED2_VS_BIN = vs_bin)
    prepend_path(vs_bin)
  } else {
    say("Set RED2_VS_BIN before building with Intel on Windows.")
  }
  configure_windows_link_env(intel, vs_bin)
  configure_windows_intel_mpi_env()
}

default_hdf5_prefix <- function(toolchain) {
  if (toolchain == "intel") {
    vcpkg <- Sys.getenv("VCPKG_ROOT")
    if (!is_windows && startsWith(vcpkg, "/mnt/")) vcpkg <- ""
    if (!nzchar(vcpkg) && is_windows) {
      vcpkg <- first_existing(c(file.path(Sys.getenv("USERPROFILE"), "src", "vcpkg"), "C:/vcpkg"))
    }
    if (nzchar(vcpkg)) {
      triplet <- if (is_windows) "x64-windows-ifx" else "x64-linux-ifx"
      return(file.path(vcpkg, "installed", triplet))
    }
  }
  ""
}

hdf5_exists <- function(prefix, toolchain) {
  if (!nzchar(prefix)) return(FALSE)
  inc <- file.path(prefix, "include", "hdf5.mod")
  libdir <- file.path(prefix, "lib")
  if (is_windows && toolchain == "intel") {
    return(file.exists(inc) && file.exists(file.path(libdir, "hdf5_fortran.lib")))
  }
  file.exists(inc) && (file.exists(file.path(libdir, "libhdf5_fortran.so")) ||
    file.exists(file.path(libdir, "libhdf5_fortran.a")) ||
    file.exists(file.path(libdir, "libhdf5_fortran.dylib")))
}

ensure_vcpkg <- function() {
  vcpkg <- Sys.getenv("VCPKG_ROOT")
  exe <- if (is_windows) "vcpkg.exe" else "vcpkg"
  if (!is_windows && startsWith(vcpkg, "/mnt/")) vcpkg <- ""
  if (nzchar(vcpkg) && file.exists(file.path(vcpkg, exe))) return(normalizePath(vcpkg, winslash = "/"))
  hit <- which1("vcpkg")
  if (!is_windows && startsWith(hit, "/mnt/")) hit <- ""
  if (nzchar(hit)) return(normalizePath(dirname(hit), winslash = "/"))
  root <- if (is_windows) {
    file.path(Sys.getenv("USERPROFILE"), "src", "vcpkg")
  } else {
    file.path(Sys.getenv("XDG_CACHE_HOME") %||% file.path(path.expand("~"), ".cache"), "rED2", "vcpkg")
  }
  say("vcpkg was not detected.")
  if (!ask_yes_no(sprintf("Clone and bootstrap vcpkg at %s?", root), default = TRUE)) {
    stop("vcpkg is required to build Intel-compatible HDF5.", call. = FALSE)
  }
  dir.create(dirname(root), recursive = TRUE, showWarnings = FALSE)
  run("git", c("clone", "https://github.com/microsoft/vcpkg", root), ask = TRUE)
  bootstrap <- file.path(root, if (is_windows) "bootstrap-vcpkg.bat" else "bootstrap-vcpkg.sh")
  run(bootstrap, if (is_windows) character() else "-disableMetrics", ask = TRUE)
  Sys.setenv(VCPKG_ROOT = root)
  normalizePath(root, winslash = "/")
}

build_hdf5_vcpkg_intel <- function() {
  vcpkg <- ensure_vcpkg()
  triplet <- if (is_windows) "x64-windows-ifx" else "x64-linux-ifx"
  vcpkg_exe <- file.path(vcpkg, if (is_windows) "vcpkg.exe" else "vcpkg")
  run(vcpkg_exe, c("install", paste0("hdf5[fortran]:", triplet),
    paste0("--overlay-triplets=", normalizePath("tools/vcpkg-triplets", winslash = "/"))), ask = TRUE)
  file.path(vcpkg, "installed", triplet)
}

ensure_hdf5 <- function(toolchain) {
  prefix <- opts$hdf5_root %||% default_hdf5_prefix(toolchain)
  if (hdf5_exists(prefix, toolchain)) {
    Sys.setenv(RED2_HDF5_ROOT = normalizePath(prefix, winslash = "/", mustWork = TRUE))
    return(invisible(prefix))
  }
  if (toolchain != "intel") return(invisible(prefix))

  say("Intel-compatible HDF5 was not found%s.",
    if (nzchar(prefix)) sprintf(" at %s", prefix) else "")
  build <- switch(opts$build_hdf5,
    yes = TRUE,
    no = FALSE,
    ask = ask_yes_no("Build HDF5 with the Intel compilers now?", default = TRUE),
    FALSE
  )
  if (!build) {
    say("RED2_HDF5_ROOT is not set; package configure will try to build HDF5 with vcpkg.")
    return(invisible(prefix))
  }
  prefix <- build_hdf5_vcpkg_intel()
  if (!hdf5_exists(prefix, toolchain)) {
    stop(sprintf("HDF5 build finished, but Fortran HDF5 was not found in %s.", prefix), call. = FALSE)
  }
  Sys.setenv(RED2_HDF5_ROOT = normalizePath(prefix, winslash = "/", mustWork = TRUE))
  if (!is_windows) {
    Sys.setenv(PKG_CONFIG_PATH = paste(file.path(prefix, "lib", "pkgconfig"), Sys.getenv("PKG_CONFIG_PATH"),
      sep = .Platform$path.sep))
    Sys.setenv(LD_LIBRARY_PATH = paste(file.path(prefix, "lib"), Sys.getenv("LD_LIBRARY_PATH"),
      sep = .Platform$path.sep))
  }
}

configure_gfortran_env <- function() {
  if (opts$mpi && !is_windows && nzchar(which1("mpifort"))) Sys.setenv(FC = "mpifort", F77 = "mpifort")
  if (opts$mpi) Sys.setenv(RED2_ENABLE_MPI = "yes") else Sys.unsetenv("RED2_ENABLE_MPI")
}

maybe_regenerate_configure <- function() {
  if (!file.exists("configure.ac")) return(invisible())
  needs <- !file.exists("configure") ||
    file.info("configure.ac")$mtime > file.info("configure")$mtime
  if (!needs) return(invisible())
  say("configure.ac is newer than configure; regenerating configure scripts.")
  if (is_windows) {
    bash <- first_existing(c("C:/rtools45/usr/bin/bash.exe", "C:/rtools44/usr/bin/bash.exe", which1("bash")))
    if (!nzchar(bash)) stop("Rtools bash is required to regenerate configure on Windows.", call. = FALSE)
    run(bash, c("--login", "-lc", sprintf("cd %s && autoconf && cp configure configure.ucrt",
      shQuote(gsub("\\\\", "/", repo)))), ask = FALSE)
  } else {
    run("autoconf", ask = FALSE)
    file.copy("configure", "configure.ucrt", overwrite = TRUE)
  }
}

clean_build_outputs <- function() {
  unlink(Sys.glob("rED2_*.tar.gz"))
  unlink(Sys.glob("*.Rcheck"), recursive = TRUE)
}

build_package <- function() {
  maybe_regenerate_configure()
  clean_build_outputs()
  r <- file.path(R.home("bin"), "R")
  run(r, c("CMD", "build", "."))
  tarball <- tail(Sys.glob("rED2_*.tar.gz"), 1L)
  if (!length(tarball) || !file.exists(tarball)) stop("R CMD build did not produce a tarball.", call. = FALSE)
  if (opts$check) {
    run(r, c("CMD", "check", "--as-cran", "--no-manual", tarball))
  } else {
    run(r, c("CMD", "INSTALL", tarball))
  }
}

main <- function() {
  toolchain <- choose_toolchain()
  say("Selected toolchain: %s", toolchain)
  if (toolchain == "intel") {
    configure_intel_env()
    ensure_hdf5(toolchain)
    if (opts$mpi) Sys.setenv(RED2_ENABLE_MPI = "yes") else Sys.unsetenv("RED2_ENABLE_MPI")
  } else {
    configure_gfortran_env()
  }
  build_package()
}

tryCatch(main(), error = function(e) {
  say("Error: %s", conditionMessage(e))
  if (running_under_rscript) quit(status = 1)
  stop(e)
})
