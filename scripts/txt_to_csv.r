library(tidyverse)
library(RODBC)
library(gert)
library(keyring)

warehouse <- odbcConnect("PostgreSQL35W")

uksi <- sqlQuery(warehouse, 
                 
                 "select distinct cttl.taxon, cttl.search_code as tvk
                 from indicia.cache_taxa_taxon_lists cttl
                 where taxon_list_id=15"
                 
)

close(warehouse)

file_location <- "C:/Users/robhut/OneDrive - UKCEH/record-cleaner-rules"

folders <- as.data.frame(list.dirs(paste(file_location, "rules", sep = "/")))

colnames(folders) <- "folders"

folders <- folders %>%
  filter(folders != paste(file_location, "rules", sep = "/"))%>%
  mutate(folders = gsub(paste(file_location, "rules/", sep = "/"), "", folders)) %>%
  filter(!grepl("^HRS/", folders),
         !grepl("^SRS/", folders),
         !grepl("^PMRS/", folders))

folders <- unique(folders$folders)

setwd(paste(file_location, "rules", sep = "/"))

for(k in 1:length(folders)) {
  
  folder <- folders[k]
  print(folder)
  
  if(dir.exists(paste(file_location, "rules_as_csv", folder, sep = "/" )) == FALSE) {
    
    dir.create(paste(file_location, "rules_as_csv", folder, sep = "/" ), recursive = TRUE)
    
  }
  
  text_files <- list.files(path = folder, pattern = "txt")
  
  if(length(text_files) == 0) next
  
  file <- read.delim(paste(folder, text_files[1], sep = "/"), stringsAsFactors = FALSE, fileEncoding = "Latin1")
  colnames(file) <- "meta"
  file_type <- file %>%
      filter(grepl("TestType", meta)) %>%
      separate(meta, into = c("title","value"),sep = "=") %>%
    mutate(value = trimws(value))
  
  file_type <- unique(file_type$value)

    
  rules <-  data.frame(matrix(ncol = 1, nrow = 0))
  colnames(rules) <- c("tvk")
  rules <- rules %>%
    mutate_all(as.character)
  
    if(file_type == "IdentificationDifficulty") {
      
      for(i in 1:length(text_files)) {
        
        file_name <- text_files[i]
        print(file_name)
        temp <- read.delim(paste(folder, file_name, sep = "/"), stringsAsFactors = FALSE, fileEncoding = "Latin1")
        colnames(temp) <- "id"
        
        values <- temp %>%
          filter(grepl("=", id, fixed = TRUE),
                 !grepl("[", id, fixed = TRUE)) %>%
          separate(id, into = c("tvk","value_code"),sep = "=") %>%
          filter(grepl("^...SYS", tvk))
        
        rules_new <- bind_rows(values, rules) %>%
          left_join(uksi, by = "tvk") 
        
        codes <- temp %>%
          filter(grepl("=", id, fixed = TRUE)) %>%
          separate(id, into = c("value_code","text"),sep = "=") %>%
          mutate(value_code = trimws(value_code)) %>%
          filter(!grepl("[[:alpha:]]", value_code))
        
        
        write.csv(rules_new, paste(file_location, "/rules_as_csv/", folder, "/", gsub("txt$", "", file_name), "csv", sep = ""), na = "", row.names = FALSE)
        write.csv(codes, paste(file_location, "/rules_as_csv/", folder, "/difficulties_codes.csv", sep = ""), na = "", row.names = FALSE)

        
        git_add(paste("rules_as_csv/", folder, "/", gsub("txt$", "", file_name), "csv", sep = ""))
        git_add(paste("rules_as_csv/", folder, "/difficulties_codes.csv", sep = ""))

        stat <- git_status() %>%
          filter(grepl("rules_as_csv", file),
                 staged == TRUE)
        print(stat)
        if(nrow(stat) != 0){
          
        git_commit_all(paste("Add files: ", folder, "/", gsub("txt$", "", file_name), "csv" , sep = ""))
        git_push()
        
      }
        
      }
      
      
    } else if(file_type == "WithoutPolygon") {
      
      
      for(i in 1:length(text_files)) {
        
        file_name <- text_files[i]
        print(file_name)
        
        temp <- read.delim(paste(folder, file_name, sep = "/"), stringsAsFactors = FALSE, fileEncoding = "Latin1")
        colnames(temp) <- "tenkm"
        metadata <- temp %>%
          filter(grepl("DataRecordId", tenkm)) %>%
          separate(tenkm, into = c("title","value"),sep = "=")%>%
          pivot_wider(names_from = title, values_from = value) %>%
          rename(tvk = DataRecordId) %>%
          select(tvk)
          
        values <- temp %>%
          filter(!grepl("=", tenkm, fixed = TRUE),
                 !grepl("[", tenkm, fixed = TRUE)) %>%
          rename(value = tenkm)
        
        if(nrow(values) == 0) next
        
        values <- values %>%
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
          rules <- bind_rows(rule, rules)
        
      }
      
      rules <- right_join(uksi, rules, by = "tvk")
      
      write.csv(rules, paste(file_location, "/rules_as_csv/", folder, "/tenkm.csv", sep = ""), na = "", row.names = FALSE)
      git_add(paste("rules_as_csv/", folder, "/tenkm.csv", sep = ""))
      stat <- git_status() %>%
        filter(grepl("rules_as_csv", file),
               staged == TRUE)
      print(stat)
      if(nrow(stat) != 0){
        
        git_commit_all(paste("Add files: ", folder, "/tenkm.csv" , sep = ""))
       git_push()
      
      }
      
    } else if(file_type == "Period") {
      
      for(i in 1:length(text_files)) {
        
        file_name <- text_files[i]
        print(file_name)
        
        temp <- read.delim(paste(folder, file_name, sep = "/"), stringsAsFactors = FALSE, fileEncoding = "Latin1")
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
        
        rules <- bind_rows(rule, rules)
      }
      
      rules <- right_join(uksi, rules, by = "tvk")
      write.csv(rules, paste(file_location, "/rules_as_csv/", folder, "/period.csv", sep = ""), na = "", row.names = FALSE)
      git_add(paste("rules_as_csv/", folder, "/period.csv", sep = ""))
      
      stat <- git_status() %>%
        filter(grepl("rules_as_csv", file),
               staged == TRUE)
      print(stat)
      if(nrow(stat) != 0){
        
        git_commit_all(paste("Add files: ", folder, "/period.csv" , sep = ""))
        git_push()
      
      }
      
    } else if(file_type == "PeriodWithinYear") {
      
      for(i in 1:length(text_files)) {
        
        file_name <- text_files[i]
        print(file_name)
        
        temp <- read.delim(paste(folder, file_name, sep = "/"), stringsAsFactors = FALSE, fileEncoding = "Latin1")
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
        
        rules <- bind_rows(rule, rules)
      }
      
      rules <- right_join(uksi, rules, by = "tvk") %>%
        mutate(stage = "Adult")
      write.csv(rules, paste(file_location, "/rules_as_csv/", folder, "/periodwithinyear.csv", sep = ""), na = "", row.names = FALSE)
      git_add(paste("rules_as_csv/", folder, "/periodwithinyear.csv", sep = ""))
      
      stat <- git_status() %>%
        filter(grepl("rules_as_csv", file),
               staged == TRUE)
      print(stat)
      if(nrow(stat) != 0){
        
        git_commit_all(paste("Add files: ", folder, "/periodwithinyear.csv" , sep = ""))
        git_push()
      
      }
      
    } else if(file_type == "AncillarySpecies") {
      
      for(i in 1:length(text_files)) {
        
        file_name <- text_files[i]
        print(file_name)
        
        temp <- read.delim(paste(folder, file_name, sep = "/"), stringsAsFactors = FALSE, fileEncoding = "Latin1")
        colnames(temp) <- "additional"
        
        values <- temp %>%
          filter(!grepl("=", additional, fixed = TRUE),
                 !grepl("[", additional, fixed = TRUE)) %>%
          separate(additional, into = c("tvk","value_code"),sep = ",") 
        
        codes <- temp %>%
          filter(grepl("=", additional, fixed = TRUE)) %>%
          separate(additional, into = c("value_code","text"),sep = "=") %>%
          mutate(value_code = trimws(value_code)) %>%
          filter(!grepl("[[:alpha:]]", value_code))
        
        msg <- temp %>%
          filter(grepl("^ErrorMsg", additional)) %>%
          mutate(ErrorMsg = gsub("ErrorMsg", "", additional),
                 ErrorMsg = trimws(gsub("=", "", ErrorMsg))) %>%
          select(ErrorMsg)
        
        rules_new <- bind_rows(values, rules) %>%
          left_join(uksi, by = "tvk") 
        
        write.csv(rules_new, paste(file_location, "/rules_as_csv/", folder, "/", gsub("txt$", "", file_name), "csv", sep = ""), na = "", row.names = FALSE)
        write.csv(codes, paste(file_location, "/rules_as_csv/", folder, "/additional_codes.csv", sep = ""), na = "", row.names = FALSE)
        write.csv(msg, paste(file_location, "/rules_as_csv/", folder, "/additional_msg.csv", sep = ""), na = "", row.names = FALSE)
        
        git_add(paste("rules_as_csv/", folder, "/", gsub("txt$", "", file_name), "csv", sep = ""))
        git_add(paste("rules_as_csv/", folder, "/additional_codes.csv", sep = ""))
        git_add(paste("rules_as_csv/", folder, "/additional_msg.csv", sep = ""))
        
        stat <- git_status() %>%
          filter(grepl("rules_as_csv", file),
                 staged == TRUE)
        
        if(nrow(stat) != 0){
          
          git_commit_all(paste("Add files: ", folder, "/", gsub("txt$", "", file_name), "csv" , sep = ""))
        git_push()
        
        }
        
        
        
        }

      
    }
      
}