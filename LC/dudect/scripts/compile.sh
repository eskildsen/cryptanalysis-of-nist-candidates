#!/bin/bash
CFLAGS="-O2 -std=c11 -Wfatal-errors"
LDFLAGS="-O2 -std=c11"
INCS="-Iinc/"
LIBS="-lm"
OBJS="src/cpucycles.o src/fixture.o src/random.o src/ttest.o src/percentile.o"
SUBMISSIONS=$(find -path './candidates/*/Implementations/crypto_aead/*/*/encrypt.c')
[ ! -d "compiled" ] && mkdir -p "compiled"

for d in $SUBMISSIONS; do
    CANDIDATE=$(echo $d | cut -d'/' -f3)
    SUBMISSION=$(echo $d | cut -d'/' -f6)
    IMPLEMENTATION=$(echo $d | cut -d'/' -f7)
    COMPILED=""
    INCS2="-I${d%encrypt.c}"
    DUDECT_COMPILED="compiled/${CANDIDATE}/dudect_${SUBMISSION}_${IMPLEMENTATION}"

    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    #cc $CFLAGS $INCS -c $d -o $ENCRYPT_COMPILED
    C_FILES=$(find -path "./candidates/${CANDIDATE}/Implementations/crypto_aead/${SUBMISSION}/${IMPLEMENTATION}/*.c")
    for file in $C_FILES; do
        name=$(echo $file | cut -d'/' -f8)
        [[ "$name" = "genkat_aead.c" ]] && continue
        echo "Compiling $file"
        ENCRYPT_COMPILED="${file%.c}.o"
        cc $CFLAGS $INCS -c $file -o $ENCRYPT_COMPILED
        COMPILED="$COMPILED $ENCRYPT_COMPILED"
    done


    echo "Compiling $DUDECT_COMPILED"
    cc $LDFLAGS $INCS $INCS2 -o $DUDECT_COMPILED src/dut.c $OBJS $COMPILED $LIBS
done