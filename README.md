# Record Cleaner Rules

## About
The [NBN RecordCleaner](https://nbn.org.uk/tools-and-resources/nbn-toolbox/nbn-record-cleaner/)
is a Windows application for checking species observations against rules drawn
up based on past observations and expert knowledge.

The rules contain information such as where and when species can be observed 
so that records falling outside known ranges can be highlighted for additional 
checking.

The [Indicia Biological Recording System](http://www.indicia.org.uk/) has been
developed so that it can apply these same rules to records and the 
www[iRecord website](https://www.brc.ac.uk/irecord/), in particular, uses them
to flag exceptional records to the recorder and verifier.

Each rule for each species is stored in a small text file complying with the  
[specification](https://data.nbn.org.uk/recordcleaner/documentation/NBNRecordCleanerRuleGuide.pdf).

There is a two-tier [index](https://data.nbn.org.uk/recordcleaner/rules/servers.txt)
listing where rulesets for different recording schemes can be 
downloaded from. In practise they are all hosted by the NBN currently.

This repository has been created in retrospect to help manage updates to the 
rules. It contains the rule files themselves and scripts for bundling them in
to zip files.

The zip files cannot be served from Github because the Record Cleaner software
does not support the https protocol.

## How to update rule files
Clone the repository and apply updates to the files in the `rules` folder.
Major updates are usually achieved by compiling information in a spreadsheet
and running a script offline to create the rule files. The old files can be
deleted and replaced by the new ones. When changes are complete they can be
committed and pushed.

## How to package rule files
To zip the rule files for a particular recording scheme, 
 - change to the /rules/<scheme> folder, 
 - execute the ./package.sh script
 - the ouput is stored by recording scheme in the /zip folder

 The folder names and structure within the zip file are chosen to maintain the
 organisation which the NBN already have in place to ensure on-going 
 compatibility

The package script is written for Linux users but variants for other operating
systems could be easily created.