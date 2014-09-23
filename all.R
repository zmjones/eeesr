set.seed(1987)

library(rms)
library(stringr)
library(parallel)
library(plyr)

Frms <- function(response, input, model, var) {
    # response: dependent variable (vector)
    # input: input matrix (matrix or dataframe)
    # model: string vector (length 1), either "lrm" or "ols"
    # var: string vector (length 1) which is to be extracted
    # returns: vector (length 2) containing coefficient and standard error of "var"
    if (model == "lrm")
        fit <- lrm(response ~ input)
    else if (model == "ols")
        fit <- ols(as.integer(response) ~ input)
    else stop("Invalid model type.")
    beta <- coef(fit)
    se <- sqrt(diag(vcov(fit)))
    c(beta[var], se[var])
}

CleanAll <- function(all, labels) {
    # all: list of lists of all results (from function CallAll)
    # returns: list of dataframes with coef, se, and var
    all <- lapply(all, function(x) lapply(x, function(y) do.call(rbind, y)))
    all <- lapply(all, function(x) as.data.frame(do.call(rbind, x)))
    all <- lapply(all, function(x) {
        colnames(x) <- c("coef", "se")
        x$lwr <- x$coef - 1.96 * x$se
        x$upr <- x$coef + 1.96 * x$se
        x$median <- x$coef
        x$spec <- labels
        x <- x[, c("spec", "lwr", "median", "upr")]
        x <- ddply(x, .(spec), function(x) colMeans(x[, -1]))
        return(x)
    })
    return(all)
}

CallAll <- function(vars, specs, model, lag = FALSE) {
    # vars: a string vector of dependent variables
    # specs: a string vector of model specifications
    # model: string vector (length 1), either "lrm" or "ols"
    # lag: logical, use a LDV?
    # returns: list of lists with all coef/se results
    all <- lapply(vars, function(y) {
        lapply(seq(1, MI_ITER), function(z) {
            mclapply(specs, function(x) {
                if (lag == TRUE) {
                    df <- na.omit(df.mi[[z]])
                    x <- sub(" ", paste0(y, "_lag + "), x)
                }
                else df <- df.mi[[z]]
                Frms(df[, y], model.matrix(as.formula(x), df)[, -1],
                     model, str_extract(x, "\\b[a-zA-Z|_|(|)|0-9]+$"))
            }, mc.cores = CORES)})})
    return(all)
}

all.lrm <- CleanAll(CallAll(lrm.vars, specs, "lrm"), ivar.labels)
all.lrm.cwar <- CleanAll(CallAll(lrm.vars, specs.cwar, "lrm"), ivar.labels.cwar)
all.lrm.lag <- CleanAll(CallAll(lrm.vars, specs, "lrm", TRUE), ivar.labels)
all.ols <- CleanAll(CallAll(ols.vars, specs, "ols"), ivar.labels)
all.ols.cwar <- CleanAll(CallAll(ols.vars, specs.cwar, "ols"), ivar.labels.cwar)
all.ols.lag <- CleanAll(CallAll(ols.vars, specs, "ols", TRUE), ivar.labels)
all <- c(all.lrm, all.lrm.cwar, all.lrm.lag, all.ols, all.ols.cwar, all.ols.lag)
save(all, file = "all.RData")
