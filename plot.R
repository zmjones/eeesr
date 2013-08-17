invisible(lapply(c("ggplot2", "grid", "reshape2"), require, character.only = TRUE))

PlotAll <- function(df, file.prefix, title) {
  df$spec <- reorder(df$spec, df$coef)
  p <- ggplot(df, aes(x = spec, y = coef))
  p <- p + geom_point()
  p <- p + geom_errorbar(aes(y = coef, ymin = coef - 2 * se, ymax = coef + 2 * se), width = .2)
  p <- p + geom_hline(y = 0, linetype = "dashed")
  p <- p + labs(x = "Model Specification", y = "Coefficient", title = title)
  p <- p + coord_flip() + theme_bw()
  p <- p + theme(plot.margin = unit(rep(PLOT_BORDER, 4), "in"))
  ggsave(paste0("figures/", file.prefix, ".png"), plot = p, width = 6, height = 6)
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
  p <- p + theme(plot.margin = unit(rep(PLOT_BORDER, 4), "in"))
  ggsave(paste("./figures/", file.prefix, ".png", sep = ""), plot = p, width = 6, height = 6)
}

PlotImp <- function(var.imp, title, file.prefix, rnames, pval) {
  sig <- sapply(pval, function(x) if (x <= .05) "yes" else "no")
  df <- data.frame("var" = rnames, "imp" = var.imp,
                   "sig" = factor(sig, levels = c("yes", "no")))
  df$var <- reorder(factor(df$var), df$imp)
  p <- ggplot(data = df, aes(x = factor(var), y = imp, fill = sig))
  p <- p + scale_fill_grey(name = "p < .05")
  p <- p + geom_bar(stat = "identity")
  p <- p + labs(x = "Variable", y = "Importance", title = title)
  p <- p + coord_flip() + theme_bw()
  p <- p + theme(plot.margin = unit(rep(PLOT_BORDER, 4), "in"))
  ggsave(paste0("figures/", file.prefix, ".png"), plot = p, width = 6, height = 6)
}

plot.df <- df[, !colnames(df) %in% c("ccode", "year", ciri.vars,
                                     "physint", "amnesty", "gdppc", "pop")]
colnames(plot.df) <- ivar.labels
max.cor <- apply(apply(cor(plot.df), 1, function(x) ifelse(x == 1, NA, x)), 1,
                 function(x) max(x, na.rm = TRUE))
p <- ggplot(data = melt(cor(plot.df)), aes(x = Var1, y = Var2, fill = value))
p <- p + geom_tile()
p <- p + scale_fill_gradient2(space = "Lab", name = "Correlation")
p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1))
p <- p + guides(fill = guide_colorbar(barwidth = .75, ticks = FALSE))
p <- p + labs(x = NULL, y = NULL, title = "Covariate Correlations")
ggsave("./figures/cor-cov.png", plot = p, width = 8, height = 8)

PlotAll(all[[1]], "all-disap", "Disappearances, All Data (LRM)")
PlotAll(all[[2]], "all-kill", "Killings, All Data (LRM)")
PlotAll(all[[3]], "all-polpris", "Political Imprisonment, All Data (LRM)")
PlotAll(all[[4]], "all-tort", "Torture, All Data (LRM)")
PlotAll(all[[5]], "all-pts-lrm", "Political Terror Scale, All Data (LRM)")
PlotAll(all[[6]], "all-physint", "Physical Integrity Index, All Data (OLS)")
PlotAll(all[[7]], "all-pts-ols", "Political Terror Scale, All Data (OLS)")

dxy.lab <- expression(D[xy])
PlotCV(cv[[1]], "cv-disap", "Disappearances (LRM)", dxy.lab)
PlotCV(cv[[2]], "cv-kill", "Killings (LRM)", dxy.lab)
PlotCV(cv[[3]], "cv-polpris", "Political Imprisonment (LRM)", dxy.lab)
PlotCV(cv[[4]], "cv-tort", "Torture (LRM)", dxy.lab)
PlotCV(cv[[5]], "cv-pts-lrm", "Political Terror Scale (LRM)", dxy.lab)
PlotCV(cv[[6]], "cv-cwar-disap", "Disappearances (LRM)", dxy.lab)
PlotCV(cv[[7]], "cv-cwar-kill", "Killings (LRM)", dxy.lab)
PlotCV(cv[[8]], "cv-cwar-polpris", "Political Imprisonment (LRM)", dxy.lab)
PlotCV(cv[[9]], "cv-cwar-tort", "Torture (LRM)", dxy.lab)
PlotCV(cv[[10]], "cv-cwar-pts-lrm", "Political Terror Scale LRM", dxy.lab)
PlotCV(cv[[11]], "cv-physint", "Physical Integrity Index (OLS)", "RMSE")
PlotCV(cv[[12]], "cv-pts-ols", "Political Terror Scale (OLS)", "RMSE")
PlotCV(cv[[13]], "cv-cwar-physint", "Physical Integrity Index (OLS)", "RMSE")
PlotCV(cv[[14]], "cv-cwar-pts-ols", "Physical Integrity Index (OLS)", "RMSE")

PlotImp(imp[[1]], "Disappearances, Importance and Significance (LRM)",
        "disap-imp-sig", ivar.labels, pval[[1]])
PlotImp(imp[[2]], "Killings, Importance and Significance (LRM)",
        "kill-imp-sig", ivar.labels, pval[[2]])
PlotImp(imp[[3]], "Political Imprisonment, Importance and Significance (LRM)",
        "polpris-imp-sig", ivar.labels, pval[[3]])
PlotImp(imp[[4]], "Torture, Importance and Significance (LRM)",
        "tort-imp-sig", ivar.labels, pval[[4]])
PlotImp(imp[[5]], "Political Terror Scale, Importance and Significance (LRM)",
        "pts-imp-sig", ivar.labels, pval[[5]])
PlotImp(imp[[6]], "Physical Integrity Index, Importance and Significance (OLS)",
        "physint-imp-sig", ivar.labels, pval[[6]])
