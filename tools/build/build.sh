#!/bin/sh
set -e
cd "$(dirname "$0")"
exec sh ../bootstrap/javascript.sh build.ts "$@"
