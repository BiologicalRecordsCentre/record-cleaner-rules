library(tidyverse)
library(gert)
library(gitcreds)
# gitcreds_set()
file_location <- "C:/Users/robhut/OneDrive - UKCEH/record-cleaner-rules/rules"

index <- read.delim("https://data.nbn.org.uk/recordcleaner/rules/servers.txt", header = FALSE) %>%
  mutate(V1 = gsub("#.+$", "", V1),
         folder = gsub("^.+rules", "", V1),
         folder = gsub("/index.txt", "", folder, fixed = TRUE),
         folder = gsub("/", "", folder, fixed = TRUE))
folder <- index$folder
index <- index$V1


for(i in 1:length(index)) {
  
  scheme_index <- read.delim(index[i], header = FALSE)%>%
    mutate(V1 = gsub("#.+$", "", V1))
  scheme_index <- scheme_index$V1
  
  if(dir.exists(paste(file_location, folder[i], sep = "/" )) == FALSE) {
    
    dir.create(paste(file_location, folder[i], sep = "/" ), recursive = TRUE)
    
  }
  
  
  for(j in 1:length(scheme_index)) {
    
    temp <- tempfile()

    download.file(URLencode(scheme_index[j]),temp)
    zip_name <- gsub("http://data.nbn.org.uk/recordcleaner/rules/", "", scheme_index[j])
    zip_name <- gsub(paste(folder[i], "/", sep = ""), "", zip_name)
    zip_name <- gsub(".zip", "", zip_name)
    print(zip_name)
    
    unzip(temp, list = FALSE, overwrite = TRUE, exdir = paste(file_location, folder[i], sep = "/"), unzip = "unzip")
    unlink(temp)
    all_files <- list.files(path = paste(file_location, folder[i], zip_name, sep = "/"), pattern = "txt")
    if(length(all_files) == 0) next
    
    for(k in 1:length(all_files)) {
      
      git_add(paste(file_location, folder[i], zip_name, all_files[k], sep  = "/"))
      
    }
    
      
      git_commit_all(paste("Add files: ", gsub("http://data.nbn.org.uk/recordcleaner/rules/", "", scheme_index[j]), sep = ""))
      git_push()
      
    
  }
  
  
  print(paste("Complete", index[i], sep = ": "))
  
}

