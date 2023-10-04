#'
#' @useDynLib rED2
#' @export
double <- function(x) {
    n_rows <- as.integer(nrow(x))
    n_cols <- as.integer(ncol(x))
    .Fortran('double', n_rows, n_cols, as.double(x))[[3]]
}

#'
#' @useDynLib rED2
#' @export
edmain <- function() {
    .Fortran('edmain2')
}