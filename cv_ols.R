invisible(lapply(c("rms", "multicore"), require, character.only = TRUE))
options(showprogress = FALSE)

cv.ols <- lapply(ols.vars, function(x)
                 lapply(seq(1, MI_ITER), function(z)
                 CallCV(df.mi[[z]], specs, as.integer(df.mi[[z]][, x]), "ols",
                 c("log GDP per cap. + log Pop.", ivar.labels))))
cv.ols.cwar <- lapply(ols.vars, function(x)
                      lapply(seq(1, MI_ITER), function(z)
                      CallCV(df.mi[[z]], specs.cwar, as.integer(df.mi[[z]][, x]), "ols",
                      c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))))
