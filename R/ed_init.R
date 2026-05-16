#' @export
edInit <- function() {
  bin <- system.file("bin", package = "rED2")
  exe <- if (.Platform$OS.type == "windows") "edmain.exe" else "edmain"
  system2(file.path(bin, exe))
}
