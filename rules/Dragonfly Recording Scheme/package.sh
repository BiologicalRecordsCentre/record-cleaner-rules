#! /bin/bash

mkdir -p ../../zip/DRN
rm ../../zip/DRN/*.zip -f
cd DRN_IDifficulty
zip -r ../../../zip/DRN/DRN_IDifficulty.zip DRN_IDifficulty.txt
cd ../"DRN Odonata Rules"
zip -r ../../../zip/DRN/"DRN Odonata Rules.zip" DRN
