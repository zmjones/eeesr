require(plyr)
require(stringr)
require(lubridate)
require(ggplot2)
require(reshape2)
require(grid)
require(countrycode)
require(foreign)
require(rms)
options(showprogress = FALSE)
require(multicore)
require(party)

CVrms <- function(response, input, B, R, model) {
  cv <- vector("numeric", R)
  if (model == "lrm") {
    fit <- lrm(response ~ input, x = TRUE, y = TRUE)
    for(r in 1:R)
      cv[r] <- validate(fit, B, method = "cross")[1, 5]
  } else if (model == "ols") {
    fit <- ols(response ~ input, x = TRUE, y = TRUE)
    for(r in 1:R)
      cv[r] <- sqrt(validate(fit, B, method = "cross")[2, 3])
  } else break
  return(cv)
}

Frms <- function(response, input, model, var) {
  if (model == "lrm")
    fit <- lrm(response ~ input)
  else if (model == "ols")
    fit <- ols(response ~ input)
  else break
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

CleanCV <- function(cv) {
  cv <- as.data.frame(t(apply(cv, 1, function(x)
                      quantile(x, probs = c(.025, .5, .975)))))
  colnames(cv) <- c("lwr", "median", "upr")
  cv$spec <- row.names(cv)
  row.names(cv) <- NULL
  return(cv)
}

CallCV <- function(specs, depvar, mtype, rnames) {
  cv <- CleanCV(t(as.data.frame(mclapply(specs, function(x)
                CVrms(depvar, model.matrix(as.formula(x), df)[, -1],
                      10, 500, model = mtype), mc.cores = CORES))))
  cv$spec <- rnames
  return(cv)
}

PlotCV <- function(df, file.prefix, title, ylab) {
  if (grepl("LRM", title))
    df$base <- df[1, "upr"]
  else
    df$base <- df[1, "lwr"]
  df$spec <- reorder(df$spec, df$median)
  df$pos <- grep("log GDP per cap\\.", levels(df$spec))
  p <- ggplot(data = df, aes(x = spec, y = median, group = spec))
  p <- p + geom_point()
  p <- p + geom_errorbar(aes(y = median, ymin = lwr, ymax = upr), width = .25)
  p <- p + geom_hline(aes(yintercept = base), linetype = "dashed")
  p <- p + geom_rect(aes(xmin = pos - .5, xmax = pos + .5, ymin = -Inf, ymax = Inf), alpha = .01)
  p <- p + theme_bw() + coord_flip()
  p <- p + labs(title = title, y = ylab, x = "Model Specification")
  p <- p + theme(plot.margin = unit(c(.1, .1, .1, .1), "in"))
  ggsave(paste("./figures/", file.prefix, ".png", sep = ""), plot = p, width = 6, height = 6)
}

PlotAll <- function(df, file.prefix, title) {
  df$spec <- reorder(df$spec, df$coef)
  p <- ggplot(df, aes(x = spec, y = coef))
  p <- p + geom_point()
  p <- p + geom_errorbar(aes(y = coef, ymin = coef - 2 * se, ymax = coef + 2 * se), width = .2)
  p <- p + geom_hline(y = 0, linetype = "dashed")
  p <- p + labs(x = "Model Specification", y = "Coefficient", title = title)
  p <- p + coord_flip() + theme_bw()
  p <- p + theme(plot.margin = unit(c(.1, .1, .1, .1), "in"))
  ggsave(paste0("figures/", file.prefix, ".png"), plot = p, width = 6, height = 6)
}

PlotImp <- function(var.imp, title, file.prefix, rnames) {
  df <- data.frame("var" = rnames, "imp" = var.imp)
  df$var <- reorder(df$var, df$imp)
  p <- ggplot(data = df, aes(x = factor(var), y = imp))
  p <- p + geom_bar(stat = "identity")
  p <- p + labs(x = "Variable", y = "Importance", title = title)
  p <- p + coord_flip() + theme_bw()
  p <- p + theme(plot.margin = unit(c(.1, .1, .1, .1), "in"))
  ggsave(paste0("figures/", file.prefix, ".png"), plot = p, width = 6, height = 6)
}
