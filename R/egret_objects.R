#' Create named list for EGRET analysis
#'
#' Create a named list with the INFO, Daily, and Sample dataframes, and surface matrix. If any of these are
#' not available, an NA should be 
#'
#' @param INFO dataframe containing the INFO dataframe
#' @param Daily dataframe containing the daily data
#' @param Sample dataframe containing the sample data
#' @param surfaces matrix returned from \code{modelEstimation}. Default is NA. 
#' @keywords data import USGS WRTDS
#' @export
#' @return eList named list with Daily, Sample, and INFO dataframes, along with the surfaces matrix.
#' Any of these values can be NA, not all EGRET functions will work with missing parts of the named list eList.
#' @seealso \code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
#' @examples
#' eList <- Choptank_eList
#' Daily <- getDaily(eList)
#' INFO <- getInfo(eList)
#' eList_flowHistory <- as.egret(INFO, Daily)
#' plotFlowSingle(eList_flowHistory, 1)
#' Sample <- getSample(eList)
#' surfaces <- getSurfaces(eList)
#' eList_full <- as.egret(INFO, Daily, Sample, surfaces)
#' plotFluxQ(eList_full)
as.egret <- function(INFO, Daily, Sample=NA, surfaces=NA) {
  eList <- list(INFO=INFO, 
                Daily=Daily, 
                Sample=Sample, 
                surfaces=surfaces)
  
  if(!is.na(Daily) && !("Q" %in% names(Daily))){
    message("Please double check that the Daily dataframe is correctly defined.")
  }
  
  if(!is.na(Sample) && !all((c("ConcLow","ConcHigh","Uncen","ConcAve") %in% names(Sample)))){
    message("Please double check that the Sample dataframe is correctly defined.")
  }
  
  if(!any(c("param.units", "shortName", "paramShortName", "constitAbbrev", "drainSqKm") %in% names(INFO))){
    message("Please double check that the INFO dataframe is correctly defined.")
  }
  
  if(!is.na(surfaces) && 14 != nrow(surfaces)){
    message("Please double check that the surfaces matrix is correctly defined.")
  }
  
  attr(eList, "param.units") <- INFO$param.units
  attr(eList, "shortName") <- INFO$shortName
  attr(eList, "paramShortName") <- INFO$paramShortName
  attr(eList, "constitAbbrev") <- INFO$constitAbbrev
  attr(eList, "drainSqKm") <- INFO$drainSqKm    
  
  class(eList) <- "egret"
  invisible(eList)
}



#' Check for EGRET object
#'
#' Checks object to see if it is an EGRET object
#'
#' @param x object to check
#' @keywords data import USGS WRTDS
#' @export
#' @return logical
#' @examples
#' eList <- Choptank_eList
#' is.egret(eList)
is.egret <- function(x) {
  inherits(x, "egret")
}

#' EGRET helper functinos
#' 
#' A small collection of helper functions
#' 
#' @keywords data import USGS WRTDS
#' @export
#' @param x EGRET object
#' @param \dots additional parameters
#' @rdname helperEGRET
#' 
#' @examples
#' Choptank_eList
#' print(Arkansas_eList)
print.egret <- function(x,...){
  
  localDaily <- getDaily(x)
  localSample <- getSample(x)
  localINFO <- getInfo(x)
  
  if(!all(is.na(x$Daily))){
    cat("Daily discharge:\n")
    print(localDaily[1,c("Date","Q")])
    cat("...\n")
    print(localDaily[nrow(localDaily),c("Date","Q")])
  }
  if(!all(is.na(x$Sample))){
    columnsToPrint <- which(names(localSample) %in% c("Date","ConcLow","ConcHigh","Q"))
    
    cat("\nSample data:\n")
    print(localSample[1,columnsToPrint])
    cat("...\n")
    print(localSample[nrow(localSample),columnsToPrint])
  }
  cat("\n",attr(x, "shortName"), ":",attr(x, "paramShortName"),"\n",sep="")
  cat("Parameter units:", attr(x, "param.units"),"\n")
  cat("Drainage area:", attr(x, "drainSqKm"), "km^2\n")      
  
}

#' @method plot egret
#' @export
#' @rdname helperEGRET
#' @seealso \code{\link{multiPlotDataOverview}}
#' 
#' @examples
#' plot(Choptank_eList)
#' plot(Choptank_eList, cex.main=0.7)
plot.egret <- function(x, ...){
  multiPlotDataOverview(x, ...)
}

#' @export
#' @rdname helperEGRET
#' 
#' @examples 
#' nDischarge(Arkansas_eList)
nDischarge <- function(x){
  stopifnot(is.egret(x))
  Daily <- getDaily(x)
  
  if(is.null(Daily)){
    message("No Daily data found; returning NULL.")
    nobs <- NULL
  } else {
    nobs <- nrow(Daily)
  }
  
  return(nobs)
}

#' @export
#' @rdname helperEGRET
#' 
#' @examples 
#' nObservations(Arkansas_eList)
nObservations <- function(x){
  stopifnot(is.egret(x))
  Sample <- getSample(x)
  
  if(is.null(Sample)){
    message("No Sample data found; returning NULL.")
    nobs <- NULL
  } else {
    nobs <- nrow(Sample)
  }
  
  return(nobs)
}

#' @export
#' @rdname helperEGRET
#' 
#' @examples 
#' nCensoredVals(Arkansas_eList)
nCensoredVals <- function(x){
  stopifnot(is.egret(x))
  Sample <- getSample(x)
  
  if(is.null(Sample)){
    message("No Sample data found; returning NULL.")
    ncensored <- NULL
  } else {
    # 0 in Uncen col represents censored value
    ncensored <- length(which(Sample[['Uncen']] == 0))
  }
  
  return(ncensored)
}

#' Get Daily dataframe from EGRET object
#'
#' From a named list or EGRET object, extract the Daily dataframe
#'
#' @param x EGRET object or named list
#' @param \dots additional parameters
#' @keywords data import USGS WRTDS
#' @export
#' @return Daily dataframe
#' @rdname getDaily
#' @seealso \code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
#' @examples
#' eList <- Choptank_eList
#' Daily <- getDaily(eList)
getDaily <- function(x, ...){
  UseMethod("getDaily")
}

#' @rdname getDaily
#' @export
getDaily.egret <- function(x, ...){
  Daily <- x$Daily
  return(Daily)
}

#' @rdname getDaily
#' @export
getDaily.default <- function(x, ...){
  if("Daily" %in% names(x)){
    return(x$Daily)
  } else {
    stop("Please provide a named list that includes a Daily dataframe")
  }
}

#' Get INFO dataframe from EGRET object
#'
#' From a named list or EGRET object, extract the INFO dataframe
#'
#' @param x EGRET object or named list
#' @param \dots additional parameters
#' @keywords data import USGS WRTDS
#' @export
#' @return INFO dataframe
#' @rdname getInfo
#' @seealso \code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
#' @examples
#' eList <- Choptank_eList
#' INFO <- getInfo(eList)
getInfo <- function(x, ...){
  UseMethod("getInfo")
}

#' @rdname getInfo
#' @export
getInfo.egret <- function(x, ...){
  INFO <- x$INFO
  return(INFO)
}

#' @rdname getInfo
#' @export
getInfo.default <- function(x, ...){
  if("INFO" %in% names(x)){
    return(x$INFO)
  } else {
    stop("Please provide a named list that includes a INFO dataframe")
  }
}

#' Get Sample dataframe from EGRET object
#'
#' From a named list or EGRET object, extract the Sample dataframe
#'
#' @param x EGRET object or named list
#' @param \dots additional parameters
#' @keywords data import USGS WRTDS
#' @export
#' @return Sample dataframe
#' @rdname getSample
#' @seealso \code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
#' @examples
#' eList <- Choptank_eList
#' Sample <- getSample(eList)
getSample <- function(x, ...){
  UseMethod("getSample")
}

#' @rdname getSample
#' @export
getSample <- function(x, ...){
  Sample <- x$Sample
  return(Sample)
}

#' @rdname getSample
#' @export
getSample.default <- function(x, ...){
  if("Sample" %in% names(x)){
    return(x$Sample)
  } else {
    stop("Please provide a named list that includes a Sample dataframe")
  }
}

#' Get surfaces matrix from EGRET object
#'
#' From a named list or EGRET object, extract the surfaces matrix
#'
#' @param x EGRET object or named list
#' @param \dots additional parameters
#' @keywords data import USGS WRTDS
#' @export
#' @return Sample dataframe
#' @rdname getSurfaces
#' @seealso \code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
#' @examples
#' eList <- Choptank_eList
#' surfaces <- getSurfaces(eList)
getSurfaces <- function(x, ...){
  UseMethod("getSurfaces")
}

#' @rdname getSurfaces
#' @export
getSurfaces.egret <- function(x, ...){
  surfaces <- x$surfaces
  return(surfaces)
}

#' @rdname getSurfaces
#' @export
getSurfaces.default <- function(x, ...){
  if("surfaces" %in% names(x)){
    return(x$surfaces)
  } else {
    stop("Please provide a named list that includes a surfaces matrix")
  }
}
