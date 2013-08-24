invisible(require("plyr"))

cv <- c(cv.lrm, cv.lrm.cwar, cv.ols, cv.ols.cwar)
cv <- lapply(cv, function(x) do.call(rbind, x))
cv <- lapply(cv, function(x) ddply(x[, -4], .(x$spec), colMeans))
cv <- lapply(cv, function(x) {colnames(x)[1] <- "spec"; return(x)})
