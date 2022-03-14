#! /bin/bash

mkdir -p ../../zip/TRS
rm ../../zip/TRS/*.zip -f
cd TRS_IDifficulty
zip -r ../../../zip/TRS/TRS_IDifficulty.zip TRS_IDifficulty.txt
cd ../"TRS Caddisfly rules"
zip -r ../../../zip/TRS/"TRS Caddisfly rules.zip" TRS
