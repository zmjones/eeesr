require(party)
options(stringsAsFactors = FALSE)

df <- read.csv("./data/rep.csv")[, c(12,35,37)]
df <- df[!is.na(df$polpris), ]
df <- df[sample(row.names(df), 500), ]
df$polpris <- as.ordered(df$polpris)
df$cwar <- factor(df$cwar, labels = c("no civil war", "civil war"))
fit <- ctree(polpris ~ cwar + ythblgap, data = df)

png("./figures/tree.png", width = 12, height = 7, units = "in", res = 1600)
plot(fit, inner_panel = node_barplot(fit, beside = FALSE),
     terminal_panel = node_barplot(fit, beside = FALSE))
dev.off()
