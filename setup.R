CORES <- 7
CV_FOLD <- 10
CV_ITER <- 1000
MI_ITER <- 5
B_ITER <- 100
PLOT_BORDER <- .1
PANEL_BORDER <- .25

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
df <- df[!is.na(df$physint) & !is.na(df$amnesty), ]

lrm.vars <- c("disap", "kill", "polpris", "tort", "amnesty")
lrm.labs <- c("Disappearances", "Killings", "Political Imprisonment", "Torture", "Political Terror Scale")
ols.vars <- c("physint", "amnesty", "latent")
ols.labs <- c("Physical Integrity Index", "Political Terror Scale", "Dynamic Latent Score")
ciri.vars <- lrm.vars[1:4]
base.spec <- "~ log(gdppc) + log(pop)"
ivars <- colnames(df)[!colnames(df) %in% c("ccode", "year", ciri.vars,
                                           "physint", "amnesty", "gdppc", "pop", "latent",
                                           "physint_lag", "amnesty_lag", "disap_lag",
                                           "kill_lag", "polpris_lag", "tort_lag", "latent_lag")]
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
