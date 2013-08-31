CVrms <- function(response, input, B, R, model) {
  # response: dependent variable (vector)
  # input: input matrix (matrix or dataframe)
  # B: the number of cross validation folds (integer)
  # R: the number of times to repeat cross validation (integer)
  # model: string vector (length 1), either "lrm" or "ols"
  # returns: matrix of length R and width B with cross-validation results
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
  # cv: list of lists of cv results (from function CallCV)
  # returns: quantiles of discrepancy statistic for each model specification in a data frame
  cv <- lapply(cv, function(x) lapply(x, function(y) do.call(rbind, y)))
  cv <- lapply(cv, function(x) as.data.frame(do.call(rbind, x)))
  cv <- lapply(cv, function(x) {
    x$spec <- labels
    x <- ddply(x, .(spec), function(y) quantile(unlist(y[, -ncol(y)]), probs = c(.025, .5, .975)))
    colnames(x) <- c("spec", "lwr", "median", "upr")
    return(x)
  })
  return(cv)
}

CallCV <- function(vars, specs, model) {
  # vars: a string vector of dependent variables
  # specs: a string vector of model specifications
  # model: string vector (length 1), either "lrm" or "ols"
  # returns: list of lists with cv results
  cv <- lapply(vars, function(y)
               lapply(seq(1, MI_ITER), function(z)
                      mclapply(specs, function(x)
                               CVrms(df.mi[[z]][, y],
                                     model.matrix(as.formula(x), df.mi[[z]])[, -1],
                                     CV_FOLD, CV_ITER, model), mc.cores = CORES)))
  return(cv)
}

specs <- c("~ gdppc + pop", specs)
specs.cwar <- c("~ gdppc + pop + cwar", specs.cwar)
