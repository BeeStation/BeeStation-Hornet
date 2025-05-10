#!/bin/bash
set -e
source dependencies.sh
echo "Downloading BYOND version $BYOND_MAJOR.$BYOND_MINOR"
curl "http://www.byond.com/download/build/$BYOND_MAJOR/$BYOND_MAJOR.${BYOND_MINOR}_byond.zip" -o C:/byond.zip -A "Beestation/1.0 Continuous Integration"
