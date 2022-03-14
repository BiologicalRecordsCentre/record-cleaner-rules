#! /bin/bash

mkdir -p ../../zip/GBRS
rm ../../zip/GBRS/*.zip -f
cd GBRS_IDifficulty
zip -r ../../../zip/GBRS/GBRS_IDifficulty.zip GBRS_IDifficulty.txt
cd ../"GBRS Ground Beetle rules"
zip -r ../../../zip/GBRS/"GBRS Ground Beetle rules.zip" GBRS
