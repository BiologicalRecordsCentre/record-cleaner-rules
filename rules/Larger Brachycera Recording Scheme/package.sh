#! /bin/bash

mkdir -p ../../zip/LBRS
rm ../../zip/LBRS/*.zip -f
cd LBRS_IDifficulty
zip -r ../../../zip/LBRS/LBRS_IDifficulty.zip LBRS_IDifficulty.txt
cd ../"LBRS Larger Brachycera rules"
zip -r ../../../zip/LBRS/"LBRS Larger Brachycera rules.zip" LBRS
