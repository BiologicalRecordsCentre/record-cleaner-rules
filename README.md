# Record Cleaner Rules

## About
The [NBN RecordCleaner](https://nbn.org.uk/tools-and-resources/nbn-toolbox/nbn-record-cleaner/)
has been available as a Windows application for checking species observations against rules drawn
up based on past observations and expert knowledge.

The rules contain information such as where and when species can be observed
so that records falling outside known ranges can be highlighted for additional 
checking.

[Record Cleaner online](https://www.brc.ac.uk/record_cleaner) is now available, hosted within the UKCEH Biological Records Centre website. It uses the rules specified within this repository, derived from rules originally developed by national recording schemes, and available from NBN.

Each rule for each species used to be stored in a small text file complying with the
[original specification](https://data.nbn.org.uk/recordcleaner/documentation/NBNRecordCleanerRuleGuide.pdf).

The original ruleset files are available via an [index](https://data.nbn.org.uk/recordcleaner/rules/servers.txt) hosted by NBN.

This repository has been created to manage the rules for online use and for future updates. It contains the rules in a more condensed, comma-separated value (CSV) file format.

## How to update rule files
Rule files updates are normally overseen by the relevant national recording scheme, and BRC can support this process as required.

Either
 - Use Git to clone the repository then apply updates to the files in the `rules_as_csv` folder before committing and pushing them back to the repo.
 - Edit the files via the github website.
 - Use tools which are under development to assist with editing. Contact BRC 
 for the latest information.
