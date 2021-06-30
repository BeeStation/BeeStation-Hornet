#!/bin/bash

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
# Extracted from the Dockerfile. Change by editing Dockerfile's ARG commands. Otherwise, this is set by Docker's envrionment variables
if [[ -f "Dockerfile" ]]; then
	LIST=($(sed -n 's/.*byond:\([0-9]\+\)\.\([0-9]\+\).*/\1 \2/p' Dockerfile))
	export BYOND_MAJOR=${LIST[0]}
	export BYOND_MINOR=${LIST[1]}
	unset LIST
fi

#rust_g git tag
export RUST_G_VERSION=0.4.7.1

#node version
export NODE_VERSION=12
export NODE_VERSION_PRECISE=12.20.0

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.7
