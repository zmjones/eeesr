rm(list = ls())
set.seed(1987)
CORES <- 8
source("functions.R")

df <- read.csv("./data/rep.csv")
df$disap <- factor(df$disap)
df$kill <- factor(df$kill)
df$polpris <- factor(df$polpris)
df$tort <- factor(df$tort)
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
ivar.labels <- c("INGOs", "Polity", "Executive Compet.", "Executive Open.",
                 "Executive Const.", "Participation Compet.", "Judicial Indep.",
                 "Oil Rents", "Military Regime", "Left Executive", "Trade/GDP", "FDI",
                 "Public Trial", "Fair Trial", "Court Decision Final", "Legislative Approval",
                 "WB/IMF Structural Adj.", "IMF Structural Adj.", "WB Structural Adj.",
                 "British Colony", "Common Law", "PTA w/ HR Clause", "CAT Ratifier",
                 "CPR Ratifier", "Youth Bulge", "Civil War", "International War",
                 "AI Press (lag)", "AI Background (lag)", "Western Media (lag)")
ivar.labels.cwar <- ivar.labels[!(ivar.labels %in% "Civil War")]

all.lrm <- lapply(lrm.vars, function(x) lapply(specs.cwar, function(y)
                  Frms(df[, x], model.matrix(as.formula(y), df)[, -1],
                  model = "lrm", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$"))))
all.ols <- lapply(ols.vars, function(x) lapply(specs.cwar, function(y)
                  Frms(df[, x], model.matrix(as.formula(y), df)[, -1],
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
cv.ols <- lapply(ols.vars, function(x) CallCV(specs, df[, x], "ols",
                 c("log GDP per cap. + log Pop.", ivar.labels)))
cv.ols.cwar <- lapply(ols.vars, function(x) CallCV(specs.cwar, df[, x], "ols",
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
