rm(list = ls())

source("functions.R")

cat <- read.csv("./data/cat.csv")[, c(1:2,6)]
cpr <- read.csv("./data/cpr.csv")[, c(1:2,6)]
cat$ccode <- countrycode(cat$participant, "country.name", "cown") #serbia is getting dropped here
cpr$ccode <- countrycode(cpr$participant, "country.name", "cown")
names(cat)[3] <- "cat_ratify"
names(cpr)[3] <- "cpr_ratify"
cat$participant <- NULL
cpr$participant <- NULL

paradox <- read.delim("./data/paradox_rep.tab")
paradox <- paradox[paradox$year >= 1981, ]

paradox$country[paradox$country == "United Arab Emirat"] = "United Arab Emirates"
paradox$ccode <- countrycode(paradox$country, "country.name", "cown") #no mismatches from 'warn'
names(paradox) <- tolower(names(paradox))
paradox <- paradox[, -1]

polity <- read.csv("./data/polity.csv", na.strings = c("-88", "-77", "-66", "0"))[, c(2,5,11,14:16,18)]
polity <- na.omit(polity[polity$year >= 1981 & polity$year <= 1999, ])

ciri <- read.csv("./data/ciri_hr.csv", na.strings = c("-999", "-77", "-66"))
names(ciri) <- tolower(names(ciri))
ciri <- na.omit(ciri[ciri$year <= 1999, ])
names(ciri)[2] <- "ccode"

load( "./data/pts.RData")
pts <- na.omit(PTS[PTS$Year <= 1999 & PTS$Year >= 1981, c(3,5:6)])
names(pts) <- tolower(names(pts))
names(pts)[1] <- "ccode"
rm(PTS)

polcon <- read.csv("./data/polcon.csv")[ ,c(2,7,13)]
names(polcon) <- tolower(names(polcon))
polcon <- na.omit(polcon[polcon$year >= 1981 & polcon$year <= 1999, ])

exgdp <- read.table("./data/exgdp.dat", sep = " ", header = TRUE)[, -c(2,5,7)]
names(exgdp)[1] <- "ccode"
exgdp <- na.omit(exgdp[exgdp$year >= 1981 & exgdp$year <= 1999, ])

acd <- read.csv("./data/acd.csv")[, c(21,10,13,11:12)]
names(acd) <- c("ccode", "year", "type", "int", "cumint")
acd <- na.omit(acd[acd$year >= 1981 & acd$year <= 1999, ])

#what variables do we need from this?
#md <- read.dta("./data/murdie_davis.dta")[, c(1:2,16,21,152)]
#md <- na.omit(md[md$year >= 1981 & md$year <= 1999, ])
#names(md) <- c("year", "ccode", "md_gcnc", "md_sec", "md_ln_fill")

oil <- read.dta("./data/oil_hr.dta")[, c(1,5,129)]
names(oil) <- tolower(names(oil))
oil <- na.omit(oil[oil$year >= 1981 & oil$year <= 1999, ])
names(oil)[3] <- "rentspc"

dpi <- read.dta("./data/dpi.dta")[, c(1,3,9,15)]
dpi$countryname[dpi$countryname == "UAE"] = "United Arab Emirates"
dpi$countryname[dpi$countryname == "Cent. Af. Rep."] = "Central African Republic"
dpi$countryname[dpi$countryname == "PRC"] = "People's Republic of China"
dpi$countryname[dpi$countryname == "GDR"] = "German Democratic Republic"
dpi$countryname[dpi$countryname == "Dom. Rep."] = "Dominican Republic"
dpi$countryname[dpi$countryname == "ROK"] = "Republic of Korea"
dpi$countryname[dpi$countryname == "P. N. Guinea"] = "Papua New Guinea"
dpi$countryname[dpi$countryname == "PRK"] = "People's Republic of Korea"
dpi$countryname[dpi$countryname == "S. Africa"] = "South Africa"
dpi$ccode <- countrycode(dpi$countryname, "country.name", "cown")
dpi <- na.omit(dpi[dpi$year >= 1981 & dpi$year <= 1999, -1])
dpi[is.na(dpi$military), ] = 0 #there are 9 NAs, recoding appropriate?

hill_isq <- read.dta("./data/hill_isq_rep.dta")[, c(3,2,10:11,17)]
names(hill_isq)[1] <- "ccode"
hill_isq <- na.omit(hill_isq[hill_isq$year >= 1981 & hill_isq$year <= 1999, ])

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

df <- join(paradox, polity, type = "left")
df <- join(df, ciri, type = "left")
df <- join(df, pts, type = "left")
df <- join(df, polcon, type = "left")
df <- join(df, exgdp, type = "left")
df <- join(df, acd, type = "left")
#df <- join(df, md, type = "left")
df <- join(df, oil, type = "left")
df <- join(df, dpi, type = "left")
df <- join(df, hill_isq, type = "left")
df <- join(df, wb, type = "left")
df <- join(df, civ_libs, type = "left")
df <- join(df, soe_jud, type = "left")
df <- join(df, a_cbook, type = "left")
df <- join(df, mitch, type = "left")
df <- join(df, sb, type = "left")
df <- join(df, cat, type = "left")
df <- join(df, cpr, type = "left")
df <- join(df, youth, type = "left")

df$cat_ratify[is.na(df$cat_ratify)] <- 0
df$cpr_ratify[is.na(df$cpr_ratify)] <- 0
df$type[is.na(df$type)] <- 0
df$int[is.na(df$int)] <- 0
df$cumint[is.na(df$cumint)] <- 0
df$military[is.na(df$military)] <- 0
df$ingo_uia <- log(df$ingo_uia + 1)
df$cwar <- ifelse((df$type == 3 | df$type == 4) & df$cumint == 1, 1, 0)
df$iwar <- ifelse(df$type == 2 & df$cumint == 1, 1, 0)
df$rentspc <- log(df$rentspc + 1)
df$execrlc[df$exerclc == -999] <- NA

rm(paradox, polity, ciri, polcon, pts, exgdp, acd, oil, dpi,
   hill_isq, civ_libs, soe_jud, wb, a_cbook, mitch, sb, cat, cpr, youth)

df <- aggregate(df, by = list(df$ccode, df$year), max)[, -c(1:2)]

df <- ddply(df, .(ccode), transform, ainr_lag = c(NA, ainr[-length(ainr)]),
            aibr_lag = c(NA, aibr[-length(aibr)]), avmdia_lag = c(NA, avmdia[-length(avmdia)]))

#nrow(df) == 3443
#nrow(df[!(is.na(df$physint)), ]) == 2625 
df <- df[!is.na(df$physint), -c(16,19:21,25:27)]

write.csv(df, "./data/rep.csv", row.names = FALSE)
