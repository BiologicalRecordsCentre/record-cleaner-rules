#------------------------------------------------------------------------------
# Create WithoutPolygon rules from tenkm.csv
#------------------------------------------------------------------------------

library(rstudioapi)

source("schemes.r")

tenkm_rules = function(
  group = NULL # String, taxonomic group to build rules for.
){
	if(is.null(group) | !isTRUE(group %in% names(schemes))){
		return(paste0(
		  "You must pass in a group parameter from the following: ",
		  paste(names(schemes), collapse = ", "),
		  '.'
	  ))
	}
	
  #Locate files
  
  
  wd <- gsub("/scripts", "", getwd())
  folders <- list.dirs(wd)
  
  colnames(folders) <- "folders"
  
  folders <- folders %>%
    filter(grepl("tenkm$", folders),
           grepl(paste("/rules_as_csv/", schemes[[group]]$CSV_PATH, "/", sep = ""), folders))
  dir <- folders$folders
	
  # Read files

	tenkm_file = paste0(dir, "/tenkm.csv")
	tenkms = read.csv(tenkm_file)
	output_folder <- gsub("/rules_as_csv/", "/rules_export/", dir)
	
	# Ensure the output directory exists.
	dir.create(output_folder, showWarnings = FALSE)
			
	# Cross-check files
	cat("Checking files...\n")
	flush.console()
	
	# Check for duplicated rows
	if(nrow(tenkms) != nrow(unique(tenkms))){
		warning(
			"tenkm.csv contains duplicated rows (duplicates will be excluded)",
			immediate. = TRUE
		)
		tenkms = unique(tenkms)
	}


				
	# Print progress
	cat("Creating tenkm rule files...\n")
	flush.console()
	
	# Loop through species and create distribution rules
	for(i in 1:nrow(unique(tenkm$tvk))){
		# Find indicies for distribution data of this species
		tvk = unique(tenkm$tvk)[i]
		gr_inds = which(tenkms$tvk == tvk)
		# If data found then create rule file
		if(length(gr_inds) > 0){
			# Extract species name
			name = unique(tenkm$name)[i]
			# Print progress
			cat(i, name,"\n")
			flush.console()
			
			# Create rule file
			write_tenkm(
				gridrefs = tenkms$GRIDREF[gr_inds],
				group,
				name,
				tvk, 
				output_folder
			)
		}
	}
		
	# Print progress
	cat("Finished creating rule files\n\n")
	flush.console()
	
	# Output files if assigned to an object
	return(invisible(list(NAMES = species, DIST = tenkms)))
}


write_tenkm = function(
	gridrefs, 		# Vector of gridrefs to output
	group,			# The name of the taxonomic group
	name,			# The name of the species
	tvk,			# The taxon-version key of the species
	output_folder	# The folder to save the rule file in.
){
	# Build filename
	filename = file.path(
		output_folder,
		paste0(gsub("[./\\]", "", name),".txt")
	)

	# Open connection to file specified
		f_con = file(filename, open = "wt")
		
	# Build file header
	f_header = c(
		"[Metadata]",
		"TestType=WithoutPolygon",
		paste("Group=", group, " 10km distribution", sep=""),
		paste("ShortName=", name, " 10km", sep=""),
		paste("Description=Check coordinate against known distribution of", name),
		paste("ErrorMsg=Coordinate is outside known range for", name),
		"DataFieldName=Species",
		paste("DataRecordId=", tvk, sep=""),
		paste("LastChanged=", format(Sys.Date(), "%Y%m%d"), sep=""),
		"[EndMetadata]\n"
	)

	# Write header to file
	writeLines(f_header, con = f_con)
	
	# Remove duplicates from gridrefs
	gridrefs = unique(gridrefs)

	# Remove any NAs from gridrefs
	rm_inds = which(is.na(gridrefs))
	if(length(rm_inds) == length(gridrefs)){
		stop("All gridref values are NA")
	} else if(length(rm_inds) > 0){
		gridrefs = gridrefs[-rm_inds]
	}

	# Remove any empty or spaces filled gridrefs
	rm_inds = which(grepl("^[ ]+$", gridrefs) | gridrefs == "")
	if(length(rm_inds) == length(gridrefs)){
		stop("All gridref values are blank or contain only spaces")
	} else if(length(rm_inds) > 0){
		gridrefs = gridrefs[-rm_inds]
	}

	# Determine grid type for each gridref.
	# Types are OSGB, OSNI, or UTM30.
	gr_types = get_gr_type(gridrefs)
		
	# Grid markers to put in file
	gr_markers = c("[10km_GB]", "[10km_Ireland]", "[10km_CI]")
	names(gr_markers) = c("OSGB", "OSNI", "UTM30")

	# Drop any grid markers for types not in use
	gr_markers = gr_markers[unique(gr_types)]

	# Loop through grid types, printing marker and then grid references
	for(j in 1:length(gr_markers)){
		# Determine which grid refs are current gr_types 
		gr_type = names(gr_markers)[j]
		type_inds = which(gr_types == gr_type)
		# Add marker to file and write gridrefs
		writeLines(c(
			gr_markers[j], 
			sort(gridrefs[type_inds]),
			"\n"
		), con = f_con)
	}

	# Close file connection
		close(f_con)
}


# Function to determine grid reference type.
get_gr_type = function(gridrefs){
	# Create variable to store output
	types = rep(NA, length(gridrefs))
  
	# Find British 10km gridrefs
	types[
		grepl("^[[:upper:]]{2}[[:digit:]]{2}$", gridrefs)
		& !grepl("^(WA)|(WV)", gridrefs)
	] = "OSGB"
	
	# Find Irish 10km gridrefs
	types[
		grepl("^[[:upper:]]{1}[[:digit:]]{2}$", gridrefs)
	] = "OSNI"
	
	# Find Channel Islands 10km gridrefs
	types[
		grepl("^(WA)|(WV)[[:digit:]]{2}$)",gridrefs)
	] = "UTM30"
	
	# Return output object
	return(types)
}

