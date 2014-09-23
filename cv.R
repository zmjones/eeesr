set.seed(1987)
library(party)
library(foreach)
library(iterators)
library(doParallel)
library(parallel)
library(rms)
library(plyr)
registerDoParallel(makeCluster(detectCores()))
options(showprogress = FALSE)

cv.lrm <- CleanCV(CallCV(lrm.vars, specs, "lrm"),
                  c("log GDP per cap. + log Pop.", ivar.labels))
cv.lrm.cwar <- CleanCV(CallCV(lrm.vars, specs.cwar, "lrm"),
                       c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))
cv.lrm.lag <- CleanCV(CallCV(lrm.vars, specs, "lrm", TRUE),
                      c("log GDP per cap. + log Pop. + LDV", ivar.labels))
cv.ols <- CleanCV(CallCV(ols.vars, specs, "ols"),
                  c("log GDP per cap. + log Pop.", ivar.labels))
cv.ols.cwar <- CleanCV(CallCV(ols.vars, specs.cwar, "ols"),
                       c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar))
cv.ols.lag <- CleanCV(CallCV(ols.vars[-3], specs, "ols", TRUE),
                      c("log GDP per cap. + log Pop. + LDV", ivar.labels))
cv <- c(cv.lrm, cv.lrm.cwar, cv.lrm.lag, cv.ols, cv.ols.cwar, cv.ols.lag)
save(cv, file = "cv.RData")
