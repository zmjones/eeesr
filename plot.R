library(ggplot2)
library(reshape2)
library(plyr)
library(grid)
library(polycor)

setBreaks <- function(x) {
  range <- max(x) - min(x)
  breaks <- round(c(min(x) + range / 5, median(x), max(x) - range / 5), 2)
  names(breaks) <- attr(breaks, "labels")
  return(breaks)
}

PlotCater <- function(df, file.prefix, xlab = "Coefficient", mtype = "LRM", all = FALSE, imp = FALSE) {
  scale <- .85
  height <- 8
  width <- 12
  if (all == FALSE) {
    if (mtype == "LRM")
      bound <- "upr"
    else if (mtype == "OLS")
      bound <- "lwr"
    else
      stop("Invalid model type argument.")
  }
  df <- ldply(df, function(x) {
    if (all == FALSE & imp == FALSE)
      x$base <- x[grep("log GDP per cap\\.", x$spec), bound]
    else x$base <- 0
    x$spec <- as.factor(x$spec)
    return(x)
  })
  df$spec <- reorder(df$spec, df$median)
  if (all == FALSE & imp == FALSE)
    df <- ddply(df, .(depvar), transform, pos = grep("log GDP per cap\\.", levels(spec)))
  p <- ggplot(data = df, aes(y = spec, x = median))
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
  ggsave(paste0("./figures/", file.prefix, ".png"), plot = p,
         height = height * scale, width = width * scale)
}

depvars <- c(rep(lrm.labs, 3), rep(ols.labs, 3))
depvars.imp <- c(lrm.labs, ols.labs[-2])

for(i in 1:length(imp))
  imp[[i]]$depvar <- depvars.imp[i]

for(i in 1:length(cv)) {
  cv[[i]]$depvar <- depvars[i]
  all[[i]]$depvar <- depvars[i]
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

depvars <- c(lrm.vars, "physint", "latent")
depvars <- c(depvars, paste0(depvars, "_lag"))
mi.vars <- colnames(df)[as.logical(apply(df, 2, function(x)
    any(is.na(x)))) & !(colnames(df) %in% depvars)]
obs <- df[, mi.vars]
obs$type <- "obs"
mi <- as.data.frame(do.call("rbind", df.mi))[, mi.vars]
i <- 1
mi <- apply(mi, 2, function(x) {
  x <- x[is.na(obs[, i])]
  i <- i + 1
  return(x)
})
mi <- as.data.frame(apply(mi, 2, as.numeric))
mi$type <- "mi"
plot.df <- as.data.frame(rbind(obs, mi))
plot.df <- melt(plot.df, id.vars = "type")
ivar.lookup <- data.frame("ivar" = ivars, "labels" = ivar.labels)
mi.labels <- ivar.lookup[match(mi.vars, ivar.lookup$ivar), "labels"]
mi.labels[is.na(mi.labels)] <- c("log Population", "log GDP per Cap.")
## mi.labels <- ivar.labels[apply(df[, colnames(df) %in% ivars], 2, function(x) any(is.na(x)))]
plot.df$type <- factor(plot.df$type, levels = unique(plot.df$type), labels = c("Observed", "Imputed"))
plot.df$variable <- factor(plot.df$variable, levels = unique(plot.df$variable), labels = mi.labels)
p <- ggplot(data = na.omit(plot.df), aes(x = value))
p <- p + geom_density(aes(fill = type), alpha = .4)
p <- p + scale_fill_brewer(palette = "Set1")
p <- p + facet_wrap( ~ variable, ncol = 4, scales = "free")
p <- p + theme_bw()
p <- p + theme(legend.title = element_blank())
ggsave("figures/mi.png", plot = p, width = 10, height = 10)

plot.df <- df[, !colnames(df) %in% c("ccode", "year", "gdppc", "pop", "latent_sd", depvars)]
colnames(plot.df) <- ivar.labels
plot.df <- melt(hetcor(plot.df, use = "pairwise.complete.obs")$correlations)
plot.df <- plot.df[order(plot.df$value), ]
plot.df$Var1 <- reorder(plot.df$Var1, plot.df$value)
plot.df$Var2 <- reorder(plot.df$Var2, plot.df$value)
p <- ggplot(data = plot.df, aes(x = Var1, y = Var2, fill = value))
p <- p + geom_tile()
p <- p + scale_fill_gradient2(name = "Correlation", breaks = seq(-1, 1, by = .25),
                              space = "Lab")
p <- p + guides(fill = guide_colorbar(barwidth = .75, ticks = FALSE))
p <- p + labs(x = NULL, y = NULL)
p <- p + theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("./figures/cor-cov.png", plot = p, width = 9, height = 9)
