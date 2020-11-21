#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;	then
    echo "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!"
    st=1
fi;
if grep -P '^\ttag = \"icon' _maps/**/*.dmm;	then
    echo "ERROR: tag vars from icon state generation detected in maps, please remove them."
    st=1
fi;
if grep -P 'step_[xy]' _maps/**/*.dmm;	then
    echo "ERROR: step_x/step_y variables detected in maps, please remove them."
    st=1
fi;
if grep -m 1 'pixel_[xy] = 0' _maps/**/*.dmm;	then
    echo "ERROR: pixel_x/pixel_y = 0 variables detected in maps, please review to ensure they are not dirty varedits."
    st=1
fi;
if grep -P '\td[1-2] =' _maps/**/*.dmm;	then
    echo "ERROR: d1/d2 cable variables detected in maps, please remove them."
    st=1
fi;
echo "Checking for stacked cables"
if grep -P '"\w+" = \(\n([^)]+\n)*/obj/structure/cable,\n([^)]+\n)*/obj/structure/cable,\n([^)]+\n)*/area/.+\)' _maps/**/*.dmm;	then
    echo "found multiple cables on the same tile, please remove them."
    st=1
fi;
if grep '^/area/.+[\{]' _maps/**/*.dmm;	then
    echo "ERROR: Vareditted /area path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep -P '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    echo "ERROR: base /turf path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep -P '^/*var/' code/**/*.dm; then
    echo "ERROR: Unmanaged global var use detected in code, please use the helpers."
    st=1
fi;
if grep -i 'centcomm' code/**/*.dm; then
    echo "ERROR: Misspelling(s) of CENTCOM detected in code, please remove the extra M(s)."
    st=1
fi;
if grep -i 'centcomm' _maps/**/*.dmm; then
    echo "ERROR: Misspelling(s) of CENTCOM detected in maps, please remove the extra M(s)."
    st=1
fi;
if ls _maps/*.json | grep -P "[A-Z]"; then
    echo "ERROR: Uppercase in a map json detected, these must be all lowercase."
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
				echo "WARNING: Found potential invalid file reference to $filepath/$filename in _maps/$json"
				st=1
			fi
		done
	else # It's not a list, it's just one file name
		if [ ! -f "$filepath/$filenames" ]
		then
			echo "WARNING: Found potential invalid file reference to $filepath/$filenames in _maps/$json"
			st=1
		fi
	fi
done

exit $st
