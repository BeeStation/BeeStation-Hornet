#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin/auxtools
wget -O ~/.byond/bin/auxtools/linda_libauxmos.so "https://github.com/BeeStation/auxmos/releases/download/0.1/linda_libauxmos.so"
chmod +x ~/.byond/bin/auxtools/linda_libauxmos.so
ldd ~/.byond/bin/auxtools/linda_libauxmos.so
