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
