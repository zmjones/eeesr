Frms <- function(response, input, model, var) {
  # response: dependent variable (vector)
  # input: input matrix (matrix or dataframe)
  # model: string vector (length 1), either "lrm" or "ols"
  # var: string vector (length 1) which is to be extracted
  # returns: vector (length 2) containing coefficient and standard error of "var"
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
  # x: dataframe to be cleaned
  # vars: list of specification labels to be added as a column of x
  # returns: cleaned up dataframe with a column labeled "spec" and appropriate column labels
  colnames(x) <- c("coef", "se")
  x$spec <- vars
  return(x)
}

all.lrm <- lapply(lrm.vars, function(x)
                  lapply(seq(1, MI_ITER), function(z) lapply(specs, function(y)
                  Frms(df.mi[[z]][, x], model.matrix(as.formula(y), df.mi[[z]])[, -1],
                  model = "lrm", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$")))))
all.ols <- lapply(ols.vars, function(x)
                  lapply(seq(1, MI_ITER), function(z) lapply(specs, function(y)
                  Frms(as.integer(df.mi[[z]][, x]), model.matrix(as.formula(y), df.mi[[z]])[, -1],
                  model = "ols", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$")))))
all <- c(all.lrm, all.ols)
all <- lapply(all, function(x) lapply(x, function(y) data.frame(do.call(rbind, y))))
all <- lapply(all, function(x) lapply(x, function(y)
              CleanAll(y, ivar.labels)))
all <- lapply(all, function(x) do.call(rbind, x))
all <- lapply(all, function(x) ddply(x[, -3], .(x$spec), colMeans))
all <- lapply(all, function(x) {colnames(x)[1] <- "spec"; return(x)})

lrm.pval <- lapply(lrm.vars, function(x)
                   lapply(seq(1, MI_ITER), function(z)
                   lapply(specs, function(y)
                   lrm((df.mi[[z]][, x] ~ model.matrix(as.formula(y), df.mi[[z]])[, -1])))))
lrm.pval <- lapply(lrm.pval, function(x)
                   lapply(x, function(z)
                   lapply(z, function(y)
                   1 - pchisq((y$coefficients / sqrt(diag(y$var)))^2, 1))))
lrm.pval <- lapply(lrm.pval, function(x)
                   lapply(x, function(z)
                   sapply(z, function(y) as.numeric(y[length(y)]))))
lrm.pval <- lapply(lrm.pval, function(x) rowMeans(do.call(cbind, x)))
ols.pval <- lapply(seq(1, MI_ITER), function(x) unlist(lapply(specs, function(y)
                   as.numeric(summary(lm(as.integer(df.mi[[x]][, "physint"]) ~
                   model.matrix(as.formula(y), df.mi[[x]])[, -1]))$coefficients[, 4])[4])))
ols.pval <- list(rowMeans(do.call(cbind, ols.pval)))
pval <- c(lrm.pval, ols.pval)
