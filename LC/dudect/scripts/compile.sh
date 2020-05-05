#!/bin/sh
CFLAGS="-O2 -std=c11"
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
    ENCRYPT_COMPILED="${d%.c}.o"
    INCS2="-I${d%encrypt.c}"
    DUDECT_COMPILED="compiled/${CANDIDATE}/dudect_${SUBMISSION}_${IMPLEMENTATION}"

    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    echo "Compiling $d"
    cc $CFLAGS $INCS -c $d -o $ENCRYPT_COMPILED
    echo "Compiling $DUDECT_COMPILED"
    cc $LDFLAGS $INCS $INCS2 -o $DUDECT_COMPILED src/dut.c $OBJS $ENCRYPT_COMPILED $LIBS
done