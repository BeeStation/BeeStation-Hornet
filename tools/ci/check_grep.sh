#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

echo -e "${BLUE}Checking for map issues...${NC}"

if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
    st=1
fi;
if grep -P '^\ttag = \"icon' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: Tag vars from icon state generation detected in maps, please remove them.${NC}"
    st=1
fi;
if grep -P 'step_[xy]' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: step_x/step_y variables detected in maps, please remove them.${NC}"
    st=1
fi;
if grep -m 1 'pixel_[xy] = 0' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: pixel_x/pixel_y = 0 variables detected in maps, please review to ensure they are not dirty varedits.${NC}"
    st=1
fi;
if grep -P '\td[1-2] =' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: d1/d2 cable variables detected in maps, please remove them.${NC}"
    st=1
fi;
echo -e "${BLUE}Checking for stacked cables...${NC}"
if grep -P '"\w+" = \(\n([^)]+\n)*/obj/structure/cable,\n([^)]+\n)*/obj/structure/cable,\n([^)]+\n)*/area/.+\)' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: Found multiple cables on the same tile, please remove them.${NC}"
    st=1
fi;
if grep '^/area/.+[\{]' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: Variable editted /area path use detected in a map, please replace with a proper area path.${NC}"
    st=1
fi;
if grep -P '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    echo
    echo -e "${RED}ERROR: Base /turf path use detected in maps, please replace a with proper turf path.${NC}"
    st=1
fi;
if grep -P '^/*var/' code/**/*.dm; then
    echo
    echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
    st=1
fi;
if grep -i 'centcomm' code/**/*.dm; then
    echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in code, please remove the extra M(s).${NC}"
    st=1
fi;
if grep -i 'centcomm' _maps/**/*.dm; then
    echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in maps, please remove the extra M(s).${NC}"
    st=1
fi;
if grep -P 'set name\s*=\s*"[\S\s]*![\S\s]*"' code/**/*.dm; then
    echo
    echo -e "${RED}ERROR: Verb with name containing an exclamation point found. These verbs are not compatible with TGUI chat's statpanel or chat box.${NC}"
    st=1
fi;
if ls _maps/*.json | grep -P "[A-Z]"; then
    echo
    echo -e "${RED}ERROR: Uppercase in a map .JSON file detected, these must be all lowercase.${NC}"
    st=1
fi;
for json in _maps/*.json
do
    filepath="_maps/$(jq -r '.map_path' $json)"
    filenames=$(jq -r '.map_file' $json)
    if [[ "$filenames" =~ ^\[ ]] # If it starts with brackets it's a list
    then
        echo "$filenames" | jq -c '.[]' | while read filename
        do
            #Remove quotes
            filename="${filename%\"}"
            filename="${filename#\"}"

            if [ ! -f "$filepath/$filename" ]
            then
                echo -e "${RED}WARNING: Found potential invalid file reference to $filepath/$filename in _maps/$json${NC}"
                st=1
            fi
        done
    else # It's not a list, it's just one file name
        if [ ! -f "$filepath/$filenames" ]
        then
            echo -e "${RED}WARNING: Found potential invalid file reference to $filepath/$filenames in _maps/$json${NC}"
            st=1
        fi
    fi
done
echo -e "${BLUE}Checking for missing newlines...${NC}"
nl='
'
nl=$'\n'
while read f; do
    t=$(tail -c2 "$f"; printf x); r1="${nl}$"; r2="${nl}${r1}"
    if [[ ! ${t%x} =~ $r1 ]]; then
        echo -e "${RED}ERROR: file $f is missing a trailing newline${NC}"
        st=1
    fi;
done < <(find . -type f -not \( -path "./.git/*" -prune \) -exec grep -Iq . {} \; -print)

if [ $st = 0 ]; then
    echo
    echo -e "${GREEN}No errors found using grep!${NC}"
fi;

if [ $st = 1 ]; then
    echo
    echo -e "${RED}Errors found, please fix them and try again.${NC}"
fi;

exit $st
