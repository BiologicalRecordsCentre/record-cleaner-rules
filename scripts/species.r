#------------------------------------------------------------------------------
# Perform checks on species file
#------------------------------------------------------------------------------
species_checks = function(
  group = NULL
){
	if(is.null(group) | !isTRUE(group %in% names(schemes))){
		return(paste0(
		  "You must pass in a group parameter from the following: ",
		  paste(names(schemes), collapse = ", "),
		  '.'
	  ))
	}
	
	# Read file
	species_file = paste0("rules_as_csv/", schemes[[group]]$scheme, "/",schemes[[group]]$rule_group, "/id_difficulty.csv")
	if(file.exists(species_file)){
	  
	  species = read.csv(species_file)
	  
	  # Check file
	  cat("Checking species file...\n")
	  flush.console()
	  
	  
	  # Check for duplicated rows
	  if(nrow(species) != length(unique(species$tvk))){
	    
	    dups <- species %>%
	      count(tvk) %>%
	      filter(n > 1)
	    
	    warning(
	      "TVKs below are duplicated.\n\t", 
	      
	      paste(dups$tvk, collapse="\n\t"), 
	      immediate. = TRUE
	    )
	    species = unique(species)
	  }
	  
	  # Look for TVKs that are matched to more than one name
	  chk_inds = which(
	    tapply(as.character(species$taxon), species$tvk, length, simplify = FALSE) > 1
	  )
	  
	  if(length(chk_inds) > 0){
	    
	    warning(
	      "TVKs given below are linked to more than 1 name.\n\t", 
	      paste(names(chk_inds), collapse="\n\t"), 
	      immediate. = TRUE
	    )
	  }
	  
	  # Look for names that are matched to more than one TVK
	  chk_inds = which(
	    tapply(as.character(species$tvk), species$taxon, length, simplify = FALSE) > 1)
	  
	  if(length(chk_inds) > 0){
	    
	    warning(
	      "Names given below are linked to more than 1 TVK.\n\t", 
	      paste(names(chk_inds), collapse="\n\t"), 
	      immediate. = TRUE
	    )
	  }
	  
	  # Print progress
	  cat("Finished checking species file.\n\n")
	  flush.console()
	  
	  
	} else {
	  
	  cat("Species file does not exist.\n\n")
	  flush.console()
	  
	}
	
	
	
}

