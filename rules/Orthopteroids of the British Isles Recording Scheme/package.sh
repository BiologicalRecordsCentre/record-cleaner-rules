#! /bin/bash

mkdir -p ../../zip/OBIRS
rm ../../zip/OBIRS/*.zip -f
cd OBIRS_IDifficulty
zip -r ../../../zip/OBIRS/OBIRS_IDifficulty.zip OBIRS_IDifficulty.txt
cd ../"OBIRS Grasshopper and Cricket rules"
zip -r ../../../zip/OBIRS/"OBIRS Grasshopper and Cricket rules.zip" OBIRS
