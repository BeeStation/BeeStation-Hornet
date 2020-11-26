#!/bin/bash
set -euo pipefail
EXIT_CODE=0

tools/deploy.sh ci_test
rm ci_test/*.dll
mkdir ci_test/config

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt

cd ci_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
DreamDaemon beestation.dmb -close -trusted -verbose -params "log-directory=ci" || EXIT_CODE=$?

#We don't care if extools dies
if [ $EXIT_CODE != 134 ]; then
   if [ $EXIT_CODE != 0 ]; then
      exit $EXIT_CODE
   fi
fi

cd ..
cat ci_test/data/logs/ci/clean_run.lk
