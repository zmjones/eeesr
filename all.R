invisible(lapply(c("rms", "stringr", "plyr"), require, character.only = TRUE))
options(showprogress = FALSE)

Frms <- function(response, input, model, var) {
  if (model == "lrm")
    fit <- lrm(response ~ input)
  else if (model == "ols")
    fit <- ols(response ~ input)
  else stop("Invalid model type.")
  beta <- coef(fit)
  se <- sqrt(diag(vcov(fit)))
  if (is.factor(get(gsub("log\\(|\\)", "", var), df)))
    return(c(beta[grepl(var, names(beta))], se[grepl(var, names(se))]))
  else
    return(c(beta[var], se[var]))
}

CleanAll <- function(x, vars) {
  colnames(x) <- c("coef", "se")
  x$spec <- vars
  return(x)
}

all.lrm <- lapply(lrm.vars, function(x) lapply(specs.cwar, function(y)
                  Frms(df[, x], model.matrix(as.formula(y), df)[, -1],
                  model = "lrm", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$"))))
all.ols <- lapply(ols.vars, function(x) lapply(specs.cwar, function(y)
                  Frms(as.integer(df[, x]), model.matrix(as.formula(y), df)[, -1],
                  model = "ols", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$"))))
all <- c(all.lrm, all.ols)
all <- lapply(all, function(x) data.frame(do.call(rbind, x)))
all <- lapply(all, function(x) CleanAll(x, ivar.labels[!(ivar.labels %in% "Civil War")]))

lrm.pval <- lapply(lrm.vars, function(x) lapply(specs, function(y)
               lrm((df[, x] ~ model.matrix(as.formula(y), df)[, -1]))))
lrm.pval <- lapply(lrm.pval, function(x) lapply(x, function(y)
               1 - pchisq((y$coefficients / sqrt(diag(y$var)))^2, 1)))
lrm.pval <- lapply(lrm.pval, function(x) ldply(x, function(y) y[length(y)])[, 1])
ols.pval <- unlist(lapply(specs, function(y) as.numeric(summary(lm(as.integer(df[, "physint"]) ~
                    model.matrix(as.formula(y), df)[, -1]))$coefficients[, 4])[4]))
ols.pval <- list(ols.pval)
pval <- c(lrm.pval, ols.pval)
