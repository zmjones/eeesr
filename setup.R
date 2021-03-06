CORES <- 32
CV_FOLD <- 10
CV_ITER <- 1000
MI_ITER <- 5
B_ITER <- 100
PLOT_BORDER <- .1
PANEL_BORDER <- .25
original <- TRUE

df <- read.csv("./data/rep.csv")
df$gdppc <- log(df$gdppc)
df$pop <- log(df$pop)
df$rentspc <- log(df$rentspc + 1)
df$trade_gdp <- log(df$trade_gdp)
df$ingo_uia <- log(df$ingo_uia + 1)
df$disap <- as.ordered(df$disap)
df$kill <- as.ordered(df$kill)
df$tort <- as.ordered(df$tort)
df$polpris <- as.ordered(df$polpris)
df$physint <- as.ordered(df$physint)
df$amnesty <- as.ordered(df$amnesty)
df$wbimfstruct <- as.integer(df$wbimfstruct)
df <- df[!is.na(df$physint) & !is.na(df$amnesty), ]
non_original <- c("terrrev", "laworder", "cim", "CIE", "lagus", "lagun", "hrordinal", "nonhrordinal")
if (original) df <- df[, !(colnames(df) %in% non_original)]

lrm.vars <- c("disap", "kill", "polpris", "tort", "amnesty")
lrm.labs <- c("Disappearances", "Killings", "Political Imprisonment", "Torture", "Political Terror Scale")
ols.vars <- c("physint", "amnesty", "latent")
ols.labs <- c("Physical Integrity Index", "Political Terror Scale", "Dynamic Latent Score")
ciri.vars <- lrm.vars[1:4]
base.spec <- "~ log(gdppc) + log(pop)"
ivars <- colnames(df)[!colnames(df) %in% c("ccode", "year", ciri.vars,
                                           "physint", "amnesty", "gdppc", "pop", "latent", "latent_sd",
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
                 "CCPR Ratifier", "Youth Bulge", "Ter. Revison.", "Rule of Law", "CIM", "CIE",
                 "US Sanction (lag)", "UN Sanction (lag)", "HR Sanctions",
                 "Non-HR Sanctions", "Civil War", "International War", "AI Press (lag)",
                 "AI Background (lag)", "Western Media (lag)", "HRO Shaming (lag)")
if (original) ivar.labels <- ivar.labels[-c(26:33)]
ivar.labels.cwar <- ivar.labels[!(ivar.labels %in% "Civil War")]
