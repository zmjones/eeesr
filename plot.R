require(ggplot2)
require(reshape2)
require(plyr)
require(grid)

setBreaks <- function(x) {
  range <- max(x) - min(x)
  breaks <- round(c(min(x) + range / 5, median(x), max(x) - range / 5), 2)
  names(breaks) <- attr(breaks, "labels")
  return(breaks)
}

PlotCater <- function(cv, file.prefix, xlab = "Coefficient", mtype = "LRM", all = FALSE, imp = FALSE) {
  len <- length(cv)
  if (all == FALSE) {
    if (mtype == "LRM")
      bound <- "upr"
    else if (mtype == "OLS")
      bound <- "lwr"
    else
      stop("Invalid model type argument.")
  }
  cv <- ldply(cv, function(x) {
    if (all == FALSE & imp == FALSE)
      x$base <- x[grep("log GDP per cap\\.", x$spec), bound]
    else x$base <- 0
    x$spec <- as.factor(x$spec)
    return(x)
  })
  cv$spec <- reorder(cv$spec, cv$median)
  if (all == FALSE & imp == FALSE)
    cv <- ddply(cv, .(depvar), transform, pos = grep("log GDP per cap\\.", levels(spec)))
  p <- ggplot(data = cv, aes(y = spec, x = median))
  p <- p + geom_point()
  p <- p + geom_errorbarh(aes(x = median, xmax = upr, xmin = lwr, height = .25))
  p <- p + geom_vline(aes(xintercept = base), linetype = "dashed")
  if (all == FALSE & imp == FALSE)
    p <- p + geom_rect(aes(ymin = pos - .5, ymax = pos + .5, xmin = -Inf, xmax = Inf), alpha = .01)
  p <- p + scale_x_continuous(breaks = setBreaks)
  p <- p + labs(x = xlab, y = NULL)
  p <- p + facet_wrap(~ depvar, scales = "free_x", nrow = 1)
  p <- p + theme_bw()
  p <- p + theme(plot.margin = unit(rep(PLOT_BORDER, 4), "in"))
  scale <- .85
  height <- 6
  width <- 12
  ## if (imp == TRUE)
  ##   height <- height * 3
  ggsave(paste0("./figures/", file.prefix, ".png"), plot = p,
         height = height * scale, width = width * scale)
}

depvars <- c(rep(lrm.labs, 3), rep(ols.labs, 3))
depvars.imp <- c(lrm.labs, ols.labs[-2])

for(i in 1:length(imp))
  imp[[i]]$depvar <- depvars.imp[i]

for(i in 1:length(cv)) {
  cv[[i]]$depvar <- depvars[i]
  ## all[[i]]$depvar <- depvars[i]
}

PlotCater(cv[c(1:4)], "cv-lrm", expression(D[xy]), "LRM")
PlotCater(cv[c(6:9)], "cv-lrm-cwar", expression(D[xy]), "LRM")
PlotCater(cv[c(1:5)], "cv-lrm-pts", expression(D[xy]), "LRM")
PlotCater(cv[c(6:10)], "cv-lrm-cwar-pts", expression(D[xy]), "LRM")
PlotCater(cv[c(11:15)], "cv-lrm-ldv", expression(D[xy]), "LRM")
PlotCater(cv[c(16:18)], "cv-ols", "RMSE", "OLS")
PlotCater(cv[c(19:21)], "cv-ols-cwar", "RMSE", "OLS")
PlotCater(cv[c(22:23)], "cv-ols-ldv", "RMSE", "OLS")

PlotCater(all[c(1:5)], "all-lrm", all = TRUE)
PlotCater(all[c(6:10)], "all-lrm-cwar", all = TRUE)
PlotCater(all[c(11:15)], "all-lrm-ldv", all = TRUE)
PlotCater(all[c(16:18)], "all-ols", all = TRUE)
PlotCater(all[c(19:21)], "all-ols-cwar", all = TRUE)
PlotCater(all[c(22:23)], "all-ols-ldv", all = TRUE)

PlotCater(imp[c(1:4)], "imp-ciri", "Permutation Importance", imp = TRUE)
PlotCater(imp[c(5:7)], "imp-aggregate", "Permutation Importance", imp = TRUE)

mi.vars <- colnames(df)[as.logical(apply(df, 2, function(x) any(is.na(x))))]
obs <- df[, mi.vars[-c(25:30)]]
obs$type <- "obs"
mi <- as.data.frame(do.call("rbind", df.mi))[, mi.vars]
i <- 1
mi <- apply(mi, 2, function(x) {
  x <- x[is.na(obs[, i])]
  i <- i + 1
  return(x)
})
mi <- as.data.frame(apply(mi, 2, as.numeric))
mi <- mi[, mi.vars[-c(25:31)]]
mi$type <- "mi"
plot.df <- as.data.frame(rbind(obs, mi))
plot.df <- melt(plot.df, id.vars = "type")
mi.labels <- c("Polity", "Executive Compet.", "Executive Open.", "Executive Const.",
               "Participation Compet.", "log Population", "log GDP per capita",
               "log Oil Rents", "Left Executive", "log Trade/GDP", "FDI", "Public Trial",
               "Fair Trial", "Court Decision Final", "Legislative Approval", "WB/IMF Structural Adj.",
               "IMF Structural Adj.", "WB Structural Adj.", "CAT Ratifier", "Youth Bulge",
               "AI Press (lag)", "AI Background (lag)", "Western Media (lag)", "HRO Shaming (lag)")
plot.df$type <- factor(plot.df$type, levels = unique(plot.df$type), labels = c("Imputed", "Observed"))
plot.df$variable <- factor(plot.df$variable, levels = unique(plot.df$variable), labels = mi.labels)
p <- ggplot(data = plot.df, aes(x = value))
p <- p + geom_density(aes(fill = type), alpha = .4)
p <- p + scale_fill_brewer(palette = "Set1")
p <- p + facet_wrap( ~ variable, ncol = 4, scales = "free")
p <- p + theme_bw()
p <- p + theme(legend.title = element_blank())
ggsave("figures/mi.png", plot = p, width = 10, height = 10)

depvars <- c(lrm.vars, "physint")
depvars <- c(depvars, paste0(depvars, "_lag"))
plot.df <- df[, !colnames(df) %in% c("ccode", "year", "gdppc", "pop", depvars)]
colnames(plot.df) <- c(ivar.labels)
plot.df <- melt(cor(plot.df, use = "na.or.complete"))
plot.df <- plot.df[order(plot.df$value), ]
plot.df$Var1 <- reorder(plot.df$Var1, plot.df$value)
plot.df$Var2 <- reorder(plot.df$Var2, plot.df$value)
p <- ggplot(data = plot.df, aes(x = Var1, y = Var2, fill = value))
p <- p + geom_tile()
p <- p + scale_fill_gradient2(name = "Correlation", breaks = seq(-.25, 1, by = .25),
                              space = "Lab")
p <- p + guides(fill = guide_colorbar(barwidth = .75, ticks = FALSE))
p <- p + labs(x = NULL, y = NULL)
p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("./figures/cor-cov.png", plot = p, width = 8, height = 8)
