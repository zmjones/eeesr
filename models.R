rm(list = ls())
set.seed(1987)
CORES <- 8
source("functions.R")

df <- read.csv("./data/rep.csv")
df$disap <- as.ordered(df$disap)
df$kill <- as.ordered(df$kill)
df$tort <- as.ordered(df$tort)
df$polpris <- as.ordered(df$polpris)
df$physint <- as.ordered(df$physint)
df$amnesty <- as.ordered(df$amnesty)
df$gdppc <- log(df$gdppc)
df$pop <- log(df$pop)
df.save <- df[!(is.na(df$amnesty) | is.na(df$physint)), ]
df <- na.omit(df)

lrm.vars <- c("disap", "kill", "polpris", "tort", "amnesty")
ols.vars <- c("physint", "amnesty")
ciri.vars <- lrm.vars[1:4]
base.spec <- "~ log(gdppc) + log(pop)"
ivars <- colnames(df)[!colnames(df) %in% c("ccode", "year", ciri.vars,
                                           "physint", "amnesty", "gdppc", "pop")]
specs <- paste0("~ gdppc + pop + ", ivars)
specs.cwar <- paste0("~ gdppc + pop + cwar + ", ivars[!(ivars %in% "cwar")])
ivar.labels <- c("log INGOs", "Polity", "Executive Compet.", "Executive Open.",
                 "Executive Const.", "Participation Compet.", "Judicial Indep.",
                 "log Oil Rents", "Military Regime", "Left Executive", "log Trade/GDP", "FDI",
                 "Public Trial", "Fair Trial", "Court Decision Final", "Legislative Approval",
                 "WB/IMF Structural Adj.", "IMF Structural Adj.", "WB Structural Adj.",
                 "British Colony", "Common Law", "PTA w/ HR Clause", "CAT Ratifier",
                 "CPR Ratifier", "Youth Bulge", "Civil War", "International War",
                 "AI Press (lag)", "AI Background (lag)", "Western Media (lag)")
ivar.labels.cwar <- ivar.labels[!(ivar.labels %in% "Civil War")]

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
plot.df <- data.frame("var" = names(max.cor), "cor" = max.cor)
plot.df$var <- reorder(plot.df$var, plot.df$cor)
p <- ggplot(data = plot.df, aes(x = factor(var), y = cor))
p <- p + geom_bar(stat = "identity")
p <- p + labs(x = "Variable", y = "Maximum Correlation")
p <- p + coord_flip() + theme_bw()
p <- p + theme(plot.margin = unit(c(.1, .1, .1, .1), "in"))
ggsave("./figures/max-cor.png", plot = p, width = 6, height = 6)

all.lrm <- lapply(lrm.vars, function(x) lapply(specs.cwar, function(y)
                  Frms(df[, x], model.matrix(as.formula(y), df)[, -1],
                  model = "lrm", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$"))))
all.ols <- lapply(ols.vars, function(x) lapply(specs.cwar, function(y)
                  Frms(as.integer(df[, x]), model.matrix(as.formula(y), df)[, -1],
                  model = "ols", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$"))))
all <- c(all.lrm, all.ols)
all <- lapply(all, function(x) data.frame(do.call(rbind, x)))
all <- lapply(all, function(x) CleanAll(x, ivar.labels[!(ivar.labels %in% "Civil War")]))
PlotAll(all[[1]], "all-disap", "Disappearances, All Data (LRM)")
PlotAll(all[[2]], "all-kill", "Killings, All Data (LRM)")
PlotAll(all[[3]], "all-polpris", "Political Imprisonment, All Data (LRM)")
PlotAll(all[[4]], "all-tort", "Torture, All Data (LRM)")
PlotAll(all[[5]], "all-pts-lrm", "Political Terror Scale, All Data (LRM)")
PlotAll(all[[6]], "all-physint", "Physical Integrity Index, All Data (OLS)")
PlotAll(all[[7]], "all-pts-ols", "Political Terror Scale, All Data (OLS)")

specs <- c("~ gdppc + pop", specs)
specs.cwar <- c("~ gdppc + pop + cwar", specs.cwar)
cv.lrm <- lapply(lrm.vars, function(x) CallCV(specs, df[, x], "lrm",
                 c("log GDP per cap. + log Pop.", ivar.labels)))
cv.lrm.cwar <- lapply(lrm.vars, function(x) CallCV(specs.cwar, df[, x], "lrm",
                      c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar)))
cv.ols <- lapply(ols.vars, function(x) CallCV(specs, as.integer(df[, x]), "ols",
                 c("log GDP per cap. + log Pop.", ivar.labels)))
cv.ols.cwar <- lapply(ols.vars, function(x) CallCV(specs.cwar, as.integer(df[, x]), "ols",
                      c("log GDP per cap. + log Pop. + Civil War", ivar.labels.cwar)))
cv <- c(cv.lrm, cv.lrm.cwar, cv.ols, cv.ols.cwar)
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

imp <- mclapply(c(lrm.vars, "physint"), function(x)
                varimp(cforest(as.formula(paste0(x, "~", paste0(ivars, collapse = "+"))),
                data = df.save)), mc.cores = CORES)
PlotImp(imp[[1]], "Disappearances, Variable Importance", "disap-imp", ivar.labels)
PlotImp(imp[[2]], "Killings, Variable Importance", "kill-imp", ivar.labels)
PlotImp(imp[[3]], "Political Imprisonment, Variable Importance", "polpris-imp", ivar.labels)
PlotImp(imp[[4]], "Torture, Variable Importance", "tort-imp", ivar.labels)
PlotImp(imp[[5]], "Political Terror Scale, Variable Importance", "pts-imp", ivar.labels)
PlotImp(imp[[6]], "Physical Integrity Index, Variable Importance", "physint-imp", ivar.labels)

pval <- lapply(c(ciri.vars, ols.vars), function(x) lapply(specs.cwar[-1], function(y)
               lrm((df[, x] ~ model.matrix(as.formula(y), df)[, -1]))))
pval <- lapply(pval, function(x) lapply(x, function(y)
               1 - pchisq((y$coefficients / sqrt(diag(y$var)))^2, 1)))
pval <- lapply(pval, function(x) ldply(x, function(y) y[length(y)])[, 1])
PlotPval(pval[[1]], "Disappearances, P-Values", "disap-pval", ivar.labels.cwar)
PlotPval(pval[[2]], "Killings, P-Values", "kill-pval", ivar.labels.cwar)
PlotPval(pval[[3]], "Political Imprisonment, P-Values", "polpris-pval", ivar.labels.cwar)
PlotPval(pval[[4]], "Torture, P-Values", "tort-pval", ivar.labels.cwar)
PlotPval(pval[[5]], "Political Terror Scale, P-Values", "pts-pval", ivar.labels.cwar)
PlotPval(pval[[6]], "Physical Integrity Index, P-Values", "physint-pval", ivar.labels.cwar)
