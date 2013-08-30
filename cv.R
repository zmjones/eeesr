invisible(lapply(c("rms", "multicore", "plyr"), require, character.only = TRUE))
options(showprogress = FALSE)

cv.lrm <- CleanCV(CallCV(lrm.vars, specs, "lrm"),
                  c("log GDP per cap. + log Pop.", ivar.labels))
cv.lrm.cwar <- CleanCV(CallCV(lrm.vars, specs.cwar, "lrm"),
                       c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))
cv.ols <- CleanCV(CallCV(ols.vars, specs, "ols"),
                  c("log GDP per cap. + log Pop.", ivar.labels))
cv.ols.cwar <- CleanCV(CallCV(ols.vars, specs.cwar, "ols"),
                       c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))
cv <- c(cv.lrm, cv.lrm.cwar, cv.ols, cv.ols.cwar)
