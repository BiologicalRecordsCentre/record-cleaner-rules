#! /bin/bash

mkdir -p ../../zip/UKLS
rm ../../zip/UKLS/*.zip -f
cd UKLS_IDifficulty
zip -r ../../../zip/UKLS/UKLS_IDifficulty.zip UKLS_IDifficulty.txt
cd ../"UKLS Ladybird rules"
zip -r ../../../zip/UKLS/"UKLS Ladybird rules.zip" UKLS
