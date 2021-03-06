#' Break Detection in the Seasonal and Trend Component of a Univariate Time
#' Series
#' 
#' Iterative break detection in seasonal and trend component of a time series.
#' Seasonal breaks is a function that combines the iterative decomposition of
#' time series into trend, seasonal and remainder components with significant
#' break detection in the decomposed components of the time series.
#' 
#' To be completed.
#' 
#' @param Yt univariate time series to be analyzed. This should be an object of
#' class "ts" with a frequency greater than one without NA's.
#' @param h minimal segment size between potentially detected breaks in the
#' trend model given as fraction relative to the sample size (i.e. the minimal
#' number of observations in each segment divided by the total length of the
#' timeseries.
#' @param season the seasonal model used to fit the seasonal component and
#' detect seasonal breaks (i.e. significant phenological change).  There are
#' three options: "dummy", "harmonic", or "none" where "dummy" is the model
#' proposed in the first Remote Sensing of Environment paper and "harmonic" is
#' the model used in the second Remote Sensing of Environment paper (See paper
#' for more details) and where "none" indicates that no seasonal model will be
#' fitted (i.e. St = 0 ). If there is no seasonal cycle (e.g. frequency of the
#' time series is 1) "none" can be selected to avoid fitting a seasonal model.
#' @param max.iter maximum amount of iterations allowed for estimation of
#' breakpoints in seasonal and trend component.
#' @param breaks integer specifying the maximal number of breaks to be
#' calculated. By default the maximal number allowed by h is used.
#' @param hpc A character specifying the high performance computing support.
#' Default is "none", can be set to "foreach". Install the "foreach" package
#' for hpc support.
#' @param level numeric; threshold value for the \link[strucchange]{sctest.efp}
#' test; if a length 2 vector is passed, the first value is used for the trend,
#' the second for the seasonality
#' @param reg "lm" or "rlm": use regular or robust linear regression
#' @param decomp "stlplus" or "stl": use the NA-tolerant decomposition package
#' or the reference package (which can make use of time series with 2-3
#' observations per year)
#' @param type character, indicating the type argument to
#' \link[strucchange]{efp}
#' @return An object of the class "bfast" is a list with the following
#' elements: \item{Yt}{ equals the Yt used as input.} \item{output}{ is a list
#' with the following elements (for each iteration): \tabular{ll}{ \code{Tt}
#' \tab the fitted trend component\cr \code{St} \tab the fitted seasonal
#' component\cr \code{Nt} \tab the noise or remainder component\cr \code{Vt}
#' \tab equals the deseasonalized data \code{Yt - St} for each iteration\cr
#' \code{bp.Vt} \tab output of the \code{\link[strucchange]{breakpoints}}
#' function for the trend model\cr \code{ci.Vt} \tab output of the
#' \code{\link[strucchange]{breakpoints}} confint function for the trend
#' model\cr \code{Wt} \tab equals the detrended data \code{Yt - Tt} for each
#' iteration\cr \code{bp.Wt} \tab output of the
#' \code{\link[strucchange]{breakpoints}} function for the seasonal model\cr
#' \code{ci.Wt} \tab output of the \code{\link[strucchange]{breakpoints}}
#' confint function for the seasonal model }} \item{nobp}{ is a list with the
#' following elements: \tabular{ll}{ \code{nobp.Vt} \tab logical, TRUE if there
#' are no breakpoints detected\cr \code{nobp.Wt} \tab logical, TRUE if there
#' are no breakpoints detected }} \item{Magnitude}{ magnitude of the biggest
#' change detected in the trend component} \item{Time}{ timing of the biggest
#' change detected in the trend component}
#' @author Jan Verbesselt
#' @seealso \code{\link[bfast]{plot.bfast}} for plotting of bfast() results.
#' \cr \code{\link[strucchange]{breakpoints}} for more examples and background
#' information about estimation of breakpoints in time series.
#' @references Verbesselt J, Hyndman R, Newnham G, Culvenor D (2010).
#' Detecting Trend and Seasonal Changes in Satellite Image Time Series.
#' \emph{Remote Sensing of Environment}, \bold{114}(1), 106--115.
#' \url{http://dx.doi.org/10.1016/j.rse.2009.08.014}
#' 
#' Verbesselt J, Hyndman R, Zeileis A, Culvenor D (2010).  Phenological Change
#' Detection while Accounting for Abrupt and Gradual Trends in Satellite Image
#' Time Series.  \emph{Remote Sensing of Environment}, \bold{114}(12),
#' 2970--2980.  \url{http://dx.doi.org/10.1016/j.rse.2010.08.003}
#' @keywords ts
#' @examples
#' 
#' 
#' \dontrun{
#' rm(list = ls())
#' install.packages("bfast", repos="http://R-Forge.R-project.org", type = "source")
#' update.packages(checkBuilt=TRUE)
#' # make sure all your package are up to date
#' # and built correctly for your current R version
#' }
#' 
#' ## Simulated Data
#' plot(simts) # stl object containing simulated NDVI time series
#' datats <- ts(rowSums(simts$time.series))
#' # sum of all the components (season,abrupt,remainder)
#' tsp(datats) <- tsp(simts$time.series) # assign correct time series attributes
#' plot(datats)
#' 
#' \dontrun{
#' if (requireNamespace("forecast", quietly = TRUE)) {
#'       fit <- bfast(datats,h=0.15, season="dummy", max.iter=1)
#'       plot(fit,sim=simts)
#'       fit
#'       # prints out whether breakpoints are detected
#'       # in the seasonal and trend component
#' 
#'    } else {
#'       ## do something else not involving forecast related functions
#'       ## like seasonaldummy() and tsdisply()
#'    }
#' }
#' 
#' 
#' ## Real data
#' ## The data should be a regular ts() object without NA's
#' ## See Fig. 8 b in reference
#' plot(harvest, ylab="NDVI")
#' # MODIS 16-day cleaned and interpolated NDVI time series
#' 
#' (rdist <- 10/length(harvest))
#' # ratio of distance between breaks (time steps) and length of the time series
#' \dontrun{
#' if (requireNamespace("forecast", quietly = TRUE)) {
#'   fit <- bfast(harvest,h=rdist, season="harmonic", max.iter=1,breaks=2)
#'   plot(fit)
#'   ## plot anova and slope of the trend identified trend segments
#'   #plot(fit, ANOVA=TRUE)
#'   ## plot the trend component and identify the break with
#'   ## the largest magnitude of change
#'   plot(fit,type="trend",largest=TRUE)
#' 
#'   ## plot all the different available plots
#'   plot(fit,type="all")
#' 
#'   ## output
#'   niter <- length(fit$output) # nr of iterations
#'   out <- fit$output[[niter]]
#'   # output of results of the final fitted seasonal and trend models and
#'   ## #nr of breakpoints in both.
#' 
#'   ## running bfast on yearly data
#'   t <- ts(as.numeric(harvest), frequency = 1, start = 2006)
#'   fit <- bfast(t, h = 0.23, season = "none", max.iter = 1)
#'   plot(fit)
#'   fit
#' }
#' }
#' 
#' @export bfast
bfast <- function (Yt, h = 0.15, season = c("dummy", "harmonic", "none"), 
                   max.iter = 10, breaks = NULL, hpc = "none", level = 0.05,
                   reg = c("lm", "rlm"), decomp=c("stlplus", "stl"),
                   type = "OLS-MOSUM", ...) 
{
  # Error catching
  reg = match.arg(reg)
  if(!(reg %in% c("lm","rlm"))) stop("Regression method unknown, use either 'lm' or 'rlm'.")
  if(reg == "rlm") require(MASS)
  decomp = match.arg(decomp)
  if(decomp == "stlplus" && !require("stlplus",quietly = T)) stop("Please install the stlplus package!")
  ## Get Arguments
  season <- match.arg(season)
  level  <- rep(level, length.out = 2)
  ti <- time(Yt)
  f <- frequency(Yt) # on cycle every f time points (seasonal cycle)
  if (class(Yt) != "ts") 
    stop("Not a time series object")
  output <- list()
  Tt <- 0
  if (season == "harmonic") {
    w <- 1/f
    tl <- 1:length(Yt)
    co <- cos(2 * pi * tl * w)
    si <- sin(2 * pi * tl * w)
    co2 <- cos(2 * pi * tl * w * 2)
    si2 <- sin(2 * pi * tl * w * 2)
    co3 <- cos(2 * pi * tl * w * 3)
    si3 <- sin(2 * pi * tl * w * 3)
    smod <- Wt ~ co + si + co2 + si2 + co3 + si3
    # Start the iterative procedure and for first iteration St=decompose result
    if (decomp == "stlplus") {
        St <- stlplus(Yt, t=ti, n.p = f, s.window = "periodic", ...)$data[, "seasonal"]
    } else {
        St <- stl    (Yt, "periodic")$time.series[, "seasonal"]
    }
  }
  else if (season == "dummy") {
    # Start the iterative procedure and for first iteration St=decompose result
    if (decomp == "stlplus") {
        St <-  stlplus(Yt, t=ti, n.p = f, s.window = "periodic", ...)$data[, "seasonal"]
    } else {
        St <- stl(Yt, "periodic")$time.series[, "seasonal"]
    }
    D <- seasonaldummy(Yt)
    D[rowSums(D) == 0, ] <- -1
    smod <- Wt ~ -1 + D
  }
  else if (season == "none") {
    print("No seasonal model will be fitted!")
    St <- 0
  }
  else stop("Not a correct seasonal model is selected ('harmonic' or 'dummy') ")
  Vt.bp <- 0
  Wt.bp <- 0
  CheckTimeTt <- 1
  CheckTimeSt <- 1
  i <- 0
  while ((!identical(CheckTimeTt, Vt.bp) | !identical(CheckTimeSt, Wt.bp)) & i < max.iter) {
    CheckTimeTt <- Vt.bp
    CheckTimeSt <- Wt.bp
    ### Change in trend component
    Vt <- Yt - St # Deasonalized Time series
    p.Vt <- sctest(efp(Vt ~ ti, h = h, type = type))
    if (p.Vt$p.value <= level[1]) {
      bp.Vt   <- breakpoints(Vt ~ ti, h = h, breaks = breaks, na.action=na.exclude,hpc = hpc)
      nobp.Vt <- is.na(breakpoints(bp.Vt)[1])
    } else {
      nobp.Vt <- TRUE
      bp.Vt   <- NA
    }
    if (nobp.Vt) {
      ## No Change detected
      fm0   <- lm(Vt ~ ti)
      Vt.bp <- 0 # no breaks times
      Tt <- ts(data=NA,start = ti[1], end = ti[length(ti)],frequency = f) # Data minus trend
      Tt[which(!is.na(Yt))] <- fitted(fm0) # Overwrite non-missing with fitted values
      tsp(Tt) <- tsp(Yt)
      ci.Vt <- NA
    } else {
      fm1 <- lm(Vt[which(!is.na(Yt))] ~ breakfactor(bp.Vt)/ti[which(!is.na(Yt))] )
      ci.Vt <- confint(bp.Vt, het.err = FALSE)
      Vt.bp <- ci.Vt$confint[, 2]
      # Define empty copy of original time series
      Tt <- ts(data=NA,start = ti[1], end = ti[length(ti)],frequency = f)
      Tt[which(!is.na(Yt))] <- fitted(fm1) # Overwrite non-missing with fitted values
      tsp(Tt) <- tsp(Yt)
    }
    if (season == "none") {
      Wt <- 0
      St <- 0
      bp.Wt <- NA
      ci.Wt <- NA
      nobp.Wt <- TRUE
    } else {
      ### Change in seasonal component
      Wt <- Yt - Tt
      p.Wt <- sctest(efp(smod, h = h, type = type)) # preliminary test 
      if (p.Wt$p.value <= level[2]) {
        bp.Wt <- breakpoints(smod, h = h, breaks = breaks, 
                             hpc = hpc)
        nobp.Wt <- is.na(breakpoints(bp.Wt)[1])
      }
      else {
        nobp.Wt <- TRUE
        bp.Wt <- NA
      }
      if (nobp.Wt) {
        ## No seasonal change detected
        sm0 <- lm(smod)
        St <- ts(data=NA,start = ti[1], end = ti[length(ti)],frequency = f)
        St[which(!is.na(Yt))] <- fitted(sm0) # Overwrite non-missing with fitted values
        tsp(St) <- tsp(Yt)
        Wt.bp <- 0
        ci.Wt <- NA
      } else {
        if (season == "dummy") 
          sm1 <- lm(Wt ~ -1 + D %in% breakfactor(bp.Wt))
        if (season == "harmonic") 
          sm1 <- lm(Wt ~ (co + si + co2 + si2 + co3 + si3) %in% breakfactor(bp.Wt))
        ci.Wt <- confint(bp.Wt, het.err = FALSE)
        Wt.bp <- ci.Wt$confint[, 2]
        
        # Define empty copy of original time series
        St <- ts(data=NA,start = ti[1], end = ti[length(ti)],frequency = f)
        St[which(!is.na(Yt))] <- fitted(sm1) # Overwrite non-missing with fitted values
        tsp(St) <- tsp(Yt)
      }
    }
    i <- i + 1
    output[[i]] <- list(Tt = Tt, St = St, Nt = Yt - Tt - St, Vt = Vt, bp.Vt = bp.Vt, Vt.bp = Vt.bp, ci.Vt = ci.Vt,
                        Wt = Wt, bp.Wt = bp.Wt, Wt.bp = Wt.bp, ci.Wt = ci.Wt)
  }
  if (!nobp.Vt) { # probably only works well for dummy model!
    Vt.nrbp <- length(bp.Vt$breakpoints)
    co  <- coef(fm1) # final fitted trend model
    Mag <- matrix(NA, Vt.nrbp, 3)
    for (r in 1:Vt.nrbp) {
      if (r == 1) {
        y1 <- co[1] + co[r + Vt.nrbp + 1] * ti[Vt.bp[r]]
      } else {
        y1 <- co[1] + co[r] + co[r + Vt.nrbp + 1] * ti[Vt.bp[r]]
      }
      y2 <- (co[1] + co[r + 1]) + co[r + Vt.nrbp + 2] * ti[Vt.bp[r] + 1]

      Mag[r, 1] <- y1
      Mag[r, 2] <- y2
      Mag[r, 3] <- y2 - y1
    }
    index <- which.max(abs(Mag[, 3]))
    m.x <- rep(Vt.bp[index], 2)
    m.y <- c(Mag[index, 1], Mag[index, 2]) #Magnitude position
    Magnitude <- Mag[index, 3] # Magnitude of biggest change
    Time <- Vt.bp[index]
  } else {
    m.x <- NA
    m.y <- NA
    Magnitude <- 0 # if we do not detect a break then the magnitude is zero
    Time <- NA # if we do not detect a break then we have no timing of the break
    Mag <- 0
  }
  return(structure(list(Yt = Yt, output = output, nobp = list(Vt = nobp.Vt, Wt = nobp.Wt), 
                        Magnitude = Magnitude, Mags = Mag, Time = Time, 
                        jump = list(x = ti[m.x], y = m.y)), class = "bfast"))
}
