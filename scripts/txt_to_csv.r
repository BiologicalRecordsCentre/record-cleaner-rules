library(tidyverse)

library(RODBC)

org <- "BC"
scheme <- "BC"

warehouse <- odbcConnect("PostgreSQL35W")

uksi <- sqlQuery(warehouse, 
                 
                 "select distinct cttl.taxon, cttl.search_code as tvk
from indicia.cache_taxa_taxon_lists cttl
where taxon_list_id=15"
                 
)

close(warehouse)

file_location <- "C:/Users/robhut/OneDrive - UKCEH/Indicia/record-cleaner-rules"

if(dir.exists(paste(file_location, "rules_as_csv", org, scheme, sep = "/" )) == FALSE) {
  
  dir.create(paste(file_location, "rules_as_csv", org, scheme, sep = "/" ), recursive = TRUE)
  
}

setwd(paste(file_location, "rules", sep = "/"))

### Grid Reference #####
files <- paste(org, scheme, "tenkm", sep = "/") 
fileNames <- list.files(files)

if(length(fileNames) != 0) {
  
  tenkm_rules <- data.frame(matrix(ncol = 1, nrow = 0))
  
  colnames(tenkm_rules) <- c("tvk")
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
      rename(tvk = DataRecordId) %>%
      select( tvk)
    values <- temp %>%
      filter(!grepl("=", tenkm, fixed = TRUE),
             !grepl("[", tenkm, fixed = TRUE)) %>%
      rename(value = tenkm)%>%
      mutate(km100 = gsub("..$", "", value),
             km10 = case_when(nchar(value) == 4 ~ gsub("^..", "", value),
                              TRUE ~ gsub("^.", "", value))) %>%
      select(-value) %>%
      group_by(km100) %>%
      arrange(km10) %>%
      mutate(row = paste("n", row_number(), sep = "")) %>%
      pivot_wider(names_from = row, values_from = km10) %>%
      unite(km10, -km100, sep = " ", na.rm = TRUE) %>%
      mutate(coord_system = case_when(nchar(km100) == 1 ~ "OSNI",
                                      str_detect(km100, "^W") ~ "CI",
                                      TRUE ~ "OSGB")) %>%
      arrange(coord_system, km100)
    rule <- bind_cols(metadata, values)
    tenkm_rules <- bind_rows(rule, tenkm_rules)
  
  }
  
  tenkm_rules <- right_join(uksi, tenkm_rules, by = "tvk")
  
} else {
  
  tenkm_rules <- data.frame(matrix(ncol = 5, nrow = 0))
  
  colnames(tenkm_rules) <- c("taxon",
                             "tvk",
                             "km100",
                             "km10",
                             "coord_system")
  
}

write.csv(tenkm_rules, paste(file_location, "/rules_as_csv/", org, "/", scheme, "/tenkm.csv", sep = ""), na = "", row.names = FALSE)

### Recording Period #####
files <- paste(org, scheme, "period", sep = "/") 
fileNames <- list.files(files)
if(length(fileNames) != 0) {
  period_rules <- data.frame(matrix(ncol = 1, nrow = 0))

  colnames(period_rules) <- c("tvk")
  period_rules <- period_rules %>%
    mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "period"
  rule <- temp %>%
    filter(grepl("=", period, useBytes = TRUE)) %>%
    separate_wider_delim(period, delim= "=", names = c("title","value")) %>%
    filter(grepl("tvk|start|end", title, ignore.case = TRUE)) %>%
    mutate(value = gsub("^ ", "", value)) %>%
    pivot_wider(names_from = title, values_from = value) %>%
    janitor::clean_names() %>%
    mutate(start_day = case_when(nchar(start_date) == 8 ~  gsub("^......", "", start_date)),
           start_month = case_when(nchar(start_date) == 8 ~ gsub("..$", "",  gsub("^....", "", start_date))),
           start_year = case_when(nchar(start_date) == 8 ~ gsub("....$", "", start_date)))%>%
    mutate(end_day = case_when(nchar(end_date) == 8 ~ gsub("^......", "", end_date)),
           end_month = case_when(nchar(end_date) == 8 ~ gsub("..$", "",  gsub("^....", "", end_date))),
           end_year = case_when(nchar(end_date) == 8 ~ gsub("....$", "", end_date))) %>%
    select(tvk, start_day, start_month, start_year, end_day, end_month, end_year)

  period_rules <- bind_rows(rule, period_rules)
}
  
  period_rules <- right_join(uksi, period_rules, by = "tvk")
  
} else {
  
  period_rules <- data.frame(matrix(ncol = 8, nrow = 0))
  
  colnames(period_rules) <- c("taxon",
                              "tvk",
                              "start_day",
                              "start_month",
                              "start_year",
                              "end_day",
                              "end_month",
                              "end_year")
  
}


write.csv(period_rules, paste(file_location, "/rules_as_csv/", org, "/", scheme, "/period.csv", sep = ""), na = "", row.names = FALSE)

### Period Within Year #####

files_s <- paste(org, scheme, "seasonalperiod", sep = "/") 
fileNames_s <- list.files(files_s)

files_f <- paste(org, scheme, "flightperiod", sep = "/") 
fileNames_f <- list.files(files_f)

if(length(fileNames_s) > length(fileNames_f)) {
  
  fileNames <- fileNames_s
  files <- files_s
  
} else { 
  
  fileNames <- fileNames_f
  files <- files_f }


if(length(fileNames) != 0) {
s_period_rules <- data.frame(matrix(ncol = 1, nrow = 0))

colnames(s_period_rules) <- c("tvk")
wy_period_rules <- s_period_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "period"
  rule <- temp %>%
    filter(grepl("=", period, useBytes = TRUE)) %>%
    separate_wider_delim(period, delim= "=", names = c("title","value")) %>%
    filter(grepl("tvk|start|end", title, ignore.case = TRUE)) %>%
    mutate(value = gsub("^ ", "", value)) %>%
    pivot_wider(names_from = title, values_from = value) %>%
    janitor::clean_names() %>%
    mutate(start_month = case_when(nchar(start_date) == 4 ~ gsub("..$", "", start_date)),
           start_day = case_when(nchar(start_date) == 4 ~ gsub("^..", "", start_date)),
           end_month = case_when(nchar(end_date) == 4 ~ gsub("..$", "", end_date)),
           end_day = case_when(nchar(end_date) == 4 ~ gsub("^..", "", end_date))) %>%
    select(tvk, start_day, start_month, end_day, end_month)
  
  wy_period_rules <- bind_rows(rule, wy_period_rules)
}

wy_period_rules <- right_join(uksi, wy_period_rules, by = "tvk") %>%
  mutate(stage = "Adult")

} else {
  
  s_period_rules <- data.frame(matrix(ncol = 7, nrow = 0))
  
  colnames(s_period_rules) <- c("taxon",
                                "tvk",
                                "start_day",
                                "start_month",
                                "end_day",
                                "end_month",
                                "stage")
  wy_period_rules <- s_period_rules %>%
    mutate_all(as.character)
  
}


write.csv(wy_period_rules, paste(file_location, "/rules_as_csv/", org, "/", scheme, "/period_within_year.csv", sep = ""), na = "", row.names = FALSE)


### Additional Rules #####

files <- paste(org, scheme, "additional", sep = "/") 
fileNames <- list.files(files)
if(length(fileNames) != 0) {
additional_rules <- data.frame(matrix(ncol = 1, nrow = 0))

colnames(additional_rules) <- c("tvk")
additional_rules <- additional_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(files, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "additional"

  values <- temp %>%
    filter(!grepl("=", additional, fixed = TRUE),
           !grepl("[", additional, fixed = TRUE)) %>%
    separate(additional, into = c("tvk","value_code"),sep = ",") 
  
  additional_rules <- bind_rows(values, additional_rules)
}

additional_rules <- right_join(uksi, additional_rules, by = "tvk") 

} else {
  
  additional_rules <- data.frame(matrix(ncol = 3, nrow = 0))
  
  colnames(additional_rules) <- c("taxon",
                                  "tvk",
                                  "value_code")
  additional_rules <- additional_rules %>%
    mutate_all(as.character)
  
}

write.csv(additional_rules, paste(file_location, "/rules_as_csv/", org, "/", scheme, "/additional.csv", sep = ""), na = "", row.names = FALSE)


### ID Difficulty #####

fileNames <- list.files(org, pattern = paste(scheme, ".+", "txt$", sep = "")) 
if(length(fileNames) != 0) {
id_rules <- data.frame(matrix(ncol = 1, nrow = 0))

colnames(id_rules) <- c("tvk")
id_rules <- id_rules %>%
  mutate_all(as.character)

for(i in 1:length(fileNames)) {
  
  file_name <- fileNames[i]
  temp <- read.delim(paste(org, file_name, sep = "/"), stringsAsFactors = FALSE)
  colnames(temp) <- "id"
  
  values <- temp %>%
    filter(grepl("=", id, fixed = TRUE),
           !grepl("[", id, fixed = TRUE)) %>%
    separate(id, into = c("tvk","value_code"),sep = "=") %>%
    filter(grepl("^...SYS", tvk))
  
  id_rules <- bind_rows(values, id_rules)
}

id_rules <- right_join(uksi, id_rules, by = "tvk") 


} else {
  
  id_rules <- data.frame(matrix(ncol = 3, nrow = 0))
  
  colnames(id_rules) <- c("taxon",
                          "tvk",
                          "value_code")
  id_rules <- id_rules %>%
    mutate_all(as.character)
  
}

write.csv(id_rules, paste(file_location, "/rules_as_csv/", org, "/", scheme, "_id_difficulty.csv", sep = ""), na = "", row.names = FALSE)
