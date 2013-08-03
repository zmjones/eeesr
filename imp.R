invisible(lapply(c("party", "multicore"), require, character.only = TRUE))

imp <- mclapply(c(lrm.vars, "physint"), function(x)
                varimp(cforest(as.formula(paste0(x, "~", paste0(ivars, collapse = "+"))),
                data = df.imp)), mc.cores = CORES)
