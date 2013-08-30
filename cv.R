invisible(lapply(c("rms", "multicore", "plyr"), require, character.only = TRUE))
options(showprogress = FALSE)

cv.lrm <- lapply(lrm.vars, function(y)
                 lapply(seq(1, MI_ITER), function(z)
                        mclapply(specs, function(x)
                                 CVrms(df.mi[[z]][, y],
                                       model.matrix(as.formula(x), df.mi[[z]])[, -1],
                                       CV_FOLD, CV_ITER, "lrm"), mc.cores = CORES)))
cv.lrm <- CleanCV(cv.lrm, c("log GDP per cap. + log Pop.", ivar.labels))
cv.lrm.cwar <- lapply(lrm.vars, function(y)
                      lapply(seq(1, MI_ITER), function(z)
                             mclapply(specs.cwar, function(x)
                                      CVrms(df.mi[[z]][, y],
                                            model.matrix(as.formula(x), df.mi[[z]])[, -1],
                                            CV_FOLD, CV_ITER, "lrm"), mc.cores = CORES)))
cv.lrm.cwar <- CleanCV(cv.lrm, c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))
cv.ols <- lapply(ols.vars, function(y)
                 lapply(seq(1, MI_ITER), function(z)
                        mclapply(specs, function(x)
                                 CVrms(df.mi[[z]][, y],
                                       model.matrix(as.formula(x), df.mi[[z]])[, -1],
                                       CV_FOLD, CV_ITER, "ols"), mc.cores = CORES)))
cv.ols <- CleanCV(cv.ols, c("log GDP per cap. + log Pop.", ivar.labels))
cv.ols.cwar <- lapply(ols.vars, function(y)
                      lapply(seq(1, MI_ITER), function(z)
                             mclapply(specs.cwar, function(x)
                                      CVrms(df.mi[[z]][, y],
                                            model.matrix(as.formula(x), df.mi[[z]])[, -1],
                                            CV_FOLD, CV_ITER, "ols"), mc.cores = CORES)))
cv.ols.cwar <- CleanCV(cv.ols, c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))
cv <- c(cv.lrm, cv.lrm.cwar, cv.ols, cv.ols.cwar)
