#! /bin/bash

mkdir -p ../../zip/PRS
rm ../../zip/PRS/*.zip -f
cd PRS_IDifficulty
zip -r ../../../zip/PRS/PRS_IDifficulty.zip PRS_IDifficulty.txt
cd ../"PRS Stonefly rules"
zip -r ../../../zip/PRS/"PRS Stonefly rules.zip" PRS
