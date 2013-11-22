require(mice)

methods <- c(rep("", 3), rep("ri", 5), rep("", 5), "", "", rep("ri", 3),
             "", rep("ri", 3), rep("cart", 7), "", "", "cart",
             "", "", "ri", "cart", rep("", 2), rep("cart", 4), rep("", 7))

mi <- mice(df, m = MI_ITER, method = methods, print = FALSE)
df.mi <- lapply(seq(1, MI_ITER), function(x) complete(mi, x))
