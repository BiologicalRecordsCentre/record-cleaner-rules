library(tidyverse)
library(stringr)

source("scripts/2_load_functions.R")

for(i in 1:length(schemes)) {
  
  print(names(schemes[i]))
  species_checks(group = names(schemes[i]))
  
  if(file.exists(paste0("rules_as_csv/", names(schemes[i]), "/periodwithinyear.csv"))) {
    
    print("Exporting periodwithinyear.csv")
    periodwithinyear_rules(group = names(schemes[i]))
    
  }

  if(file.exists(paste0("rules_as_csv/", names(schemes[i]), "/id_difficulty.csv"))) {
    
    
    print("Exporting id_difficulty.csv")
    idifficulty_rules(group = names(schemes[i]))
    
  }
  
  if(file.exists(paste0("rules_as_csv/", names(schemes[i]), "/tenkm.csv"))) {
    
    print("Exporting tenkm.csv")
  tenkm_rules(group = names(schemes[i]))
    
  }
  
  if(file.exists(paste0("rules_as_csv/", names(schemes[i]), "/period.csv"))) {
    
    print("Exporting period.csv")
  period_rules(group = names(schemes[i]))
    
  }

}
