#!/usr/bin/env python3
"""Count /obj/machinery/power/apc objects with areastring vars in a .dmm file."""

import os
import re
import sys

def count_apcs(filepath):
    with open(filepath) as f:
        content = f.read()

    apc_block = re.compile(r'/obj/machinery/power/apc[^{]*\{[^}]*\}', re.DOTALL)
    areastring_block = re.compile(r'/obj/machinery/power/apc[^{]*\{[^}]*areastring[^}]*\}', re.DOTALL)

    total = apc_block.findall(content)
    with_areastring = areastring_block.findall(content)

    print(f"File: {filepath}")
    print(f"Total APC objects: {len(total)}")
    print(f"APCs with areastring: {len(with_areastring)}")
    print(f"APCs without areastring: {len(total) - len(with_areastring)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file.dmm> [file2.dmm ...]")
        sys.exit(1)
    for path in sys.argv[1:]:
        if not os.path.isfile(path):
            print(f"Error: File not found: {path}", file=sys.stderr)
            continue
        count_apcs(path)
        if len(sys.argv) > 2:
            print()
