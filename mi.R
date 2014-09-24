set.seed(1987)

library(mice)
library(foreach)
library(iterators)
library(doParallel)
library(parallel)
registerDoParallel(makeCluster(detectCores()))

SAVE <- TRUE

## check total na
## apply(df, 2, function(x) sum(is.na(x)))
mi_methods <- sapply(colnames(df), function(x) {
    if (any(is.na(df[, x])) & !any(x %in% c(lrm.vars, ols.vars, paste0(c(lrm.vars, ols.vars), "_lag")))) {
        if ((is.integer(df[, x]) & length(unique(df[, x])) > 10) | is.numeric(df[, x]))
            "ri"

        else
            "rf"
    }
    else ""
})

df.mi <- foreach(icount(MI_ITER), .packages = "mice") %dopar% complete(mice(df, 1, mi_methods, print = FALSE))
save(df.mi, file = "mi.RData")
