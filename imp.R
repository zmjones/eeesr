invisible(lapply(c("party", "multicore"), require, character.only = TRUE))

imp <- lapply(c(lrm.vars, "physint"), function(x)
              mclapply(seq(1, MI_ITER), function(z) {
                formula <- as.formula(paste0(x, "~", paste0(ivars, collapse = "+")))
                varimp(cforest(formula, data = df.mi[[z]]))
              }, mc.cores = CORES))

imp <- lapply(imp, function(x) as.data.frame(do.call(rbind, x)))
imp <- lapply(imp, function(x) apply(x, 2, function(x) c(mean(x), sd(x))))
