#! /bin/bash

rm ../../zip/BC/*.zip
cd BC_IDifficulty
zip -r ../../../zip/BC/BC_IDifficulty.zip BC_IDifficulty.txt
cd ../"BC Butterfly rules"
zip -r ../../../zip/BC/"BC Butterfly rules.zip" BC
cd ../NMRS_IDifficulty
zip -r ../../../zip/BC/NMRS_IDifficulty.zip NMRS_IDifficulty.txt
cd ../"NMRS Moth rules"
zip -r ../../../zip/BC/"NMRS Moth rules.zip" NMRS