set.seed(1987)
require(multicore)
require(party)
require(irr)
require(xtable)

FormatImp <- function(imp) {
  imp <- lapply(imp, function(x) do.call(rbind, x))
  imp <- lapply(imp, function(x) apply(x, 2, function(x) quantile(x, probs = c(.025, .5, .975))))
  imp <- lapply(imp, function(x) {
    x <- as.data.frame(t(x))
    x$spec <- ivar.labels
    row.names(x) <- NULL
    colnames(x) <- c("lwr", "median", "upr", "spec")
    return(x[c(4,1:3)])
  })
  return(imp)
}

imp <- lapply(c(lrm.vars, ols.vars[-2]), function(y) {
  mclapply(seq(1, B_ITER), function(b) {
    formula <- as.formula(paste0(y, "~", paste0(ivars, collapse = "+")))
    df <- df[sample(row.names(df), size = nrow(df), replace = TRUE), ]
    varimp(cforest(formula, data = df, control = cforest_unbiased(mtry = 10, ntree = 1000)))
  }, mc.cores = CORES)
})

imp <- FormatImp(imp)

check <- function(y, mtry = c(3, 5, 10, 15), ntree = c(500, 1000, 3000)) {
    formula <- as.formula(paste0(y, "~", paste0(ivars, collapse = "+")))
    tune <- expand.grid("mtry" = mtry, "ntree" = ntree)
    rc <- mclapply(1:nrow(tune), function(i) {
        fit <- cforest(formula, df, control = cforest_unbiased(mtry = tune[i, 1], ntree = tune[i, 2]))
        rank(varimp(fit))
    }, mc.cores = CORES)
    t(do.call("rbind", rc))
}

ck <- lapply(c(lrm.vars, ols.vars[-2]), function(y) check(y))
kck <- lapply(ck, function(x) kendall(x, TRUE)$value)
ka <- lapply(ck, function(x) kripp.alpha(t(x), "ordinal")$value)
as <- data.frame("w" = unlist(kck), "alpha" = unlist(ka))
row.names(as) <- c(lrm.labs, ols.labs[-2])
xtable(as)
