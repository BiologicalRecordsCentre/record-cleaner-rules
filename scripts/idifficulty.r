#------------------------------------------------------------------------------
# Create Period rules from period.csv
#------------------------------------------------------------------------------

source("schemes.r")

idifficulty_rules = function(
  group = NULL # String, taxonomic group to build rules for.
){
	if(is.null(group) | !isTRUE(group %in% names(schemes))){
		return(paste0(
		  "You must pass in a group parameter from the following: ",
		  paste(names(schemes), collapse = ", "),
		  '.'
	  ))
	}
	
	# Read files
	species_file = paste0("../rules/", schemes[[group]]$CSV_PATH, "/species.csv")
	species = read.csv(species_file)
	difficulty_file = paste0(
		"../rules/", 
		schemes[[group]]$CSV_PATH, 
		"/difficulties.csv"
	)
	difficulties = read.csv(difficulty_file)
	
	output_folder = paste0("../rules/", schemes[[group]]$IDIFF_PATH)
	# Ensure the output directory exists.
	dir.create(output_folder, showWarnings = FALSE)
			
	# Cross-check files
	cat("Checking files...\n")
	flush.console()	

	# Remove species for which there is no ID_DIFF.
	species = species[!is.na(species$ID_DIFF),]
	
	species_idiff = unique(species$ID_DIFF)
	chk_inds = which(!species_idiff %in% difficulties$ID)
	if(length(chk_inds) > 0){
		warning(
			"ID_DIFFs given below are present in species.csv but are ",
			"not present in difficulties.csv (corresponding species will be excluded):",
			"\n\t", 
			paste(species_idiff[chk_inds], collapse="\n\t"), 
			immediate. = TRUE
		)
		rm_inds = which(species$ID_DIFF %in% species_idiff[chk_inds])
		species = species[-rm_inds,]
	}

	if(length(species) > 0)
	{
		# Print progress
		cat("Creating idifficulty rule file...\n")
		flush.console()
		
		# Build filename
		filename = file.path(output_folder,"idifficulty.txt")

	} else {
		cat("No ID Difficulty values found so no rule file created.\n")
	}
		
		# Open connection to file specified
		f_con = file(filename, open = "wt")

		# Write header part of file
		f_header = c(
			"[Metadata]",
			"TestType=IdentificationDifficulty",
			paste("Organisation=", schemes[[group]]$ORG, sep=""),
			paste("LastChanged=", format(Sys.Date()," %Y%m%d"), sep=""),
			"[EndMetadata]\n"
		)	
		writeLines(f_header, con = f_con)
			
		# Write difficulty description part of file
		f_msg = c(
			"[INI]",
			apply(difficulties, 1, paste, collapse = "="),
			""
		)
		writeLines(f_msg, con = f_con)
			
		# Write species id difficulty part of file
		f_idiff = c(
			"[DATA]",
			apply(species[c("TVK", "ID_DIFF")], 1, paste, collapse = "=")
		)
		writeLines(f_idiff, con = f_con)
		
		# Close file connection
		close(f_con)	
	
	# Print progress
	cat("Finished creating rule files\n\n")
	flush.console()
	
	# Output files if assigned to an object
	return(invisible(list(NAMES = species)))
}



