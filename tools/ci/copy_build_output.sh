#!/bin/bash

mkdir -p \
    $1/icons \
    $1/tgui/public \

cp beestation.dmb beestation.rsc $1/
cp -r icons/* $1/icons/
cp -r tgui/public/* $1/tgui/public/

# Generated directional icons are compiled into the rsc, but rust-g metadata
# readers resolve them from disk relative to the run directory.
if [ -d "tmp/brandish-icons/assets" ]; then
  mkdir -p $1/tmp/brandish-icons/assets
  cp -r tmp/brandish-icons/assets/* $1/tmp/brandish-icons/assets/
fi
