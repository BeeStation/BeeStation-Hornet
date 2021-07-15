#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

#mkdir -p ~/.byond/bin/auxtools
wget -O ../../auxtools/libauxmos.so "https://github.com/BeeStation/auxmos/releases/download/${AUXMOS_VERSION}/libauxmos.so"
chmod +x ../../auxtools/libauxmos.so
ldd ../../auxtools/libauxmos.so
