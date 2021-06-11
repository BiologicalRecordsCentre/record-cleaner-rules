#------------------------------------------------------------------------------
# Create Period rules from period.csv
#------------------------------------------------------------------------------

source("schemes.r")

period_rules = function(
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
	period_file = paste0("../rules/", schemes[[group]]$CSV_PATH, "/period.csv")
	periods = read.csv(period_file)
	
	output_folder = paste0("../rules/", schemes[[group]]$RULES_PATH, "/period")
	# Ensure the output directory exists.
	dir.create(output_folder, showWarnings = FALSE)
			
	# Cross-check files
	cat("Checking files...\n")
	flush.console()
	
	if(nrow(periods) != nrow(unique(periods))){
		warning(
			"period.csv contains duplicated rows (duplicates will be excluded)", 
			immediate. = TRUE
		)
		periods = unique(periods)
	}
						
	# Check all tvk referenced in periods are in species
	period_tvk = unique(periods$TVK)
	chk_inds = which(!period_tvk %in% species$TVK)
	if(length(chk_inds) > 0){
		warning(
			"TVKs given below are present in period.csv but are ",
			"not present in species.csv (these species will be excluded):",
			"\n\t", 
			paste(period_tvk[chk_inds], collapse="\n\t"), 
			immediate. = TRUE
		)
		rm_inds = which(periods$TVK %in% period_tvk[chk_inds])
		periods = periods[-rm_inds,]
	}
		
	# Create vector of month days
	month_day = c(
		JAN = 31,FEB = 28,MAR = 31,APR = 30,MAY = 31,JUN = 30,
		JUL = 31,AUG = 31,SEP = 30, OCT = 31,NOV = 30,DEC = 31
	)
	# Print progress
	cat("Creating period rule files...\n")
	flush.console()
	
	# Loop through rows in temporal file and create temporal rule files
	for(i in 1:nrow(periods)){
		# Format start and end into dates
		if(is.na(periods$YEAR[i])){
			strt = NA
		} else {
			strt_year = periods$YEAR[i]
			strt_month = ifelse(is.na(periods$MONTH[i]),01, periods$MONTH[i])
			strt_day = ifelse(is.na(periods$DAY[i]), 01, periods$DAY[i])
			strt_date = as.Date(
				paste(strt_day, strt_month, strt_year, sep="/"), 
				"%d/%m/%Y"
			)
			strt = format(strt_date,"%Y%m%d")
		}
		
		if(is.na(periods$YEAR2[i])){
			end = NA
		} else {
			end_year = periods$YEAR2[i]
			end_month = ifelse(is.na(periods$MONTH2[i]), 12, periods$MONTH2[i])
			end_day = ifelse(
				is.na(periods$DAY2[i]), 
				month_day[end_month],
				periods$DAY2[i]
			)
			end_date = as.Date(
				paste(end_day, end_month, end_year, sep="/"), 
				"%d/%m/%Y"
			)
			end = format(end_date,"%Y%m%d")
		}
		
		# Extract species name
		tvk = periods$TVK[i]
		spp_info = species[species$TVK == periods$TVK[i],]
		name = spp_info$NAME

		# Print progress
		cat(i, name,"\n")
		flush.console()
		
		# Create rule file
		write_period(strt, end, group, name, tvk, output_folder)
	}
	
	# Print progress
	cat("Finished creating rule files\n\n")
	flush.console()
	
	# Output files if assigned to an object
	return(invisible(list(NAMES = species, PERIOD = periods)))
}


write_period = function(
	strt,			# Start date of rule, yyyymmdd or NA
	end,			# End date of rule, yyyymmdd or NA
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

	# Build file content
	f_header = c(
		"[Metadata]",
		"TestType=Period",
		paste("Group=", group," Recording Period", sep=""),
		paste("ShortName=", name, sep=""),
		paste("Description=Checks date is within known recording period of ", name, sep=""),
		paste("ErrorMsg=Date is outside known recording period of ", name, sep=""),
		paste("Tvk=", tvk, sep=""),
		paste("StartDate=", ifelse(is.na(strt), "", strt), sep=""),
		paste("EndDate=", ifelse(is.na(end), "", end), sep=""),
		paste("LastChanged=", format(Sys.Date(), "%Y%m%d"), sep=""),
		"[EndMetadata]"
	)
				
	# Write information to file
	writeLines(f_header, con = filename)
}

