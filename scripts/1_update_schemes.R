rule_sets <- list.dirs("rules_as_csv")
rule_sets <- rule_sets[str_count(rule_sets, "/") ==2]
rule_sets <- gsub("rules_as_csv/", "", rule_sets)
rule_sets <- data.frame(dirs = rule_sets)
rule_sets <- rule_sets %>%
  separate_wider_delim(dirs, "/", names = c("scheme", "rule_group"))


schemes  <- split(rule_sets , seq(nrow(rule_sets )))
names(schemes) <- paste(rule_sets$scheme, rule_sets$rule_group, sep = "/")
rm(rule_sets)
saveRDS(schemes, file = "scripts/schemes.RData")
rm(schemes)