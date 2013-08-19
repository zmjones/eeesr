invisible(lapply(c("rms", "multicore", "plyr"), require, character.only = TRUE))
options(showprogress = FALSE)

CVrms <- function(response, input, B, R, model) {
  cv <- vector("numeric", R)
  if (model == "lrm") {
    fit <- lrm(response ~ input, x = TRUE, y = TRUE)
    for(r in 1:R)
      cv[r] <- validate(fit, B, method = "cross")[1, 5]
  } else if (model == "ols") {
    fit <- ols(response ~ input, x = TRUE, y = TRUE)
    for(r in 1:R)
      cv[r] <- sqrt(validate(fit, B, method = "cross")[2, 3])
  } else stop("Invalid model type.")
  return(cv)
}

CleanCV <- function(cv) {
  cv <- as.data.frame(t(apply(cv, 1, function(x)
                      quantile(x, probs = c(.025, .5, .975)))))
  colnames(cv) <- c("lwr", "median", "upr")
  cv$spec <- row.names(cv)
  row.names(cv) <- NULL
  return(cv)
}

CallCV <- function(data, specs, depvar, mtype, rnames) {
  cv <- CleanCV(t(as.data.frame(mclapply(specs, function(x)
                CVrms(depvar, model.matrix(as.formula(x), data)[, -1],
                CV_FOLD, CV_ITER, model = mtype), mc.cores = CORES))))
  cv$spec <- rnames
  return(cv)
}

specs <- c("~ gdppc + pop", specs)
specs.cwar <- c("~ gdppc + pop + cwar", specs.cwar)
cv.lrm <- lapply(lrm.vars, function(x)
                 lapply(seq(1, MI_ITER), function(z)
                 CallCV(df.mi[[z]], specs, df.mi[[z]][, x],
                 "lrm", c("log GDP per cap. + log Pop.", ivar.labels))))
cv.lrm.cwar <- lapply(lrm.vars, function(x)
                      lapply(seq(1, MI_ITER), function(z)
                      CallCV(df.mi[[z]], specs.cwar, df.mi[[z]][, x], "lrm",
                      c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))))
cv.ols <- lapply(ols.vars, function(x)
                 lapply(seq(1, MI_ITER), function(z)
                 CallCV(df.mi[[z]], specs, as.integer(df.mi[[z]][, x]), "ols",
                 c("log GDP per cap. + log Pop.", ivar.labels))))
cv.ols.cwar <- lapply(ols.vars, function(x)
                      lapply(seq(1, MI_ITER), function(z)
                      CallCV(df.mi[[z]], specs.cwar, as.integer(df.mi[[z]][, x]), "ols",
                      c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))))
cv <- c(cv.lrm, cv.lrm.cwar, cv.ols, cv.ols.cwar)
cv <- lapply(cv, function(x) do.call(rbind, x))
cv <- lapply(cv, function(x) ddply(x[, -4], .(x$spec), colMeans))
cv <- lapply(cv, function(x) {colnames(x)[1] <- "spec"; return(x)})
