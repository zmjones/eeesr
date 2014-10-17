set.seed(1987)
library(party)
library(foreach)
library(iterators)
library(doParallel)
library(parallel)
registerDoParallel(makeCluster(CORES))

CHECK <- FALSE ## check stability over tuning parameters for appendix

b_combine <- function(...) {
    x <- do.call("rbind", list(...))
    x <- as.data.frame(t(apply(x, 2, function(z) quantile(z, c(.025, .5, .975)))))
    x$spec <- ivar.labels
    row.names(x) <- NULL
    colnames(x) <- c("lwr", "median", "upr", "spec")
    x[c(4,1:3)]
}

imp <- foreach(y = c(lrm.vars, ols.vars[-2]), .packages = "party") %do% {
    form <- as.formula(paste0(y, "~", paste0(ivars, collapse = "+")))
    foreach(icount(B_ITER), .inorder = FALSE, .multicombine = TRUE,
            .combine = "b_combine", .packages = "party") %dopar% {
        df <- df[sample(row.names(df), nrow(df), TRUE), ]
        varimp(cforest(form, df, control = cforest_unbiased(mtry = 10, ntree = 1000)))
    }
}
save(imp, file = "imp.RData")

check <- function(y, mtry = c(3, 5, 10, 15), ntree = c(500, 1000, 3000)) {
    formula <- as.formula(paste0(y, "~", paste0(ivars, collapse = "+")))
    tune <- expand.grid("mtry" = mtry, "ntree" = ntree)

    rc_combine <- function(...) {
        x <- do.call("rbind", list(...))
        t(x)
    }
    
    rc <- foreach(i = 1:nrow(tune), .inorder = FALSE, .multicombine = TRUE, .combine = "rc_combine") %dopar% {
        fit <- cforest(formula, df, control = cforest_unbiased(mtry = tune[i, 1], ntree = tune[i, 2]))
        rank(varimp(fit))
    }
}

if (check) {
    library(irr)
    library(xtable)
    ck <- lapply(c(lrm.vars, ols.vars[-2]), function(y) check(y))
    kck <- lapply(ck, function(x) kendall(x, TRUE)$value)
    ka <- lapply(ck, function(x) kripp.alpha(t(x), "ordinal")$value)
    as <- data.frame("w" = unlist(kck), "alpha" = unlist(ka))
    row.names(as) <- c(lrm.labs, ols.labs[-2])
    xtable(as)
}    

