invisible(lapply(c("mice", "lattice"), require, character.only = TRUE))

methods <- c(rep("", 3), rep("ri", 5), rep("", 5), "", "", rep("ri", 3),
             "", rep("ri", 3), rep("cart", 7), "", "", "cart",
             "", "", "ri", "cart", "", rep("cart", 4))

mi <- mice(df.imp, m = MI_ITER, method = methods, print = FALSE)
df.mi <- lapply(seq(1, MI_ITER), function(x) complete(mi, x))

png("./figures/mi.png", width = 8, height = 8, units = "in",
    res = 1200, pointsize = 4)
stripplot(mi, polity2 + xrcomp + xropen + xconst + parcomp +
          pop + gdppc + rentspc + execrlc + trade_gdp +
          fdi_net_in + public_trial + fair_trial + final_decision +
          legislative_ck + structad + imfstruct + wbimfstruct +
          hr_law + ainr_lag + aibr_lag + avmdia_lag + hro_shaming_lag ~ .imp,
          scales = "free")
dev.off()
