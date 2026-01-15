---
layout: page
title: Overview
permalink: overview
---

# Overview

Thank you for your interest in Record Cleaner and its rules. 
Writing rules requires considerable knowledge not to mention patience and 
accuracy. Please contact the Biological Records Centre if you are interested
in contributing to this valuable work

These pages describe the structure of the rule sets that sit behind Record
Cleaner, allowing you to create and update rules to be used within Record
Cleaner. It isn’t essential to create files for all of the rule types in order
to use Record Cleaner, except each rule set must have an id_difficulty file. All
of the Organism Keys that appear within the rule set must be listed
in the ID difficulty file.

To start setting up rules, create a main folder with the name of your recording
scheme. Inside this folder, create a folder for each rule set you would like to
create. If you would only like to create one rule set, you should still place
these inside a folder (to keep the two-folder structure). The basic folder
structure will therefore look like this: 

```txt
--> My recording scheme
    |
    --> My rule set
        |
        --> difficulty_codes.csv
            id_difficulty.csv 
```

From here, you can start adding rules into your folder. The below sections
describe the structure of rules in the csv files. Text highlighted in blue will
appear in messages to recorders.

We have described the rules using “taxa” instead of species, as you could create
a rule for a taxon at any level (e.g. a species aggregate, a subspecies or a
genus). However, rules are not applied to taxa that are higher up in the
classification (e.g. a rule for _Machimus_ will not be applied to _Machimus
atricapillus_). 