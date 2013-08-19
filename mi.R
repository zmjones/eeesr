invisible(require(mice))

mi <- mice(df.imp, m = MI_ITER, print = FALSE)
df.mi <- lapply(seq(1, MI_ITER), function(x) complete(mi, x))
