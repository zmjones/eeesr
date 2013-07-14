rm(list = ls())

source("functions.R")

df <- read.csv("./data/rep.csv")
#df <- df[, -c(29:31)]
#nrow(na.omit(df)) == 1415
df$disap <- factor(df$disap)
df$kill <- factor(df$kill)
df$polpris <- factor(df$polpris)
df$tort <- factor(df$tort)
df$gdppc <- log(df$gdppc)
df$pop <- log(df$pop)
#nrow(df) == 2625
df <- na.omit(df)
#nrow(df) == 1082

ciri.vars <- c("disap", "kill", "polpris", "tort")
base.spec <- "~ log(gdppc) + log(pop)"
ivars <- colnames(df)[!colnames(df) %in% c("ccode", "year", ciri.vars, "physint", "amnesty",
                                           "gdppc", "pop")]
specs <- paste0("~ gdppc + pop + ", ivars)
specs.cwar <- paste0("~ gdppc + pop + cwar + ", ivars[!(ivars %in% "cwar")])

all.ciri <- lapply(ciri.vars, function(x) lapply(specs.cwar, function(y)
                   Frms(df[, x], model.matrix(as.formula(y), df)[, -1],
                   model = "lrm", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$"))))
all.ciri <- lapply(all.ciri, function(x) data.frame(do.call(rbind, x)))
all.ciri <- do.call(rbind, lapply(all.ciri, function(x) CleanAll(x, ivars[!(ivars %in% "cwar")])))
pos <- grep("ingo", all.ciri$spec)
all.ciri$var[as.integer(row.names(all.ciri)) <= pos[2] - 1] <- "disap"
all.ciri$var[as.integer(row.names(all.ciri)) >= pos[2] &
        as.integer(row.names(all.ciri)) <= pos[3] - 1] <- "kill"
all.ciri$var[as.integer(row.names(all.ciri)) >= pos[3] &
        as.integer(row.names(all.ciri)) <= pos[4] - 1] <- "polpris"
all.ciri$var[as.integer(row.names(all.ciri)) >= pos[4]] <- "tort"

all.physint <- lapply(specs.cwar, function(y) Frms(df[, "physint"],
                      model.matrix(as.formula(y), df)[, -1],
                      model = "ols", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$")))
all.physint <- data.frame(do.call(rbind, all.physint))
colnames(all.physint) <- c("coef", "se")
all.physint$spec <- ivars[!(ivars %in% "cwar")]

all.pts.ols <- lapply(specs.cwar, function(y) Frms(df[, "amnesty"],
                      model.matrix(as.formula(y), df)[, -1],
                      model = "ols", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$")))
all.pts.ols <- data.frame(do.call(rbind, all.pts.ols))
colnames(all.pts.ols) <- c("coef", "se")
all.pts.ols$spec <- ivars[!(ivars %in% "cwar")]

all.pts.lrm <- lapply(specs.cwar, function(y) Frms(df[, "amnesty"],
                      model.matrix(as.formula(y), df)[, -1],
                      model = "lrm", var = str_extract(y, "\\b[a-z|_|(|)|0-9]+$")))
all.pts.lrm <- data.frame(do.call(rbind, all.pts.lrm))
colnames(all.pts.lrm) <- c("coef", "se")
all.pts.lrm$spec <- ivars[!(ivars %in% "cwar")]

PlotAll(all.ciri[all.ciri$var == "disap", ], "all-disap", "Disappearances, All Data (LRM)")
PlotAll(all.ciri[all.ciri$var == "kill", ], "all-kill", "Killings, All Data (LRM)")
PlotAll(all.ciri[all.ciri$var == "polpris", ], "all-polpris", "Political Imprisonment, All Data (LRM)")
PlotAll(all.ciri[all.ciri$var == "tort", ], "all-tort", "Torture, All Data (LRM)")
PlotAll(all.physint, "all-physint", "Physical Integrity Index, All Data (OLS)")
PlotAll(all.pts.ols, "all-pts-ols", "Political Terror Scale, All Data (OLS)")
PlotAll(all.pts.lrm, "all-pts-lrm", "Political Terror Scale, All Data (LRM)")

specs <- c("~ gdppc + pop", specs)
cv <- do.call(rbind, lapply(ciri.vars, function(x)
              CallCV(specs, df[, x], "lrm", c("gdppc + pop", ivars))))

specs.cwar <- c("~ gdppc + pop + cwar", specs.cwar)
cv.cwar <- do.call(rbind, lapply(ciri.vars, function(x)
           CallCV(specs, df[, x], "lrm", c("gdppc + pop + cwar", ivars))))

pos <- grep("gdppc", cv$spec)
cv$var[as.integer(row.names(cv)) <= pos[2] - 1] <- "disap"
cv$var[as.integer(row.names(cv)) >= pos[2] &
       as.integer(row.names(cv)) <= pos[3] - 1] <- "kill"
cv$var[as.integer(row.names(cv)) >= pos[3] &
       as.integer(row.names(cv)) <= pos[4] - 1] <- "polpris"
cv$var[as.integer(row.names(cv)) >= pos[4]] <- "tort"

pos <- grep("gdppc", cv.cwar$spec)
cv.cwar$var[as.integer(row.names(cv.cwar)) <= pos[2] - 1] <- "disap"
cv.cwar$var[as.integer(row.names(cv.cwar)) >= pos[2] &
            as.integer(row.names(cv.cwar)) <= pos[3] - 1] <- "kill"
cv.cwar$var[as.integer(row.names(cv.cwar)) >= pos[3] &
            as.integer(row.names(cv.cwar)) <= pos[4] - 1] <- "polpris"
cv.cwar$var[as.integer(row.names(cv.cwar)) >= pos[4]] <- "tort"

cv.physint <- CallCV(specs, df$physint, "ols", c("gdppc + pop", ivars))
cv.cwar.physint <- CallCV(specs.cwar, df$physint, "ols",
                          c("gdppc + pop + cwar", ivars[!(ivars %in% "cwar")]))

cv.pts.ols <- CallCV(specs, df$amnesty, "ols", c("gdppc + pop", ivars))
cv.cwar.pts.ols <- CallCV(specs.cwar, df$amnesty, "ols",
                          c("gdppc + pop + cwar", ivars[!(ivars %in% "cwar")]))
cv.pts.lrm <- CallCV(specs, df$amnesty, "lrm", c("gdppc + pop", ivars))
cv.cwar.pts.lrm <- CallCV(specs.cwar, df$amnesty, "lrm",
                          c("gdppc + pop + cwar", ivars[!(ivars %in% "cwar")]))

dxy.lab <- expression(D[xy])
PlotCV(df = cv[cv$var == "disap", ], "cv-disap", "Disappearances (LRM)", dxy.lab)
PlotCV(cv[cv$var == "kill", ], "cv-kill", "Killings (LRM)", dxy.lab)
PlotCV(cv[cv$var == "polpris", ], "cv-polpris", "Political Imprisonment (LRM)", dxy.lab)
PlotCV(cv[cv$var == "tort", ], "cv-tort", "Torture (LRM)", dxy.lab)
PlotCV(cv.cwar[cv.cwar$var == "disap", ], "cv-cwar-disap", "Disappearances (LRM)", dxy.lab)
PlotCV(cv.cwar[cv.cwar$var == "kill", ], "cv-cwar-kill", "Killings (LRM)", dxy.lab)
PlotCV(cv.cwar[cv.cwar$var == "polpris", ], "cv-cwar-polpris", "Political Imprisonment (LRM)", dxy.lab)
PlotCV(cv.cwar[cv.cwar$var == "tort", ], "cv-cwar-tort", "Torture (LRM)", dxy.lab)
PlotCV(cv.physint, "cv-physint", "Physical Integrity Index (OLS)", "RMSE")
PlotCV(cv.cwar.physint, "cv-cwar-physint", "Physical Integrity Index (OLS)", "RMSE")
PlotCV(cv.pts.ols, "cv-pts-ols", "Political Terror Scale (OLS)", "RMSE")
PlotCV(cv.pts.lrm, "cv-pts-lrm", "Political Terror Scale (LRM)", dxy.lab)
PlotCV(cv.cwar.pts.ols, "cv-cwar-pts-ols", "Political Terror Scale (OLS)", "RMSE")
PlotCV(cv.cwar.pts.lrm, "cv-cwar-pts-lrm", "Political Terror Scale (LRM)", dxy.lab)

ciri.imp <- lapply(ciri.vars, function(x)
                   varimp(cforest(as.formula(paste0(x, " ~ ",
                   paste0(ivars, collapse = " + "))), data = df)))

physint.imp <- varimp(cforest(as.formula(paste0("physint ~ ",
                      paste0(ivars, collapse = " + "))), data = df))

pts.imp <- varimp(cforest(as.formula(paste0("physint ~ ",
                  paste0(ivars, collapse = " + "))), data = df))

PlotImp(ciri.imp[[1]], "Disappearances, Variable Importance", "disap-imp")
PlotImp(ciri.imp[[2]], "Killings, Variable Importance", "kill-imp")
PlotImp(ciri.imp[[3]], "Political Imprisonment, Variable Importance", "polpris-imp")
PlotImp(ciri.imp[[4]], "Torture, Variable Importance", "tort-imp")
PlotImp(physint.imp, "Physical Integrity Index, Variable Importance", "physint-imp")
PlotImp(pts.imp, "Political Terror Scale, Variable Importance", "pts-imp")







