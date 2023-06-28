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

# This section checks to make sure only one of any type and its decendant subtypes exists on a tile at a time.
ONLY_ONE_INCLUDE_SUBTYPE = ( "/obj/structure/lattice", "/obj/machinery/power/apc", "/obj/machinery/airalarm", "/obj/machinery/firealarm", "/obj/effect/spawner/structure/window")
for TYPEPATH in "${ONLY_ONE_INCLUDE_SUBTYPE}"
do
	GREP_STRING = "\"\w+\" = \([^)]*?\n${TYPE_PATH}[/\w,\n]*?[^)]*?\n${TYPE_PATH}[/\w,\n]*?[^)]*?\n/area.+?\)"
	if grep -Pzo $GREP_STRING _maps/**/*.dmm;	then
		echo
		echo -e "${RED}ERROR: Found multiple of type ${TYPEPATH} on the same tile, please remove them.${NC}"
		st=1
	fi;
done
# if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/power/apc[/\w,\n]*?[^)]*?\n/obj/machinery/power/apc[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
# 	echo
#     echo -e "${RED}ERROR: Found multiple APCs on the same tile, please remove them.${NC}"
#     st=1
# fi;
# if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/airalarm[/\w,\n]*?[^)]*?\n/obj/machinery/airalarm[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
# 	echo
#     echo -e "${RED}ERROR: Found multiple air alarms on the same tile, please remove them.${NC}"
#     st=1
# fi;
# if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/firealarm[/\w,\n]*?[^)]*?\n/obj/machinery/firealarm[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
# 	echo
#     echo -e "${RED}ERROR: Found multiple fire alarms on the same tile, please remove them.${NC}"
#     st=1
# fi;
# if grep -Pzo '"\w+" = \([^)]*?\n/obj/effect/spawner/structure/window[/\w,\n]*?[^)]*?\n/obj/effect/spawner/structure/window[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
# 	echo
#     echo -e "${RED}ERROR: Found multiple window spawners on the same tile, please remove them.${NC}"
#     st=1
# fi;

# This section checks to make sure identical objects of the same typepath do not exist on the same tile
if grep -Pzo '"\w+" = \([^)]*?\n/obj/effect/mapping_helpers/airlock(?<type>[/\w]*),[^)]*?\n/obj/effect/mapping_helpers/airlock\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical airlock mapping helpers on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/disposalpipe(?<type>[/\w]*),[^)]*?\n/obj/structure/disposalpipe\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical disposal components on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/barricade(?<type>[/\w]*),[^)]*?\n/obj/structure/barricade\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical barricades on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/table(?<type>[/\w]*),[^)]*?\n/obj/structure/table\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical tables on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/chair(?<type>[/\w]*),[^)]*?\n/obj/structure/chair\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical chairs on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/door/airlock[/\w,\n]*?[^)]*?\n/obj/machinery/door/airlock[/\w,\n]*?[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple airlocks on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/door/firedoor[/\w,\n]*?[^)]*?\n/obj/machinery/door/firedoor[/\w,\n]*?[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple firelocks on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/closet(?<type>[/\w]*),[^)]*?\n/obj/structure/closet\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical closets on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/grille(?<type>[/\w]*),[^)]*?\n/obj/structure/grille\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical grilles on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/girder(?<type>[/\w]*),[^)]*?\n/obj/structure/girder\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical girders on the same tile, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/stairs(?<type>[/\w]*),[^)]*?\n/obj/structure/stairs\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical stairs on the same tile, please remove them.${NC}"
	st=1
fi;

# This section checks for things in walls that are not supposed to be
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/lattice[/\w,\n]*?[^)]*?\n/turf/closed/wall[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked with a wall, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/lattice[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked within a wall, please remove them.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/window[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a window stacked within a wall, please remove it.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/effect/spawner/structure/window[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a window spawner stacked within a wall, please remove it.${NC}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/door/airlock[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found an airlock stacked within a wall, please remove it.${NC}"
    st=1
fi;

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
