#!/bin/bash
set -euo pipefail

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0


echo -e "${BLUE}Checking for proc name violations...${NC}"

# Check for inconsistent capitalisation
# Allows full capitalisation within sections (proc/get_RGB)
# Allows full capitalisation (proc/REF)
# Disallows inconsistent capitalisation (proc/Ref, prof/ReF)
regex_path_name="^\s*(?:\/\w+)*\/?proc\/((?:[a-z]+[A-Z]+[a-z]*_|[a-z]*[A-Z]+[a-z]+_|[A-Z]+[a-z]+[A-Z]+_)+\w*|\w*_(?:[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)|[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)+\("

for code in code/**/*.dm
do
	if [[ code =~ "LINT_PATHNAME_IGNORE"]]
	then
		continue
	fi
	if [[ code =~ $regex_path_name]] # If it starts with brackets it's a list
    then
		echo "The proc ${BASH_REMATCH[1]} contains upper-case letters when it should use snake_case."
		st=1
    fi
done

exit $st
