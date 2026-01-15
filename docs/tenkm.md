# 10 km distribution 

This file will flag records outside of the 10km squares specified.  

## tenkm.csv 

For each taxa, create a row for each 100 km square that it can be recorded in.
Then list every 10km square that the species could be recorded in the next
column, separated by a space. If a species can be found in the entire 100 km
square, list all of the 10 km squares: 

00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52
53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79
80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99

If you would like a starting file for your taxa, contact irecord@ceh.ac.uk. We
can support you with: 

 - Generating 10 km square lists from the scheme's data 

 - Generating 10 km square lists from the scheme's data plus a buffer (e.g. to
   include all adjoining 10 km squares) 

organism_key | taxon | km100 | km10 | coord_system
------------ | ----- | ----- | ---- | ------------
NBNORG0000006882 | Geophilus easoni | NN | 06 | OSGB
NBNORG0000006882 | Geophilus easoni | NR | 27 34 35 36 37 38 39 49 | OSGB
NBNORG0000006882 | Geophilus easoni | NU | 00 01 | OSGB
