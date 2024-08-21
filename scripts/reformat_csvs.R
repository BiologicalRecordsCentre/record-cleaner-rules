library(gert)
library(tidyverse)
library(data.table)
file_location <- "C:/Users/robhut/OneDrive - UKCEH/record-cleaner-rules/rules_as_csv"

folders <- as.data.frame(list.dirs(file_location))

colnames(folders) <- "folders"

folders <- folders %>%
  filter(folders != file_location) %>%
  mutate(folders = gsub(paste(file_location, "/", sep = ""), "", folders)) %>%
  filter(grepl("/", folders, fixed = TRUE))

folders <- unique(folders$folders)

setwd(file_location)

for(k in 1:length(folders)) {
  
  folder <- folders[k]
  print(folder)
  
  text_files <- list.files(path = folder, pattern = "csv")
  
  if(length(text_files) == 0) {next}
  
  for(i in 1:length(text_files)){
    
    
    file <- text_files[i]
    print(file)
    df <- read.csv(paste(folder, file, sep = "/"))
    
    if("value_code" %in% colnames(df)) {
      

      df <- df %>%
        rename(code = value_code)
      
    }
    
    
    if(length(which(colnames(df) %in% c("ErrorMsg", "text"))) != 0) {
      

      fwrite(df, paste(folder, file, sep = "/"), row.names = FALSE, na = "", quote = "auto")
                
      
    } else {
      
      write.csv(df, paste(folder, file, sep = "/"), row.names = FALSE, na = "", quote = FALSE)
                
    }
    
    git_add(paste(folder, file, sep = "/"))
    
  }
  
  git_commit_all(paste("Remove quotations", folder, sep = ": "))
  git_push()
}

