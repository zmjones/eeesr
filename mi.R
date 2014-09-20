require(mice)

methods <- c(rep("", 3), rep("ri", 5), rep("", 5), "", "", rep("ri", 3),
             "rf", rep("ri", 3), rep("rf", 7), "", "", rep("rf", 3), "ri", "",
             "rf", "rf", "ri", "ri", rep("rf", 7), "", "", rep("ri", 4), rep("", 7))

mi <- mice(df, m = MI_ITER, method = methods, print = FALSE)
df.mi <- lapply(seq(1, MI_ITER), function(x) complete(mi, x))
