#!/bin/bash
set -euo pipefail

source dependencies.sh

if [[ -e ~/.nvm/nvm.sh ]]; then
	source ~/.nvm/nvm.sh
	nvm install $NODE_VERSION_LTS
	nvm use $NODE_VERSION_LTS
fi
