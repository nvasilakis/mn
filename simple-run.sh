#!/bin/bash

shopt -s expand_aliases

# This scripts requires some manual steps:
# (step 0.: make sure you have ran setup.sh and download.sh)
# 1. comment *in* the libraries from libs.txt you want to run mininode on
# 2. create a copy of these libraries in libs, but (i) without node_modules and (ii) without any tests (this requires manual effort)
# 3. run this script, inspect diff, collect |diff| via $(wc -l $lib-diff)
# 4. copy node_modules and test, and run `npm t` (or any additional tests)
# (5. repeat with mode = hard)

mode="soft" # +try hard!
alias mininode="node ./mn/src/index.js"

touch results.txt
cat libs.txt | grep -v '#' | while read line
do
  lib=$(echo $line | cut -f 1 -d ' ')
  # seed=$(echo $line | cut -f 2 -d ' ')
  echo "\n\n$lib\n" >> ./results.txt
  if [[ -e $lib ]]; then
    mininode $lib --mode $mode --destination $lib-$mode 2> $lib-$mode-errors.txt
    diff -rwyB --suppress-common-lines $lib $lib-$mode > $lib-$mode-diff.txt
    # wc -l $lib-diff
    cp -r $(echo $lib/node_modules | sed 's;-notest;;') $lib-$mode
    # find $lib/ -name '*.js'
    # diff -r --no-dereference --ignore-all-space ./mininode $lib >> ./results.txt
  else
    echo $lib not found
  fi
done
