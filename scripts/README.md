# Rule Generation Scripts

These scripts, written in the R language, compile csv files in to NBN 
Verification Rule file format

## CSV File formats
### Species
A file named `species.csv` shall list species data in 3 columns, one row per
species. The first row must contain the headings as
```
TVK,NAME,ID_DIFF
```
Each subsequent row should contain the taxon-version key, Latin name, and
a number from 1 to 5 indicating identification difficulty. The difficulty
number can be omitted if not needed.

### Difficulties
A file named `difficulties.csv` shall list identification difficulty data in 
2 columns, one row per identification difficulty. The first row must contain
the headings as 
```
ID,TEXT
```
Each subsequent row contains the identification difficulty number, which
can be from 1 to 5, followed by the text describing the difficulty. Put the 
text in quotation marks ("") so that commas are not misunderstood.

### Period
Rules indicating the recording period, for example if a species has been 
introduced or become extinct, can be defined in a file named `period.csv`.
It shall contain 7 columns with one row per species. The first row must
contain the headings as
```
TVK,DAY,MONTH,YEAR,DAY2,MONTH2,YEAR2
```
Each subsequent row contains the taxon-version key of the species
followed by a start date, if relevant, in the DAY, MONTH, YEAR columns and
an end date, if relevant, in the DAY2, MONTH2, YEAR2 columns. If a date is 
not relevant, simply omit values (but not the commas). Dates can be vague
so that day or month can be omitted. A vague start date, e.g. 2006, is
set to the start of the period, i.e. 1st January 2006. A vague end date,
e.g. 3,2010, is set to the end of the period, i.e. 31st March 2010.

### Seasonal Periods
Rules indicating the season in which a species can be observed can be defined
in a file named `flightperiod.csv`. This might be used for migratory species,
only present at certain times of year, or insects only commonly observed in 
their adult life stage. The intention is to develop this to allow rules 
for multiple periods linked to different life stages. 

At present the file has 5 columns with one row per species. The first row
must contain the headings as
```
TVK,DAY,MONTH,DAY2,MONTH2
```
Each subsequent row must contain the taxon-version key of the species, the 
start date in the DAY, MONTH columns and the end date in the DAY2, MONTH2 
columns. The DAY and DAY2 fields may be omitted (but not the commas) in 
which case the period starts on the first day of MONTH and ends on the last
day of MONTH2

### Distribution
Geographical rules are defined by the ten kilometers squares where a species
is known to be present. Squares can be given for Britain, Ireland and the 
Channel Islands using OSGB, OSNI or UTM30 grid references respectively. They
should be contained in a file named `tenkm.csv` having two columns. The 
first row must contain the headings as 
```
TVK,GRIDREF
```
Each subsequent row contains the taxon-version key of a species followed by one 
ten kilometer square in which it is found. There will be many rows for each 
species.

## Scripts
The scripts are written in R. They can be run manually but the aspiration
is to automate them using Github continuous integration.

* `schemes.r` holds configuration for each taxonomic group, identifying
the path to their csv files, and the path for the output rules.
* `species.r` performs checks on `species.csv` and other scripts should
not be run until this reports no problems. Execute `species_checks("<group>")`,
where `<group>` is replaced by one of the taxonomic groups listed in 
`schemes.r`.
* `period.r` Execute `period_rules("<group>")` to build period rules.
* `flightperiod.r` Execute `flightperiod_rules("<group>")` to build seasonal 
period rules.
* `tenkm.r` Execute `tenkm_rules("<group>")` to build distribution rules.
* `idifficulty.r` Execute `idifficulty_rules("<group>")` to build 
identification difficulty rules.

