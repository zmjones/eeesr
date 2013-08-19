invisible(require("mice"))

methods <- c(rep("", 3), rep("ri", 5), rep("", 5), "", "", rep("quadratic", 3),
             "", "ri", "quadratic", "quadratic", rep("cart", 7), "", "", "cart",
             "", "", "ri", "cart", "", "", rep("cart", 3))

mi <- mice(df.imp, m = MI_ITER, method = methods, print = FALSE)
df.mi <- lapply(seq(1, MI_ITER), function(x) complete(mi, x))
