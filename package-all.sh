#! /bin/bash

SCHEMES=(BMIG BC DRN ERS GBRS LBRS OBIRS PRS TRS UKLS)

for SCHEME in ${SCHEMES[@]}; do
  ./package.sh $SCHEME
done
