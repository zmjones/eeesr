invisible(lapply(c("rms", "multicore"), require, character.only = TRUE))
options(showprogress = FALSE)

cv.lrm <- lapply(lrm.vars, function(x)
                 lapply(seq(1, MI_ITER), function(z)
                 CallCV(df.mi[[z]], specs, df.mi[[z]][, x],
                 "lrm", c("log GDP per cap. + log Pop.", ivar.labels))))
cv.lrm.cwar <- lapply(lrm.vars, function(x)
                      lapply(seq(1, MI_ITER), function(z)
                      CallCV(df.mi[[z]], specs.cwar, df.mi[[z]][, x], "lrm",
                      c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))))
