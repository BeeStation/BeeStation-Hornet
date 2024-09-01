#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar extglob

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

# check for ripgrep
if command -v rg >/dev/null 2>&1; then
	grep=rg
	pcre2_support=1
	if [ ! rg -P '' >/dev/null 2>&1 ] ; then
		pcre2_support=0
	fi
	code_files="code/**/**.dm"
	map_files="_maps/**/**.dmm"
	shuttle_map_files="_maps/shuttles/**.dmm"
	code_x_515="code/**/!(__byond_version_compat).dm"
else
	pcre2_support=0
	grep=grep
	code_files="-r --include=code/**/**.dm"
	map_files="-r --include=_maps/**/**.dmm"
	shuttle_map_files="-r --include=_maps/shuttles/**.dmm"
	code_x_515="-r --include=code/**/!(__byond_version_compat).dm"
fi

echo -e "${BLUE}Using grep provider at $(which $grep)${NC}"

part=0
section() {
	echo -e "${BLUE}Checking for $1${NC}..."
	part=0
}

part() {
	part=$((part+1))
	padded=$(printf "%02d" $part)
	echo -e "${GREEN} $padded- $1${NC}"
}

section "map issues"

part "TGM"
if $grep -U '^".+" = \(.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
    st=1
fi;
part "comments"
if $grep '//' $map_files | $grep -v '//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE' | $grep -v 'name|desc'; then
	echo
	echo -e "${RED}ERROR: Unexpected commented out line detected in this map file. Please remove it.${NC}"
	st=1
fi;
part "iconstate tags"
if $grep '^\ttag = "icon' $map_files;	then
	echo
    echo -e "${RED}ERROR: Tag vars from icon state generation detected in maps, please remove them.${NC}"
    st=1
fi;
part "invalid map procs"
if $grep '(new|newlist|icon|matrix|sound)\(.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Using unsupported procs in variables in a map file! Please remove all instances of this.${NC}"
	st=1
fi;
part "common spelling mistakes"
if $grep -i 'nanotransen' $map_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of Nanotrasen detected in maps, please remove the extra N(s).${NC}"
    st=1
fi;
if $grep 'NanoTrasen' $map_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of Nanotrasen detected in maps, please uncapitalize the T(s).${NC}"
    st=1
fi;
if $grep -i'centcomm' $map_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in maps, please remove the extra M(s).${NC}"
    st=1
fi;
if $grep -i'eciev' $map_files; then
	echo
    echo -e "${RED}ERROR: Common I-before-E typo detected in maps.${NC}"
    st=1
fi;
if grep -P 'Merge Conflict Marker' _maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;
# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
if grep -P '/obj/merge_conflict_marker' _maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;
if grep -P 'step_[xy]' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: step_x/step_y variables detected in maps, ${HINT_REMOVE}"
    st=1
fi;
if grep -m 1 'pixel_[xy] = 0' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: pixel_x/pixel_y = 0 variables detected in maps, please review to ensure they are not dirty varedits.${NC}"
    st=1
fi;
if grep -P '\td[1-2] =' _maps/**/*.dmm;    then
    echo
    echo -e "${RED}ERROR: d1/d2 cable variables detected in maps, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/effect/mapping_helpers/simple_pipes(?<type>[/\w]*),[^)]*?\n/obj/effect/mapping_helpers/simple_pipes\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple idendical simple_pipes mapping helpers on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/atmospherics(?<type>[/\w]*),[^)]*?\n/obj/machinery/atmospherics\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple idendical atmospherics machines or pipes on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/lattice[/\w,\n]*?[^)]*?\n/obj/structure/lattice[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple lattices on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/barricade(?<type>[/\w]*),[^)]*?\n/obj/structure/barricade\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical barricades on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/table(?<type>[/\w]*),[^)]*?\n/obj/structure/table\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical tables on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/chair(?<type>[/\w]*),[^)]*?\n/obj/structure/chair\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical chairs on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/door/airlock[/\w,\n]*?[^)]*?\n/obj/machinery/door/airlock[/\w,\n]*?[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple airlocks on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/door/firedoor[/\w,\n]*?[^)]*?\n/obj/machinery/door/firedoor[/\w,\n]*?[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple firelocks on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/closet(?<type>[/\w]*),[^)]*?\n/obj/structure/closet\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical closets on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/grille(?<type>[/\w]*),[^)]*?\n/obj/structure/grille\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical grilles on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/girder(?<type>[/\w]*),[^)]*?\n/obj/structure/girder\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical girders on the same tile, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/stairs(?<type>[/\w]*),[^)]*?\n/obj/structure/stairs\g{type},[^)]*?\n/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found multiple identical stairs on the same tile, ${HINT_REMOVE}"
	st=1
fi;
echo -e "${BLUE}Checking for malformed files...${NC}"
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
echo -e "${BLUE}Checking for things inside of walls...${NC}"
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/lattice[/\w,\n]*?[^)]*?\n/turf/closed/wall[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked with a wall, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/lattice[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked within a wall, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/structure/window[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found a window stacked within a wall, ${HINT_REMOVE}"
    st=1
fi;
if grep -Pzo '"\w+" = \([^)]*?\n/obj/machinery/door/airlock[/\w,\n]*?[^)]*?\n/turf/closed[/\w,\n]*?[^)]*?\n/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo -e "${RED}ERROR: Found an airlock stacked within a wall, ${HINT_REMOVE}"
    st=1
fi;
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

section "whitespace issues"
part "space indentation"
if $grep '(^ {2})|(^ [^ * ])|(^    +)' $code_files; then
	echo
    echo -e "${RED}ERROR: Space indentation detected, please use tab indentation.${NC}"
    st=1
fi;
part "mixed indentation"
if $grep '^\t+ [^ *]' $code_files; then
	echo
    echo -e "${RED}ERROR: Mixed <tab><space> indentation detected, please stick to tab indentation.${NC}"
    st=1
fi;

section "unit tests"
unit_test_files="code/modules/unit_tests/**/**.dm"
part "mob/living/carbon/human usage"
if $grep 'allocate\(/mob/living/carbon/human[,\)]' $unit_test_files ||
	$grep 'new /mob/living/carbon/human\s?\(' $unit_test_files ||
	$grep 'var/mob/living/carbon/human/\w+\s?=\s?new' $unit_test_files ; then
	echo
	echo -e "${RED}ERROR: Usage of mob/living/carbon/human detected in a unit test, please use mob/living/carbon/human/consistent.${NC}"
	st=1
fi;

section "common mistakes"
part "global vars"
if $grep '^/*var/' $code_files; then
	echo
	echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
	st=1
fi;

part "can_perform_action argument check"
if $grep 'can_perform_action\(\s*\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Found a can_perform_action() proc with improper arguments.${NC}"
	st=1
fi;

part "src as a trait source" # ideally we'd lint / test for ANY datum reference as a trait source, but 'src' is the most common.
if $grep -i '(add_trait|remove_trait)\(.+,\s*.+,\s*src\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Using 'src' as a trait source. Source must be a string key - dont't use references to datums as a source, perhaps use 'REF(src)'.${NC}"
	st=1
fi;
if $grep -i '(add_traits|remove_traits)\(.+,\s*src\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Using 'src' as trait sources. Source must be a string key - dont't use references to datums as sources, perhaps use 'REF(src)'.${NC}"
	st=1
fi;

part "ensure proper lowertext usage"
# lowertext() is a BYOND-level proc, so it can be used in any sort of code... including the TGS DMAPI which we don't manage in this repository.
# basically, we filter out any results with "tgs" in it to account for this edgecase without having to enforce this rule in that separate codebase.
# grepping the grep results is a bit of a sad solution to this but it's pretty much the only option in our existing linter framework
if $grep -i 'lowertext\(.+\)' $code_files | $grep -v 'UNLINT\(.+\)' | $grep -v '\/modules\/tgs\/'; then
	echo
	echo -e "${RED}ERROR: Found a lowertext() proc call. Please use the LOWER_TEXT() macro instead. If you know what you are doing, wrap your text (ensure it is a string) in UNLINT().${NC}"
	st=1
fi;

part "balloon_alert sanity"
if $grep 'balloon_alert\(".*"\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Found a balloon alert with improper arguments.${NC}"
	st=1
fi;

if $grep 'balloon_alert(.*<span)' $code_files; then
	echo
	echo -e "${RED}ERROR: Balloon alerts should never contain spans.${NC}"
	st=1
fi;

part "update_icon_updates_onmob element usage"
if $grep 'AddElement\(/datum/element/update_icon_updates_onmob.+ITEM_SLOT_HANDS' $code_files; then
	echo
	echo -e "${RED}ERROR: update_icon_updates_onmob element automatically updates ITEM_SLOT_HANDS, this is redundant and should be removed.${NC}"
	st=1
fi;

part "common spelling mistakes"
if $grep -i 'centcomm' $code_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in code, please remove the extra M(s).${NC}"
    st=1
fi;
if $grep -ni 'nanotransen' $code_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of Nanotrasen detected in code, please remove the extra N(s).${NC}"
    st=1
fi;
if $grep 'NanoTrasen' $code_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of Nanotrasen detected in code, please uncapitalize the T(s).${NC}"
    st=1
fi;
if $grep -i'eciev' $code_files; then
	echo
    echo -e "${RED}ERROR: Common I-before-E typo detected in code.${NC}"
    st=1
fi;

part "tgui stat mistakes"

if grep -P 'set name\s*=\s*"[\S\s]*![\S\s]*"' code/**/*.dm; then
    echo
    echo -e "${RED}ERROR: Verb with name containing an exclamation point found. These verbs are not compatible with TGUI chat's statpanel or chat box.${NC}"
    st=1
fi;

part "map json naming"
if ls _maps/*.json | $grep "[A-Z]"; then
	echo
    echo -e "${RED}ERROR: Uppercase in a map .JSON file detected, these must be all lowercase.${NC}"
    st=1
fi;
part "map json sanity"
for json in _maps/*.json
do
    map_path=$(jq -r '.map_path' $json)
    while read map_file; do
        filename="_maps/$map_path/$map_file"
        if [ ! -f $filename ]
        then
			echo
            echo -e "${RED}ERROR: Found an invalid file reference to $filename in _maps/$json ${NC}"
            st=1
        fi
    done < <(jq -r '[.map_file] | flatten | .[]' $json)
done

part "updatepaths validity"
missing_txt_lines=$(find tools/UpdatePaths/Scripts -type f ! -name "*.txt" | wc -l)
if [ $missing_txt_lines -gt 0 ]; then
    echo
    echo -e "${RED}ERROR: Found an UpdatePaths File that doesn't end in .txt! Please add the proper file extension!${NC}"
    st=1
fi;

number_prefix_lines=$(find tools/UpdatePaths/Scripts -type f | wc -l)
valid_number_prefix_lines=$(find tools/UpdatePaths/Scripts -type f | $grep -P "\d+_(.+)" | wc -l)
if [ $valid_number_prefix_lines -ne $number_prefix_lines ]; then
    echo
    echo -e "${RED}ERROR: Detected an UpdatePaths File that doesn't start with the PR number! Please add the proper number prefix!${NC}"
    st=1
fi;

section "515 Proc Syntax"
part "proc ref syntax"
if $grep '\.proc/' $code_x_515 ; then
    echo
    echo -e "${RED}ERROR: Outdated proc reference use detected in code, please use proc reference helpers.${NC}"
    st=1
fi;

if [ "$pcre2_support" -eq 1 ]; then
	section "regexes requiring PCRE2"
	part "empty variable values"
	if $grep -PU '{\n\t},' $map_files; then
		echo
		echo -e "${RED}ERROR: Empty variable value list detected in map file. Please remove the curly brackets entirely.${NC}"
		st=1
	fi;
	part "to_chat sanity"
	if $grep -P 'to_chat\((?!.*,).*\)' $code_files; then
		echo
		echo -e "${RED}ERROR: to_chat() missing arguments.${NC}"
		st=1
	fi;
	part "timer flag sanity"
	if $grep -P 'addtimer\((?=.*TIMER_OVERRIDE)(?!.*TIMER_UNIQUE).*\)' $code_files; then
		echo
		echo -e "${RED}ERROR: TIMER_OVERRIDE used without TIMER_UNIQUE.${NC}"
		st=1
	fi
	part "trailing newlines"
	if $grep -PU '[^\n]$(?!\n)' $code_files; then
		echo
		echo -e "${RED}ERROR: File(s) with no trailing newline detected, please add one.${NC}"
		st=1
	fi
	part "improper atom initialize args"
	if $grep -P '^/(obj|mob|turf|area|atom)/.+/Initialize\((?!mapload).*\)' $code_files; then
		echo
		echo -e "${RED}ERROR: Initialize override without 'mapload' argument.${NC}"
		st=1
	fi;
	part "shuttle area checker"
	if $grep -PU '(},|\/obj|\/mob|\/turf\/(?!template_noop).+)[^()]+\/area\/template_noop\)' $shuttle_map_files; then
		echo
		echo -e "${RED}ERROR: Shuttle has objs or turfs in a template_noop area. Please correct their areas to a shuttle subtype.${NC}"
		st=1
fi;
else
	echo -e "${RED}pcre2 not supported, skipping checks requiring pcre2"
	echo -e "if you want to run these checks install ripgrep with pcre2 support.${NC}"
fi

if [ $st = 0 ]; then
    echo
    echo -e "${GREEN}No errors found using $grep!${NC}"
fi;

if [ $st = 1 ]; then
    echo
    echo -e "${RED}Errors found, please fix them and try again.${NC}"
fi;

exit $st
