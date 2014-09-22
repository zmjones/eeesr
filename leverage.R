library(rms)
source("setup.R")

check <- function(form) {
    fit <- lrm(as.formula(form), df, y = TRUE, x = TRUE)
    suppressWarnings(infl <- residuals(fit, type = "dfbetas"))
    test <- data.frame("iwar" = fit$x[, 3], "infl" = na.omit(infl[, 4]))
    out <- test[test$iwar == 1, ]
    print(form)
    data.frame(df[row.names(out), c(1,3)], "dfbeta" = out$infl)
}

check("physint ~ gdppc + pop + iwar")
check("amnesty ~ gdppc + pop + iwar")
check("disap ~ gdppc + pop + iwar")
check("polpris ~ gdppc + pop + iwar")
check("tort ~ gdppc + pop + iwar")
check("kill ~ gdppc + pop + iwar")
