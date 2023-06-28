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

# This section checks for artifacts with map merging
if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
    st=1
fi;
if grep -P 'Merge Conflict Marker' _maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;
if grep -P '/obj/merge_conflict_marker' _maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;

# This section checks for bad varedits in mapping
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

# Example: A tile can only have ONE /obj/machinery/firealarm OR ONE /obj/machinery/firealarm/directional, etc.
DUPES_YES_WALLCHECK=(
	"/obj/effect/spawner/structure/window"
	"/obj/machinery/airalarm"
	"/obj/machinery/firealarm"
	"/obj/machinery/power/apc"
	"/obj/structure/lattice"
	"/obj/machinery/atmospherics/components/binary/circulator" # Since it has PIPING_ONE_PER_TURF flag
	"/obj/machinery/atmospherics/components/trinary" # Since it has PIPING_ONE_PER_TURF flag
	"/obj/machinery/atmospherics/components/unary" # Since it has PIPING_ONE_PER_TURF flag
	"/obj/machinery/door/airlock"
	"/obj/machinery/door/firedoor"
	"/obj/structure/closet"
	"/obj/structure/girder"
	"/obj/structure/table"
)
DUPES_NO_WALLCHECK=(
	"/obj/structure/grille"
)
# These can be duplicated, we only want to do a wall check for them.
ONLY_WALLCHECK=(
	"/obj/structure/window"
)
# The difference being that in this list you can have a /obj/structure/barricade/wooden and
# /obj/structure/barricade/wooden/crude on the same tile here versus in the INCLUSIVE list
DUPES_SUBTYPE_IDENTICAL_YES_WALLCHECK=(
	"/obj/effect/mapping_helpers/airlock"
	"/obj/structure/barricade"
	"/obj/structure/chair"
	"/obj/structure/stairs"
)
DUPES_SUBTYPE_IDENTICAL_NO_WALLCHECK=(
	"/obj/structure/disposalpipe"
)

# This section checks to make sure only one of any type and its decendant subtypes exists on a tile at a time.
CHECK_DUPES=(${DUPES_YES_WALLCHECK[@]} ${DUPES_NO_WALLCHECK[@]})
for TYPEPATH in "${CHECK_DUPES[@]}"
do
	if grep -Pzo "\"\w+\" = \([^)]*?\n${TYPEPATH}[/\w,\n]*?[^)]*?\n${TYPEPATH}[/\w,\n]*?[^)]*?\n/area.+?\)" _maps/**/*.dmm;	then
		echo
		echo -e "${RED}ERROR: Found multiple of type ${TYPEPATH} on the same tile, please remove them.${NC}"
		st=1
	fi;
done

# This section checks to make sure nothing is in walls/closed turfs that aren't supposed to be.
CHECK_WALLS=(${DUPES_YES_WALLCHECK[@]} ${DUPES_SUBTYPE_IDENTICAL_YES_WALLCHECK[@]} ${ONLY_WALLCHECK[@]})
for TYPEPATH in "${CHECK_WALLS[@]}"
do
    if grep -Pzo "\"\w+\" = \([^)]*?\n${TYPEPATH}[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)" _maps/**/*.dmm;	then
		echo
		echo -e "${RED}ERROR: Found ${TYPEPATH} inside a closed turf, please remove them.${NC}"
		st=1
	fi;
done

# This section checks to make sure identical objects of the same typepath do not exist on the same tile
CHECK_IDENTICAL_DUPES=(${DUPES_SUBTYPE_IDENTICAL_YES_WALLCHECK[@]} ${DUPES_SUBTYPE_IDENTICAL_NO_WALLCHECK[@]})
for TYPEPATH in "${CHECK_IDENTICAL_DUPES[@]}"
do
	if grep -Pzo "\"\w+\" = \([^)]*?\n${TYPEPATH}(?<type>[/\w]*),[^)]*?\n${TYPEPATH}\g{type},[^)]*?\n/area/.+\)" _maps/**/*.dmm;	then
		echo
		echo -e "${RED}ERROR: Found multiple IDENTICAL of type ${TYPEPATH} on the same tile, please remove them.${NC}"
		st=1
	fi;
done

# This section checks for miscellaneous mapping errors
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/stairs[/\w,\n]*?[^)]*?\n/turf/open/genturf[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a staircase on top of a gen_turf. Please replace the gen_turf with a proper turf.${NC}"
    st=1
fi;
if grep -Pzo '/obj/machinery/conveyor/inverted[/\w]*?\{\n[^}]*?dir = [1248];[^}]*?\},?\n' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found an inverted conveyor belt with a cardinal dir. Please replace it with a normal conveyor belt.${NC}"
    st=1
fi;
if ls _maps/*.json | grep -P "[A-Z]"; then
    echo
    echo -e "${RED}ERROR: Uppercase in a map .JSON file detected, these must be all lowercase.${NC}"
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

# This section checks for if you've fucked up so bad you're breaking the DMM format
if grep -Pzo '"\w+" = \([^)]*?\n/turf/[/\w,\n]*?[^)]*?\n/turf/[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm; then
	echo
    echo -e "${RED}ERROR: Multiple turfs detected on the same tile! Please choose only one turf!${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/area/.+?,[^)]*?\n/area/.+?\)' _maps/**/*.dmm; then
	echo
    echo -e "${RED}ERROR: Multiple areas detected on the same tile! Please choose only one area!${NC}"
    st=1
fi;

# This section enforces code quality and common misspellings
echo -e "${BLUE}Checking for code issues...${NC}"
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

# Now we lint the json formats
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

# Check for non-515 compatable .proc/ syntax
if grep -P --exclude='__byond_version_compat.dm' '\.proc/' code/**/*.dm; then
    echo
    echo -e "${RED}ERROR: Outdated proc reference use detected in code, please use proc reference helpers.${NC}"
    st=1
fi;

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
done < <(find . -type f -not \( -path "./.git/*" -prune \) -not \( -path "./tgui/.yarn/*" -prune \) -exec grep -Iq . {} \; -print)

if [ $st = 0 ]; then
    echo
    echo -e "${GREEN}No errors found using grep!${NC}"
fi;

if [ $st = 1 ]; then
    echo
    echo -e "${RED}Errors found, please fix them and try again.${NC}"
fi;

exit $st
