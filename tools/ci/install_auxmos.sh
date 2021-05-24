#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin/auxtools
wget -O ~/.byond/bin/auxtools/libauxmos.so " https://github.com/BeeStation/auxmos/releases/download/$AUXMOS_VERSION/libauxmos.so"
chmod +x ~/.byond/bin/auxtools/libauxmos.so
ldd ~/.byond/bin/auxtools/libauxmos.so
