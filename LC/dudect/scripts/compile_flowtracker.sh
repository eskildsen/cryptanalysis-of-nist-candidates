#!/bin/bash
PATH=$PATH:/mnt/c/Users/Eske/Desktop/llvm-3.7.1.src/build/Release+Asserts/bin
INCS="-Iinc/"
SUBMISSIONS=$(find -path './candidates/*/Implementations/crypto_aead/*/*/encrypt.c')
[ ! -d "compiled" ] && mkdir -p "compiled"

for d in $SUBMISSIONS; do
    CANDIDATE=$(echo $d | cut -d'/' -f3)
    SUBMISSION=$(echo $d | cut -d'/' -f6)
    IMPLEMENTATION=$(echo $d | cut -d'/' -f7)
    FLOWTRACKER_COMPILED="compiled/${CANDIDATE}/flowtracker_${SUBMISSION}_${IMPLEMENTATION}"
    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    BC="${d%.c}.bc"

    echo "Compiling $d"
    clang -emit-llvm $INCS -c -g $d -o $BC
    opt -instnamer -mem2reg $BC > $FLOWTRACKER_COMPILED
done