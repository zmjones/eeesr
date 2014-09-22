options(stringsAsFactors = FALSE)
pkgs <- c("dplyr", "countrycode", "foreign", "stringr", "lubridate")
invisible(lapply(pkgs, function(x) if(!is.element(x, installed.packages()[, 1]))
                                       install.packages(x, repos = c(CRAN = "http://cran.rstudio.com"))))
invisible(lapply(pkgs, require, character.only = TRUE))

cat <- read.csv("./data/cat.csv", check.names = FALSE, na.string = "")
cat <- expandPanel(expandColumns(cat), syear = "1981", eyear = "1999")
cat$cat_ratify <- ifelse(cat$ratification == 1 | cat$accession == 1 | cat$succession == 1, 1, 0)
cat$ccode <- countrycode(cat$participant, "country.name", "cown")
cat <- cat[, c(8,2,7)]

cpr <- read.csv("./data/cpr.csv", check.names = FALSE, na.string = "")
cpr <- expandPanel(expandColumns(cpr), syear = "1981", eyear = "1999")
cpr$cpr_ratify <- ifelse(cpr$ratification == 1 | cpr$accession == 1 | cpr$succession == 1, 1, 0)
cpr$ccode <- countrycode(cpr$participant, "country.name", "cown")
cpr <- cpr[, c(8,2,7)]

paradox <- read.delim("./data/paradox_rep.tab")
paradox <- paradox[paradox$year >= 1981, ]
paradox$country[paradox$country == "United Arab Emirat"] <- "United Arab Emirates"
paradox$ccode <- countrycode(paradox$country, "country.name", "cown")
names(paradox) <- tolower(names(paradox))
paradox <- paradox[, -1]
paradox <- paradox[, c(3,1,2)]

polity <- read.csv("./data/polity.csv", na.strings = c("-88", "-77", "-66", "0"))[, c(2,5,11,14:16,18)]
polity <- polity[polity$year >= 1981 & polity$year <= 1999, ]

ciri <- read.csv("./data/ciri_hr.csv", na.strings = c("-999", "-77", "-66"))
names(ciri) <- tolower(names(ciri))
ciri <- ciri[ciri$year <= 1999, ]
names(ciri)[2] <- "ccode"

pts <- read.csv("./data/pts.csv")
pts <- pts[pts$Year <= 1999 & pts$Year >= 1981, c(3,5:6)]
names(pts) <- tolower(names(pts))
names(pts)[1] <- "ccode"

polcon <- read.csv("./data/polcon.csv")[ ,c(2,7,13)]
names(polcon) <- tolower(names(polcon))
polcon <- polcon[polcon$year >= 1981 & polcon$year <= 1999, ]

exgdp <- read.table("./data/exgdp.dat", sep = " ", header = TRUE)[, -c(2,5,7)]
names(exgdp)[1] <- "ccode"
exgdp <- exgdp[exgdp$year >= 1981 & exgdp$year <= 1999, ]

acd <- read.csv("./data/acd.csv")[, c(21,10,13,11:12)]
names(acd) <- c("ccode", "year", "type", "int", "cumint")
acd <- acd[acd$year >= 1981 & acd$year <= 1999, ]
acd$ccode <- as.integer(acd$ccode)

oil <- read.dta("./data/oil_hr.dta")[, c(1,5,129)]
names(oil) <- tolower(names(oil))
oil <- oil[oil$year >= 1981 & oil$year <= 1999, ]
names(oil)[3] <- "rentspc"

dpi <- read.dta("./data/dpi.dta")[, c(1,3,9,15)]
dpi$countryname[dpi$countryname == "UAE"] <- "United Arab Emirates"
dpi$countryname[dpi$countryname == "Cent. Af. Rep."] <- "Central African Republic"
dpi$countryname[dpi$countryname == "PRC"] <- "People's Republic of China"
dpi$countryname[dpi$countryname == "GDR"] <- "German Democratic Republic"
dpi$countryname[dpi$countryname == "Dom. Rep."] <- "Dominican Republic"
dpi$countryname[dpi$countryname == "ROK"] <- "Republic of Korea"
dpi$countryname[dpi$countryname == "P. N. Guinea"] <- "Papua New Guinea"
dpi$countryname[dpi$countryname == "PRK"] <- "People's Republic of Korea"
dpi$countryname[dpi$countryname == "S. Africa"] <- "South Africa"
dpi$ccode <- countrycode(dpi$countryname, "country.name", "cown")
dpi <- dpi[dpi$year >= 1981 & dpi$year <= 1999, -1]
dpi[is.na(dpi$military), ] <- 0 

hill_isq <- read.dta("./data/hill_isq_rep.dta")[, c(3,2,10:11,17)]
names(hill_isq)[1] <- "ccode"
hill_isq <- hill_isq[hill_isq$year >= 1981 & hill_isq$year <= 1999, ]

civ_libs <- read.csv("./data/civ_libs_ick.csv", na.strings = ".")[, c(2:3,12:13)]
names(civ_libs) <- tolower(names(civ_libs))
names(civ_libs)[2:4] <- c("ccode", "public_trial", "fair_trial")
civ_libs <- civ_libs[civ_libs$year >= 1981 & civ_libs$year <= 1999, ]

soe_jud <- read.csv("./data/soe_jud_ick.csv", na.strings = ".")[, c(2:3,6,14)]
names(soe_jud) <- tolower(names(soe_jud))
names(soe_jud)[2:4] <- c("ccode", "final_decision", "legislative_ck")
soe_jud <- soe_jud[soe_jud$year >= 1981 & soe_jud$year <= 1999, ]

a_cbook <- read.csv("./data/a_cbook.csv", row.names = 1)[, c(4:5,32,45,53)]

wb <- read.dta("./data/worldbank.dta")[, c(1:2,8,9)]
names(wb)[1] <- "ccode"
wb <- wb[wb$year >= 1981 & wb$year <= 1999, ]

mitch <- read.dta("./data/mitchell_jpr.dta")[, c(2:3,36,48)]
names(mitch)[2:3] <- c("ccode", "britcol")
mitch <- mitch[mitch$year >= 1981 & mitch$year <= 1999, ]

sb <- read.dta("./data/spilker_bohmelt.dta")[, c(1:3)]
sb <- sb[sb$year >= 1981 & sb$year <= 1999, ]

youth <- read.dta("./data/youth_bulge.dta")[, c(2:3,8)]
youth <- youth[youth$year >= 1981 & youth$year <= 1999, ]
names(youth)[1] <- "ccode"

mdavis <- read.dta("./data/murdie_davis.dta")[, c(1,2,16)]
mdavis <- mdavis[mdavis$year >= 1981 & mdavis$year <= 1999, ]
names(mdavis)[2:3] <- c("ccode", "hro_shaming")

latent <- read.csv("./data/farriss_latent.csv")[, c(1,3,18)]
names(latent) <- c("year", "ccode", "latent")
latent <- latent[latent$year >= 1981 & latent$year <= 1999, ]

sanctions <- read.delim("./data/sanctionsrepdata.tab")[, c(2:3,6:7)]
names(sanctions)[2] <- "ccode"
sanctions <- sanctions[sanctions$year >= 1981 & sanctions$year <= 1999, ]

cie <- read.dta("./data/CINE 2.0.dta")[, c(1:2,16)]
cie <- cie[cie$year >= 1981 & cie$year <= 1999, ]

cim <- read.dta("./data/cim.dta")
names(cim)[1] <- "ccode"
cim <- cim[cim$year >= 1981 & cim$year <= 1999, ]

rol <- read.dta("./data/icrg.dta")
names(rol)[1] <- "ccode"
rol <- rol[rol$year >= 1981 & rol$year <= 1999, ]

tr <- read.dta("./data/Wright2014JPR_replication.dta")[, c(2:3,13)]
tr <- tr[tr$year >= 1981 & tr$year <= 1999, ]

pk <- read.dta("./data/Sanctions_HumanrightsJPR - DPeksen.dta")[, c(1,4,19:23)]
pk <- pk[pk$year >= 1981 & pk$year <= 1999, ]

df <- read.delim("./data/GW.txt")[, -c(2:3)]
df$start <- year(dmy(df$start.date))
df$end <- year(dmy(df$end.date))

df <- apply(df[, -c(2:3)], 1, function(x) {
    year <- seq(x[2], x[3])
    ccode <- rep(x[1], length(years))
    cbind(ccode, year)
})
df <- as.data.frame(do.call("rbind", df))
row.names(df) <- NULL
df <- df[df$year >= 1981 & df$year <= 1999, ]

df <- df %>%
    left_join(paradox) %>%
    left_join(polity) %>%
    left_join(ciri) %>%
    left_join(pts) %>%
    left_join(polcon) %>%
    left_join(exgdp) %>%
    left_join(acd) %>%
    left_join(oil) %>%
    left_join(dpi) %>%
    left_join(hill_isq) %>%
    left_join(wb) %>%
    left_join(civ_libs) %>%
    left_join(soe_jud) %>%
    left_join(a_cbook) %>%
    left_join(mitch) %>%
    left_join(sb) %>%
    left_join(cat) %>%
    left_join(cpr) %>%
    left_join(youth) %>%
    left_join(mdavis) %>%
    left_join(latent) %>%
    left_join(tr) %>%
    left_join(rol) %>%
    left_join(cim) %>%
    left_join(cie) %>%
    left_join(sanctions) %>%
    left_join(pk)

df$cat_ratify[is.na(df$cat_ratify)] <- 0
df$cpr_ratify[is.na(df$cpr_ratify)] <- 0
df$type[is.na(df$type)] <- 0
df$int[is.na(df$int)] <- 0
df$cumint[is.na(df$cumint)] <- 0
df$military[is.na(df$military)] <- 0
df$military[df$military == -999] <- NA
df$cwar <- ifelse((df$type == 3 | df$type == 4) & df$cumint == 1, 1, 0)
df$iwar <- ifelse(df$type == 2 & df$cumint == 1, 1, 0)
df$execrlc[df$execrlc == -999] <- NA
df$cim <- df$cim * 100

df <- df[!duplicated(df), ] ## don't know where these 205 come from

last_year <- df %>%
    mutate(year = year + 1,
           aibr_lag = aibr,
           hro_shaming_lag = hro_shaming,
           physint_lag = physint,
           amnesty_lag = amnesty,
           disap_lag = disap,
           kill_lag = kill,
           polpris_lag = polpris,
           tort_lag = tort,
           latent_lag = latent)
last_year <- last_year[, c(1:2,58:66)]
df <- df %>% left_join(last_year)

drop <- c("j", "type", "int", "cumint", "ainr", "aibr", "avmdia", "hro_shaming")
df <- df[, !(colnames(df) %in% drop)]
write.csv(df, "./data/rep.csv", row.names = FALSE)
