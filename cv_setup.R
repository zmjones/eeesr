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

CleanCV <- function(cv, labels) {
  cv <- lapply(cv, function(x) lapply(x, function(y) do.call(rbind, y)))
  cv <- lapply(cv, function(x) as.data.frame(do.call(rbind, x)))
  cv <- lapply(cv, function(x) {
    x$spec <- labels
    x <- ddply(x, .(spec), function(y) quantile(unlist(y[, -ncol(y)]), probs = c(.025, .5, .975)))
    return(x)
  })
  return(cv)
}

specs <- c("~ gdppc + pop", specs)
specs.cwar <- c("~ gdppc + pop + cwar", specs.cwar)
