#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args)) args[[1]] else "check"
pkg <- read.dcf("DESCRIPTION", "Package")[[1]]
version <- read.dcf("DESCRIPTION", "Version")[[1]]

archives <- list.files(
  root,
  pattern = sprintf("^%s_.*[.](zip|tgz|tar[.]gz)$", pkg),
  full.names = TRUE,
  recursive = TRUE
)

source_archive <- sprintf("%s_%s.tar.gz", pkg, version)
archives <- archives[basename(archives) != source_archive]

if (!length(archives)) {
  stop("No binary package archive found under ", root, call. = FALSE)
}

archives <- archives[order(file.info(archives)$mtime, decreasing = TRUE)]
archive <- normalizePath(archives[[1]], winslash = "/", mustWork = TRUE)
cat("Binary package:", archive, "\n")

tmp <- tempfile("red2-binary-smoke-")
dir.create(tmp)

if (grepl("[.]zip$", archive, ignore.case = TRUE)) {
  utils::unzip(archive, exdir = tmp)
} else {
  utils::untar(archive, exdir = tmp)
}

exe_name <- if (.Platform$OS.type == "windows") "edmain.exe" else "edmain"
exe <- list.files(tmp, pattern = paste0("^", exe_name, "$"), recursive = TRUE, full.names = TRUE)
exe <- exe[grepl(sprintf("(^|/|\\\\)bin(/|\\\\)%s$", exe_name), exe)]

if (!length(exe)) {
  stop("The binary package does not contain bin/", exe_name, call. = FALSE)
}

exe <- normalizePath(exe[[1]], winslash = "/", mustWork = TRUE)
if (.Platform$OS.type != "windows") Sys.chmod(exe, "755")

cat("ED2 binary:", exe, "\n")
out <- suppressWarnings(system2(exe, stdout = TRUE, stderr = TRUE))
text <- paste(out, collapse = "\n")
cat(text, sep = "\n")

if (!grepl("ED2IN", text, fixed = TRUE)) {
  stop("edmain did not reach the expected ED2 runtime error for missing ED2IN.", call. = FALSE)
}

if (grepl("libifcoremd|libifportmd|cannot open shared object|DLL|not found", text, ignore.case = TRUE)) {
  stop("edmain failed before ED2 runtime because a runtime library was missing.", call. = FALSE)
}
