#! /bin/bash

SCHEMES=(BMIG BC DRN ERS GBRS LBRS OBIRS PRS TRS UKLS)

DIRECTORIES=( \
  "British Myriapod and Isopod Group" \
  "Butterfly Conservation" \
  "Dragonfly Recording Scheme" \
  "Ephemeroptera Recording Scheme" \
  "Ground Beetle Recording Scheme" \
  "Larger Brachycera Recording Scheme" \
  "Orthopteroids of the British Isles Recording Scheme" \
  "Plecoptera Recording Scheme" \
  "Trichoptera Recording Scheme" \
  "UK Ladybird Survey" \
)

# Ensure scheme is passed as argument
if [ -z $1 ]; then
  echo "Call script with a scheme abbreviation as an argument."
  exit
fi

# Convert to uppercase
SCHEME=$(echo "$1" | tr [:lower:] [:upper:])

# Find index of entered scheme in array to obtain corresponding folder.
for i in ${!SCHEMES[@]}; do
  if [ "$SCHEME" = "${SCHEMES[$i]}" ]; then
    DIRECTORY="${DIRECTORIES[$i]}"
    break
  fi
done

# Package the entered scheme.
if [ "$DIRECTORY" ]; then
  # Ensure folder exists
  mkdir -p "zip/$SCHEME"
  # Remove old files
  rm "zip/$SCHEME/"* -f

  # Make zip files
  cd "rules/$DIRECTORY"
  ./package.sh
  cd ../..

  # Update index.txt
  cp "rules/$DIRECTORY/index.txt" "zip/$SCHEME"
  # Set default basepath if not set in environment.
  if [ -z "$BASEPATH" ]; then
    BASEPATH="http://data.nbn.org.uk/recordcleaner/rules"
  fi
  # Get date
  DATE=$(date +%d/%m/%Y)
  # Substitute template values using ! as separator since basepath contains '/'.
  sed -i "s!<basepath>!$BASEPATH!; s!<date>!$DATE!" "zip/$SCHEME/index.txt"

else
  echo "Unknown scheme: $SCHEME"
fi


