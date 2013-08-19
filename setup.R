set.seed(1987)

CORES <- 8
CV_FOLD <- 10
CV_ITER <- 1000
MI_ITER <- 5
PLOT_BORDER <- .15

pkgs <- c("plyr", "stringr", "lubridate", "ggplot2", "reshape2", "grid",
          "countrycode", "foreign", "rms", "multicore", "party", "mice")
invisible(lapply(pkgs, function(x) if(!is.element(x, installed.packages()[, 1]))
                 install.packages(x, repos = c(CRAN = "http://cran.rstudio.com"))))

df <- read.csv("./data/rep.csv")
df$disap <- as.ordered(df$disap)
df$kill <- as.ordered(df$kill)
df$tort <- as.ordered(df$tort)
df$polpris <- as.ordered(df$polpris)
df$physint <- as.ordered(df$physint)
df$amnesty <- as.ordered(df$amnesty)
df$gdppc <- log(df$gdppc)
df$pop <- log(df$pop)
df.imp <- df[!(is.na(df$amnesty) | is.na(df$physint)), ]
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
                 "AI Press (lag)", "AI Background (lag)", "Western Media (lag)",
                 "HRO Shaming (lag)")
ivar.labels.cwar <- ivar.labels[!(ivar.labels %in% "Civil War")]
