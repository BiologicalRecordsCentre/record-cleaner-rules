#! /bin/bash

mkdir -p ../../zip/BMIG
rm ../../zip/BMIG/*.zip -f
cd BMIG_IDifficulty
zip -r ../../../zip/BMIG/BMIG_IDifficulty.zip BMIG_IDifficulty.txt
cd ../"BMIG Myriapod and Isopod rules"
zip -r ../../../zip/BMIG/"BMIG Myriapod and Isopod rules.zip" BMIG
