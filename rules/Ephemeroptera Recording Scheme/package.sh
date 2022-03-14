#! /bin/bash

mkdir -p ../../zip/ERS
rm ../../zip/ERS/*.zip -f
cd ERS_IDifficulty
zip -r ../../../zip/ERS/ERS_IDifficulty.zip ERS_IDifficulty.txt
cd ../"ERS Mayfly rules"
zip -r ../../../zip/ERS/"ERS Mayfly rules.zip" ERS
