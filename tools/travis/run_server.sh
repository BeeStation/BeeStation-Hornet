#!/bin/bash
set -euo pipefail
EXIT_CODE=0

tools/deploy.sh travis_test
mkdir travis_test/config

#test config
cp tools/travis/travis_config.txt travis_test/config/config.txt

cd travis_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
DreamDaemon beestation.dmb -close -trusted -verbose -params "test-run&log-directory=travis" || EXIT_CODE=$?

#We don't care if extools dies
if [ $EXIT_CODE != 134 ]; then
   if [ $EXIT_CODE != 0 ]; then
      exit $EXIT_CODE
   fi
fi

cd ..
cat travis_test/data/logs/travis/clean_run.lk
