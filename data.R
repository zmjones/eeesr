options(stringsAsFactors = FALSE)
pkgs <- c("plyr", "dplyr", "countrycode", "foreign", "stringr", "lubridate", "assertthat")
invisible(lapply(pkgs, library, character.only = TRUE, quietly = TRUE))

expand_years <- function(df) {
    year <- apply(df, 1, function(x) seq(x[2], x[3]))
    unit <- vector("list", nrow(df))
    for (i in 1:nrow(df))
        unit[[i]] <- cbind(df[rep(i, length(year[[i]])), ], year[[i]])
    df <- do.call("rbind", unit)
    colnames(df)[grepl("year", colnames(df))] <- "year"
    row.names(df) <- NULL
    df[, -c(2,3)]
}

dupes <- function(df) df[which(duplicated(df[, c("ccode", "year")]) |
                                   duplicated(df[, c("ccode", "year")], fromLast = TRUE)), ]

df <- read.csv("./data/cow.csv")[, c(2,4,7)]
df <- expand_years(df)
df <- df[df$year >= 1981 & df$year <= 1999, ]
assert_that(!anyDuplicated(df))

## read source data
## cat <- read.csv("./data/cat.csv", check.names = FALSE, na.string = "")
## cat <- expandPanel(expandColumns(cat), syear = "1981", eyear = "1999")
## cat$cat_ratify <- ifelse(cat$ratification == 1 | cat$accession == 1 | cat$succession == 1, 1, 0)
## write.csv(cat, "./data/cat_expanded.csv", row.names = FALSE)
cat <- read.csv("./data/cat_expanded.csv")
cat <- cat[!(cat$participant %in% c("Serbia", "State of Palestine")), ]
cat$ccode <- countrycode(cat$participant, "country.name", "cown", TRUE)
cat <- cat[!is.na(cat$ccode), c(8,2,7)]
assert_that(!anyDuplicated(cat[, c("ccode", "year")]))
miss <- anti_join(cat, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss$from <- "cat"

## cpr <- read.csv("./data/cpr.csv", check.names = FALSE, na.string = "")
## cpr <- expandPanel(expandColumns(cpr), syear = "1981", eyear = "1999")
## write.csv(cpr, "./data/cpr_expanded.csv", row.names = FALSE)
cpr <- read.csv("./data/cpr_expanded.csv")
cpr <- cpr[!(cpr$participant %in% c("Serbia", "State of Palestine")), ]
cpr$cpr_ratify <- ifelse(cpr$ratification == 1 | cpr$accession == 1 | cpr$succession == 1, 1, 0)
cpr$ccode <- countrycode(cpr$participant, "country.name", "cown", TRUE)
cpr$ccode[cpr$participant == "Democratic People's Republic of Korea"] <- 731
cpr$ccode[cpr$participant == "Republic of Korea"] <- 732
cpr <- cpr[, c(8,2,7)]
assert_that(!anyDuplicated(cpr[, c("ccode", "year")]))
miss_add <- anti_join(cpr, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "cpr"
miss <- rbind(miss, miss_add)

paradox <- read.delim("./data/paradox_rep.tab")
paradox <- paradox[paradox$year >= 1981, ]
paradox$country[paradox$country == "United Arab Emirat"] <- "United Arab Emirates"
paradox <- paradox[paradox$country != "Slovak Republic", ] ## not independent and matches with slovakia
paradox$ccode <- countrycode(paradox$country, "country.name", "cown", TRUE)
names(paradox) <- tolower(names(paradox))
paradox$ccode[paradox$country == "Germany East"] <- 265
paradox$ccode[paradox$country == "Yemen, Rep."] <- 678
paradox$ccode[paradox$country == "Yemen South"] <- 680
paradox <- paradox[!is.na(paradox$ccode), 2:4]
assert_that(!anyDuplicated(paradox[, c("ccode", "year")]))
miss_add <- anti_join(paradox, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <-  "paradox"
miss <- rbind(miss, miss_add)

polity <- read.csv("./data/polity.csv", na.strings = c("-88", "-77", "-66", "0"))[, c(2,5,11,14:16,18)]
polity <- polity[polity$year >= 1981 & polity$year <= 1999, ]
assert_that(!anyDuplicated(polity[, c("ccode", "year")]))
miss_add <- anti_join(polity, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "polity"
miss <- rbind(miss, miss_add)

ciri <- read.csv("./data/ciri_hr.csv", na.strings = c("-999", "-77", "-66"))
names(ciri) <- tolower(names(ciri))
ciri <- unique(ciri[ciri$year <= 1999 & !is.na(ciri$cow), ])
names(ciri)[2] <- "ccode"
ciri <- ciri[!apply(ciri, 1, function(x) all(is.na(x[3:8]))), ] ## some duplicates with all missingness
assert_that(!anyDuplicated(ciri[, c("ccode", "year")]))
miss_add <- anti_join(ciri, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "ciri"
miss <- rbind(miss, miss_add)

pts <- read.csv("./data/pts.csv")
pts <- pts[pts$Year <= 1999 & pts$Year >= 1981 & !is.na(pts$COWnumeric), c(3,5:6)]
## unique(pts$Country[is.na(pts$COWnumeric)])
names(pts) <- tolower(names(pts))
names(pts)[1] <- "ccode"
assert_that(!anyDuplicated(pts[, c("ccode", "year")]))
miss_add <- anti_join(pts, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "pts"
miss <- rbind(miss, miss_add)

polcon <- read.csv("./data/polcon.csv")[ ,c(2,7,13)]
names(polcon) <- tolower(names(polcon))
polcon <- polcon[polcon$year >= 1981 & polcon$year <= 1999, ]
assert_that(!anyDuplicated(polcon[, c("ccode", "year")]))
miss_add <- anti_join(polcon, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "polcon"
miss <- rbind(miss, miss_add)

exgdp <- read.table("./data/exgdp.dat", sep = " ", header = TRUE)[, -c(2,5,7)]
names(exgdp)[1] <- "ccode"
exgdp <- exgdp[exgdp$year >= 1981 & exgdp$year <= 1999, ]
assert_that(!anyDuplicated(exgdp[, c("ccode", "year")]))
miss_add <- anti_join(exgdp, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "exgdp"
miss <- rbind(miss, miss_add)

acd <- read.csv("./data/acd.csv")[, c(3,21,10,13,11:12)]
names(acd) <- c("cname", "ccode", "year", "type", "int", "cumint")
acd <- acd[acd$year >= 1981 & acd$year <= 1999, ]
acd$ccode <- as.integer(acd$ccode)
acd <- na.omit(unique(acd))
write.csv(acd[duplicated(acd[, c("ccode", "year")]), ], "./data/acd_dropped.csv", row.names = FALSE)
acd <- acd[!duplicated(acd[, c("ccode", "year")]), ] ## selects the first observation if there are multiple
acd <- acd[, -1]
assert_that(!anyDuplicated(acd[, c("ccode", "year")]))
miss_add <- anti_join(acd, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "acd"
miss <- rbind(miss, miss_add)

oil <- read.dta("./data/oil_hr.dta")[, c(1,5,129)]
names(oil) <- tolower(names(oil))
oil <- oil[oil$year >= 1981 & oil$year <= 1999 & !is.na(oil$ccode), ]
names(oil)[3] <- "rentspc"
assert_that(!anyDuplicated(oil[, c("ccode", "year")]))
miss_add <- anti_join(oil, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "oil"
miss <- rbind(miss, miss_add)

dpi <- read.dta("./data/dpi.dta")[, c(1,3,9,15)]
dpi <- dpi[!(dpi$countryname %in% c("Turk Cyprus")), ]
dpi <- dpi[dpi$year >= 1981 & dpi$year <= 1999, ]
dpi$ccode <- countrycode(dpi$countryname, "country.name", "cown", TRUE)
dpi$ccode[dpi$countryname == "UAE"] <- 696
dpi$ccode[dpi$countryname == "GDR"] <- 265
dpi$ccode[dpi$countryname == "PRK"] <- 731
dpi$ccode[dpi$countryname == "ROK"] <- 732
dpi$countryname <- NULL
dpi$military[is.na(dpi$military)] <- 0
assert_that(!anyDuplicated(dpi[, c("ccode", "year")]))
miss_add <- anti_join(dpi, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "dpi"
miss <- rbind(miss, miss_add)

hill_isq <- read.dta("./data/hill_isq_rep.dta")[, c(3,2,10:11,17)]
names(hill_isq)[1] <- "ccode"
hill_isq <- hill_isq[hill_isq$year >= 1981 & hill_isq$year <= 1999, ]
assert_that(!anyDuplicated(hill_isq[, c("ccode", "year")]))
miss_add <- anti_join(hill_isq, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "hill_isq"
miss <- rbind(miss, miss_add)

civ_libs <- read.csv("./data/civ_libs_ick.csv", na.strings = ".")[, c(2:3,12:13)]
names(civ_libs) <- tolower(names(civ_libs))
names(civ_libs)[2:4] <- c("ccode", "public_trial", "fair_trial")
civ_libs <- civ_libs[civ_libs$year >= 1981 & civ_libs$year <= 1999, ]
assert_that(!anyDuplicated(civ_libs[, c("ccode", "year")]))
miss_add <- anti_join(civ_libs, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "civ_libs"
miss <- rbind(miss, miss_add)

soe_jud <- read.csv("./data/soe_jud_ick.csv", na.strings = ".")[, c(2:3,6,14)]
names(soe_jud) <- tolower(names(soe_jud))
names(soe_jud)[2:4] <- c("ccode", "final_decision", "legislative_ck")
soe_jud <- soe_jud[soe_jud$year >= 1981 & soe_jud$year <= 1999, ]
assert_that(!anyDuplicated(soe_jud[, c("ccode", "year")]))
miss_add <- anti_join(soe_jud, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "soe_jud"
miss <- rbind(miss, miss_add)

a_cbook <- read.csv("./data/a_cbook.csv", row.names = 1)[, c(4:5,32,45,53)]
a_cbook <- unique(a_cbook)
assert_that(!anyDuplicated(a_cbook[, c("ccode", "year")]))
miss_add <- anti_join(a_cbook, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "a_cbook"
miss <- rbind(miss, miss_add)

wb <- read.dta("./data/worldbank.dta")[, c(1:2,8,9)]
names(wb)[1] <- "ccode"
wb <- wb[wb$year >= 1981 & wb$year <= 1999, ]
assert_that(!anyDuplicated(wb[, c("ccode", "year")]))
miss_add <- anti_join(wb, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "wb"
miss <- rbind(miss, miss_add)

mitch <- read.dta("./data/mitchell_jpr.dta")[, c(2:3,36,48)]
names(mitch)[2:3] <- c("ccode", "britcol")
mitch <- mitch[mitch$year >= 1981 & mitch$year <= 1999, ]
assert_that(!anyDuplicated(mitch[, c("ccode", "year")]))
miss_add <- anti_join(mitch, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "mitch"
miss <- rbind(miss, miss_add)

sb <- read.dta("./data/spilker_bohmelt.dta")[, c(1:3)]
sb <- sb[sb$year >= 1981 & sb$year <= 1999, ]
assert_that(!anyDuplicated(sb[, c("ccode", "year")]))
miss_add <- anti_join(sb, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "sb"
miss <- rbind(miss, miss_add)

youth <- read.dta("./data/youth_bulge.dta")[, c(2:3,8)]
youth <- youth[youth$year >= 1981 & youth$year <= 1999, ]
names(youth)[1] <- "ccode"
assert_that(!anyDuplicated(youth[, c("ccode", "year")]))
miss_add <- anti_join(youth, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "youth"
miss <- rbind(miss, miss_add)

mdavis <- read.dta("./data/murdie_davis.dta")[, c(1,2,16)]
mdavis <- mdavis[mdavis$year >= 1981 & mdavis$year <= 1999, ]
names(mdavis)[2:3] <- c("ccode", "hro_shaming")
assert_that(!anyDuplicated(mdavis[, c("ccode", "year")]))
miss_add <- anti_join(mdavis, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "mdavis"
miss <- rbind(miss, miss_add)

latent <- read.csv("./data/farriss_latent.csv")[, c(1,3,18:19)]
names(latent) <- c("year", "ccode", "latent", "latent_sd")
latent <- latent[latent$year >= 1981 & latent$year <= 1999, ]
assert_that(!anyDuplicated(latent[, c("ccode", "year")]))
miss_add <- anti_join(latent, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "latent"
miss <- rbind(miss, miss_add)

sanctions <- read.delim("./data/sanctionsrepdata.tab")[, c(2:3,6:7)]
names(sanctions)[2] <- "ccode"
sanctions <- sanctions[sanctions$year >= 1981 & sanctions$year <= 1999, ]
assert_that(!anyDuplicated(sanctions[, c("ccode", "year")]))
miss_add <- anti_join(sanctions, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "sanctions"
miss <- rbind(miss, miss_add)

cie <- read.dta("./data/CINE 2.0.dta")[, c(1:2,16)]
cie <- cie[cie$year >= 1981 & cie$year <= 1999, ]
assert_that(!anyDuplicated(cie[, c("ccode", "year")]))
miss_add <- anti_join(cie, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "cie"
miss <- rbind(miss, miss_add)

cim <- read.dta("./data/cim.dta")
names(cim)[1] <- "ccode"
cim <- cim[cim$year >= 1981 & cim$year <= 1999, ]
assert_that(!anyDuplicated(cim[, c("ccode", "year")]))
miss_add <- anti_join(cim, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "cim"
miss <- rbind(miss, miss_add)

rol <- read.dta("./data/icrg.dta")
names(rol)[1] <- "ccode"
rol <- rol[rol$year >= 1981 & rol$year <= 1999, ]
assert_that(!anyDuplicated(rol[, c("ccode", "year")]))
## miss_add <- anti_join(rol, df, by = c("ccode", "year"))[, c("ccode", "year")]
## miss_add$from <- "rol"
## miss <- rbind(miss, miss_add)

tr <- read.dta("./data/Wright2014JPR_replication.dta")[, c(2:3,13)]
tr <- tr[tr$year >= 1981 & tr$year <= 1999, ]
assert_that(!anyDuplicated(tr[, c("ccode", "year")]))
miss_add <- anti_join(tr, df, by = c("ccode", "year"))[, c("ccode", "year")]
miss_add$from <- "tr"
miss <- rbind(miss, miss_add)

pk <- read.dta("./data/Sanctions_HumanrightsJPR - DPeksen.dta")[, c(1,4,20,21)]
pk <- pk[pk$year >= 1981 & pk$year <= 1999, ]
assert_that(!anyDuplicated(pk[, c("ccode", "year")]))
## miss_add <- anti_join(pk, df, by = c("ccode", "year"))[, c("ccode", "year")]
## miss_add$from <- "pk"
## miss <- rbind(miss, miss_add)

miss <- unique(miss)
miss <- miss %>% group_by(ccode, year) %>%
    summarize(from = paste(from, collapse = ","))
miss$cname <- countrycode(miss$ccode, "cown", "country.name", TRUE)
write.csv(miss, "data/not_matched.csv", row.names = FALSE)

## merge source data together
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

assert_that(!anyDuplicated(df))

## lag some of the variables by one year
last_year <- df %>%
    mutate(year = year + 1,
           aibr_lag = aibr,
           ainr_lag = ainr,
           avmdia_lag = avmdia,
           hro_shaming_lag = hro_shaming,
           physint_lag = physint,
           amnesty_lag = amnesty,
           disap_lag = disap,
           kill_lag = kill,
           polpris_lag = polpris,
           tort_lag = tort,
           latent_lag = latent)
last_year <- last_year[, c(1:2, which(grepl("_lag", colnames(last_year))))]
df <- df %>% left_join(last_year)

## drop unused variables
drop <- c("j", "type", "int", "cumint", "ainr", "aibr", "avmdia", "hro_shaming")
df <- df[, !(colnames(df) %in% drop)]

write.csv(df, "./data/rep.csv", row.names = FALSE)
