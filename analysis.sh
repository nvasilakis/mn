#!/bin/bash
#set -x
shopt -s expand_aliases

alias mininode="node ./mn/src/index.js"
rm -rf runs2
rm -rf logs
mkdir runs2
mkdir logs
logs="logs"

function check() (
    dir=${PWD}/${logs}/failed.txt
    cd runs2/$1
    if [ ! -e 'node_modules' ]; then
        npm install > "/dev/null" 2>&1
    fi
    cp -r node_modules ../$1_soft
    cp -r node_modules ../$1_hard
    v=$(npm test 2>&1) 
    if [ $? -ne 0 ]; then
        echo $1_normal >>$dir
        echo $v >>$dir
    fi
    # run local
    cd ../$1_soft
    v=$(npm test 2>&1) 
    if [ $? -ne 0 ]; then
        echo $1_soft >> $dir
        echo $v >> $dir
    fi

    cd ../$1_hard
    v=$(npm test 2>&1) 
    if [ $? -ne 0 ]; then
        echo $1_hard >>$dir
        echo $v >> $dir
    fi
)

cat libs.txt | grep -v '#' | while read line
do
    #line=$1
    array=( "soft" "hard")
    lib=$(echo $line | cut -f 1 -d ' ')
    seed=$(echo $line | cut -f 2 -d ' ')
    cp -r $lib runs2/
    nlib=$(echo $lib | sed 's;\.\/libs\/;;')
    nseed=$(echo $seed | sed 's;\.\/libs\/;;')
    for i in "${array[@]}"
    do
        mode=$i
        fname=${nlib}_${mode}
        echo "Running ${nlib} $mode"
        # clean the folder 
        log=$(mininode runs2/$nlib --seeds $seed --mode $mode --destination runs2/${fname} 2>&1)
        res=$?
        if [ ${res} -ne 0 ]; then
            echo $fname >> ${logs}/mini_failed.txt
            echo $log > ${logs}/mini_$fname
        else
            echo $fname >> ${logs}/mini_pass.txt
        fi
        diff -rwyB --suppress-common-lines ${lib} runs2/$fname >           runs2/$fname/results.txt
    done
    # run the tests 
    if [ ${res} == '0' ]; then
        check ${nlib}
    fi
done
echo "output is in logs/"
