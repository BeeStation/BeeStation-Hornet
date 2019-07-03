#!/bin/bash
set -e
set -euo pipefail

source dependencies.sh

if [ "$BUILD_TOOLS" = true ]; then
      source ~/.nvm/nvm.sh
      nvm install $NODE_VERSION
      pip3 install --user PyYaml
      pip3 install --user beautifulsoup4
fi;
source ~/.nvm/nvm.sh
nvm install $NODE_VERSION

pip3 install --user PyYaml
pip3 install --user beautifulsoup4

phpenv global $PHP_VERSION
