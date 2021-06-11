#------------------------------------------------------------------------------
# Perform checks on species file
#------------------------------------------------------------------------------

source("schemes.r")

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
	species_file = paste0("../rules/", schemes[[group]]$CSV_PATH, "/species.csv")
	species = read.csv(species_file)
			
	# Check file
	cat("Checking species file...\n")
	flush.console()

	# Check for duplicated rows
	if(nrow(species) != nrow(unique(species))){
		warning(
			"Species csv contains duplicated rows which will be removed.", 
			immediate. = TRUE
		)
		species = unique(species)
	}
			
	# Look for TVKs that are matched to more than one name
	chk_inds = which(
			tapply(as.character(species$NAME), species$TVK, length, simplify = FALSE) > 1
	)
	if(length(chk_inds) > 0){
		warning(
		  "TVKs given below are linked to more than 1 name and will be removed.\n\t", 
		  paste(names(chk_inds), collapse="\n\t"), 
		  immediate. = TRUE
		)
	}
			
	# Look for names that are matched to more than one TVK
	chk_inds = which(
	  tapply(as.character(species$TVK), species$NAME, length, simplify = FALSE) > 1)
	if(length(chk_inds) > 0){
		warning(
		  "Name(s) given below are linked to more than 1 TVK.\n\t", 
		  paste(names(chk_inds), collapse="\n\t"), 
		  immediate. = TRUE
		)
	}
	
	# Print progress
	cat("Finished checking species file.\n\n")
	flush.console()
	
}

