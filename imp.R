set.seed(1987)
require(multicore)
require(party)

imp <- lapply(c(lrm.vars, ols.vars[-2]), function(y) {
  mclapply(seq(1, B_ITER), function(b) {
    formula <- as.formula(paste0(y, "~", paste0(ivars, collapse = "+")))
    df <- df[sample(row.names(df), size = nrow(df), replace = TRUE), ]
    varimp(cforest(formula, data = df, control = cforest_unbiased(mtry = 10, ntree = 1000)))
  }, mc.cores = CORES)
})

imp <- lapply(imp, function(x) do.call(rbind, x))
imp <- lapply(imp, function(x) apply(x, 2, function(x) quantile(x, probs = c(.025, .5, .975))))
imp <- lapply(imp, function(x) {
  x <- as.data.frame(t(x))
  x$spec <- ivar.labels
  row.names(x) <- NULL
  colnames(x) <- c("lwr", "median", "upr", "spec")
  return(x[c(4,1:3)])
})
