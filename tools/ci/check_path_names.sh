#!/bin/bash
set -euo pipefail

# ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

echo -e "${BLUE}Checking for proc name violations...${NC}"

# Regex to match inconsistent capitalization in proc names
regex_path_name="^\s*(?:\/\w+)*\/?proc\/((?:[a-z]+[A-Z]+[a-z]*_|[a-z]*[A-Z]+[a-z]+_|[A-Z]+[a-z]+[A-Z]+_)+\w*|\w*_(?:[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)|[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)+\("

# Find and loop through every .dm file in the code/ directory
find code/ -type f -name "*.dm" | while IFS= read -r file; do
    # Check if the file contains the string "LINT_PATHNAME_IGNORE"
    if grep -q "LINT_PATHNAME_IGNORE" "$file"; then
        continue
    fi

    # Run the regex against the contents of the file and store the result
    matches=$(grep -Po "$regex_path_name" "$file" || true)

    if [[ -n "$matches" ]]; then
        echo -e "${RED}Violation found in file: $file${NC}"
        echo "$matches"
        st=1
    fi
done

exit $st
