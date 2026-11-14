#!/bin/bash

#Run this in the repo root after compiling
#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

#second arg is working directory if necessary
if [[ $# -eq 2 ]] ; then
  cd $2
fi

mkdir -p \
    $1/_maps \
	$1/auxtools \
	$1/code/datums/greyscale/json_configs \
	$1/data/spritesheets \
	$1/icons \
    $1/sound/runtime \
    $1/strings \
    $1/tgui/public \

if [ -d ".git" ]; then
  mkdir -p $1/.git/logs
  cp -r .git/logs/* $1/.git/logs/
fi

cp beestation.dmb beestation.rsc $1/
cp -r _maps/* $1/_maps/
cp -r code/datums/greyscale/json_configs/* $1/code/datums/greyscale/json_configs/
cp -r icons/* $1/icons/
cp -r sound/runtime/* $1/sound/runtime/
cp -r strings/* $1/strings/
cp -r tgui/public/* $1/tgui/public/

# Generated directional icons are compiled into the rsc, but rust-g metadata
# readers resolve them from disk relative to the run directory.
if [ -d "tmp/brandish-icons/assets" ]; then
  mkdir -p $1/tmp/brandish-icons/assets
  cp -r tmp/brandish-icons/assets/* $1/tmp/brandish-icons/assets/
fi

#remove .dm files from _maps

#this regrettably doesn't work with windows find
#find $1/_maps -name "*.dm" -type f -delete

#dlls on windows
cp rust_g* $1/ || true
