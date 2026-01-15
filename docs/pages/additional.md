---
layout: page
title: Additional Checks
permalink: additional
---

# Additional Checks 

This check is for taxa that you would like to be flagged for additional or more rigorous verification checks, even if they pass all the other checks. One example of this would be a rare species that is easy to identify (so would not be flagged under id_difficulty). 

This check requires 2 files. 

## additional_codes.csv 

The column “code” should contain numbers (starting from 1). Assign each code a
“text” value. This should be a short description of why the species with that
code should be scrutinised more closely. We’ve included seven examples here,
which can be edited, removed or added to.

code | text
---- | ----
1 | Rare species: it is not common to receive records of this species even within their distribution and flight period 
2 | Recent arrival: The species is a recent arrival in Britain and either has a very restricted distribution, or the distribution is changing rapidly. 
3 | Recently recognised species: An overlooked resident species which has only recently been recognised as such, or a species complex that has recently been split 
4 | Rare host: Associated with another species that is rare or declining 
5 | Probably extinct/not recorded recently 
6 | Visiting species: This species is not established in the UK, but is occasionally seen 
7 | We do not have enough data to create distribution or flight period rules for this species 

## additional.csv 

This is the spreadsheet that Record Cleaner will check. First, add the organism
key into the first column of the taxa you would like to add a rule for.  The
second, “taxon” column is for your use; add the name of the taxa that the rule
relates to. In the third column (“code”), add one of the codes you included in
the previous file.

organism_key | taxon | code
------------ | ----- | ----
NBNORG0000006883 | Nothogeophilus turki | 2
NBNORG0000006884 | Arenophilus peregrinus | 2
NBNORG0000010720 | Buddelundiella cataractae | 1