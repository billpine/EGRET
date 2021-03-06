% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formatCheckParameterCd.r
\name{formatCheckParameterCd}
\alias{formatCheckParameterCd}
\title{formatCheckParameterCd}
\usage{
formatCheckParameterCd(parameterCd, interactive = TRUE)
}
\arguments{
\item{parameterCd}{character to check}

\item{interactive}{logical Option for interactive mode.  If true, there is user interaction for error handling and data checks.}
}
\value{
parameterCd character
}
\description{
This function was never incorporated into the EGRET workflow and will be removed in future versions. A similar check exists within the dataRetrieval functions.
Checks that the parameter code is 5 digits. If it is less, it will pad the character with zeros. If more, ask the user to re-enter.
}
\keyword{WRTDS}
\keyword{flow}
