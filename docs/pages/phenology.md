---
title: Period within year
permalink: phenology
---

## Period within Year 

These rules are used when a species is only recorded at a particular time of
year (such as the flight period). Records will be flagged if they are outside of
the specified window.  

### periodwithinyear.csv 

It is possible to have a period that runs over the new year (e.g. November to
June), but the period should be less than a full year (it should not run from
June of one year to July of the next).  

These rules are linked to life stages. The “stage” column  is free text, but
asterisks and “mature” have additional functions as default values. 

Where the stage is *: The life stage of the record will be ignored and the rule
will always be applied. 

Where the stage is “mature”: The rule will be applied if the record has a mature
life stage (see stage_synonyms.csv) or no life stage information is given. 

For any other value in the stage column, the rule will only be applied if the
stage given in the record is a synonym of that value. 

organism_key | taxon | stage | start_day | start_month | end_day | end_month
------------ | ----- | ----- | --------- | ----------- | ------- | ---------
NBNORG0000011289 | Auplopus carbonarius | mature | 1 | 4 | 31 | 10
NBNORG0000011290 | Caliadurgus fasciatellus | mature | 1 | 5 | 31 | 10
NBNORG0000011291 | Pompilus cinereus | mature | 1 | 5 | 31 | 10

### stage_synonyms.csv 

To allow for a wider variety of stage terms, you will need to create a file for synonyms. In the stage column, put the stage terms you used in the period_within_year file. In the synonyms column, put all of the stage terms that you would like the rule to be applied to, separated by “, ”. If a record is added that has a stage and does not match one of the synonyms you have listed, the record will not be checked against the period_within_year rules.

stage | synonyms
----- | --------
mature | adult, adults, adult female, adult females, adult male, adult males, adult unknown, imago, mature, NA, not recorded 
immature | pupa, larva, nymph, egg, immature, juvenile 