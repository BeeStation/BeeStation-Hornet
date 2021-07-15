#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

wget -O ~/.byond/bin/libauxmos.so "https://github.com/BeeStation/auxmos/releases/download/${AUXMOS_VERSION}/libauxmos.so"
chmod +x ~/.byond/bin/libauxmos.so
ldd ~/.byond/bin/libauxmos.so
