\name{edInit}
\alias{edInit}
\title{Run the ED2 executable bundled with rED2}
\usage{
edInit()
}
\description{
Runs the ED2 main executable installed in the package's \file{bin}
directory.
}
\value{
The exit status returned by \code{\link[base:system2]{system2}}.
}
\examples{
exe <- if (.Platform$OS.type == "windows") "edmain.exe" else "edmain"
file.exists(system.file("bin", exe, package = "rED2"))
}
