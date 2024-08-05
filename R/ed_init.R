#' @export
edInit <- function() {
  bin <- system.file("bin", package = "rED2")
  system2(file.path(bin, "edmain"))
}