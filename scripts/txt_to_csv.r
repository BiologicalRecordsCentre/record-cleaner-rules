library(tidyverse)

setwd("C:/Users/robhut/OneDrive - UKCEH/Indicia/record-cleaner-rules/rules/Trichoptera Recording Scheme")


### Grid Reference #####
files <- "TRS Caddisfly rules/TRS/tenkm"
fileNames <- list.files(files)

tenkm_rules <- data.frame(matrix(ncol = 5, nrow = 0))

colnames(tenkm_rules) <- c("rule_group",
                         "rule_name",
                         "tvk",
                         "error_message",
                         "value")
tenkm_rules <- tenkm_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "tenkm"
  metadata <- temp %>%
    filter(grepl("=", tenkm, fixed = TRUE)) %>%
    separate(tenkm, into = c("title","value"),sep = "=")%>%
    pivot_wider(names_from = title, values_from = value) %>%
    rename(tvk = DataRecordId,
             error_message = ErrorMsg,
             rule_name = ShortName,
             rule_group = TestType) %>%
    select(rule_group, rule_name, tvk, error_message)
  values <- temp %>%
    filter(!grepl("=", tenkm, fixed = TRUE),
           !grepl("[", tenkm, fixed = TRUE)) %>%
    rename(value = tenkm)

  rule <- bind_cols(metadata, values)
  tenkm_rules <- bind_rows(rule, tenkm_rules)
}

rm(list=ls()[! ls() %in% c("tenkm_rules")])

### Recording Period #####

files <- "TRS Caddisfly rules/TRS/period"
fileNames <- list.files(files)

period_rules <- data.frame(matrix(ncol = 5, nrow = 0))

colnames(period_rules) <- c("rule_group",
                         "rule_name",
                         "tvk",
                         "error_message",
                         "value")
period_rules <- period_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "period"
  rule <- temp %>%
    filter(grepl("=", period, fixed = TRUE)) %>%
    separate(period, into = c("title","value"),sep = "=")%>%
    pivot_wider(names_from = title, values_from = value) %>%
    rename(tvk = Tvk,
           error_message = ErrorMsg,
           rule_name = ShortName,
           rule_group = TestType,
           start_date = StartDate,
           end_date = EndDate) %>%
    mutate(start_date = case_when(nchar(start_date) == 8 ~ paste(gsub("....$", "", start_date),
                                                                 gsub("..$", "",  gsub("^....", "", start_date)),
                                                                 gsub("^......", "", start_date), sep = "-"),
                                  TRUE ~ start_date),
           end_date = case_when(nchar(end_date) == 8 ~ paste(gsub("....$", "", end_date),
                                                                 gsub("..$", "",  gsub("^....", "", end_date)),
                                                                 gsub("^......", "", end_date), sep = "-"),
                                TRUE ~ end_date),
           value = paste(start_date, end_date, sep = " - "),
           value = gsub(" - NA", "", value),
           value = gsub("NA - ", "", value),
           value = gsub(" - $", " to present", value)) %>%
    select(rule_group, rule_name, tvk, error_message, value)

  period_rules <- bind_rows(rule, period_rules)
}

rm(list=ls()[! ls() %in% c("tenkm_rules", "period_rules")])

### Additional Rules #####

files <- "TRS Caddisfly rules/TRS/additional"
fileNames <- list.files(files)

additional_rules <- data.frame(matrix(ncol = 5, nrow = 0))

colnames(additional_rules) <- c("rule_group",
                         "rule_name",
                         "tvk",
                         "error_message",
                         "value")
additional_rules <- additional_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "additional"
  metadata <- temp %>%
    filter(grepl("=", additional, fixed = TRUE)) %>%
    separate(additional, into = c("title","value"),sep = "=")%>%
    pivot_wider(names_from = title, values_from = value) %>%
    rename(error_message = ErrorMsg,
           rule_name = ShortName,
           rule_group = TestType) %>%
    select(rule_group, rule_name, error_message)

  values <- temp %>%
    filter(!grepl("=", additional, fixed = TRUE),
           !grepl("[", additional, fixed = TRUE)) %>%
    separate(additional, into = c("tvk","value_code"),sep = ",")
  value_meaning <- temp %>%
    filter(grepl("=", additional, fixed = TRUE))%>%
    separate(additional, into = c("value_code","value"),sep = "=") %>%
    filter(value_code %in% unique(values$value_code))
  values <- left_join(values, value_meaning, by = "value_code") %>%
    mutate(value = paste(value_code, value, sep = ": ")) %>%
    select(-value_code)
  
  rule <- bind_cols(metadata, values)
  additional_rules <- bind_rows(rule, additional_rules)
}

rm(list=ls()[! ls() %in% c("tenkm_rules", "period_rules", "additional_rules")])

### ID Difficulty #####

files <- "TRS_IDifficulty"

fileNames <- list.files(files)

id_rules <- data.frame(matrix(ncol = 5, nrow = 0))

colnames(id_rules) <- c("rule_group",
                                "rule_name",
                                "tvk",
                                "error_message",
                                "value")
id_rules <- id_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "id"
  metadata <- temp %>%
    filter(grepl("=", id, fixed = TRUE)) %>%
    separate(id, into = c("title","value"),sep = "=")%>%
    pivot_wider(names_from = title, values_from = value) %>%
    rename(rule_group = TestType) %>%
    select(rule_group)
  
  values <- temp %>%
    filter(grepl("=", id, fixed = TRUE),
           !grepl("[", id, fixed = TRUE)) %>%
    separate(id, into = c("tvk","value_code"),sep = "=") %>%
    filter(grepl("^...SYS", tvk))
  value_meaning <- temp %>%
    filter(grepl("=", id, fixed = TRUE))%>%
    separate(id, into = c("value_code","value"),sep = "=") %>%
    filter(nchar(value_code) == 1,
            value_code %in% unique(values$value_code))
  values <- left_join(values, value_meaning, by = "value_code") %>%
    mutate(value = paste(value_code, value, sep = ": ")) %>%
    select(-value_code)
  
  rule <- bind_cols(metadata, values)
  id_rules <- bind_rows(rule, id_rules)
}

rm(list=ls()[! ls() %in% c("tenkm_rules", "period_rules", "additional_rules", "id_rules")])

period_rules <- period_rules %>%
  rename(recording_period = value) %>%
  select(tvk, recording_period)
additional_rules <- additional_rules %>%
  rename(additional_checks_required = value)%>%
  select(tvk, additional_checks_required)
id_rules <- id_rules %>%
  rename(id_difficulty = value)%>%
  select(tvk, id_difficulty)
tenkm_rules <- tenkm_rules %>%
  rename(grid_10km = value) %>%
  select(-rule_group)
all_rules <- full_join(period_rules, additional_rules, by = "tvk")
all_rules <- full_join(all_rules, id_rules, by = "tvk")
rm(list=ls()[! ls() %in% c("tenkm_rules", "all_rules")])
setwd("C:/Users/robhut/OneDrive - UKCEH/Indicia/record-cleaner-rules/rules_as_csv")
uksi <- read.csv("uksi_dictionary.csv") %>%
  select(taxon, preferred_taxon, name_tvk) %>%
  rename(species = taxon,
         preferred_species_name = preferred_taxon,
         tvk = name_tvk)
all_rules <- right_join(uksi, all_rules, by = "tvk")
write.csv(all_rules, "TRS Trichoptera Rules - General.csv")
write.csv(tenkm_rules, "TRS Trichoptera Rules - 10km square.csv")
