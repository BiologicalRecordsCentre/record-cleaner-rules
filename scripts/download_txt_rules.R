library(tidyverse)

file_location <- "C:/Users/robhut/OneDrive - UKCEH/Indicia/record-cleaner-rules"

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
  
  if(dir.exists(paste(file_location, "rules", folder[i], sep = "/" )) == FALSE) {
    
    dir.create(paste(file_location, "rules", folder[i], sep = "/" ), recursive = TRUE)
    
  }
  
  
  for(j in 1:length(scheme_index)) {
    
    temp <- tempfile()

    download.file(URLencode(scheme_index[j]),temp)
    unzip(temp, list = FALSE, overwrite = TRUE, exdir = paste(file_location, "rules", folder[i], sep = "/"), unzip = "unzip")
    unlink(temp)
    print(paste("Complete", scheme_index[j], sep = ": "))
    
  }
  
  
  print(paste("Complete", index[i], sep = ": "))
}
