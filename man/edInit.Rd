\name{edInit}
\alias{edInit}
\title{Run the ED2 executable bundled with rED2}
\usage{
edInit(cores = NULL, mpi = c("auto", "yes", "no"), args = character(),
  mpiexec = NULL)
}
\arguments{
\item{cores}{Number of MPI ranks to use. If \code{NULL}, rED2 checks
\env{RED2_CORES}, common scheduler variables, then physical CPU cores.}

\item{mpi}{Use \code{"auto"} to run with MPI when the executable and launcher
are available, \code{"yes"} to require MPI, or \code{"no"} to run directly.}

\item{args}{Command-line arguments passed to ED2.}

\item{mpiexec}{Optional path to \command{mpiexec} or \command{mpirun}.}
}
\description{
Runs the ED2 main executable installed in the package's \file{bin} directory.
When the executable is MPI-linked and an MPI launcher is found, rED2 can run it
with multiple ranks.
}
\value{
The exit status returned by \code{\link[base:system2]{system2}}.
}
\examples{
exe <- if (.Platform$OS.type == "windows") "edmain.exe" else "edmain"
file.exists(system.file("bin", exe, package = "rED2"))

\dontrun{
rED2::edInit(cores = 2)
rED2::edInit(cores = 2, mpi = "yes")
}
}
