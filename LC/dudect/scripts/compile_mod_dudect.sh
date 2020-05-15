#!/bin/bash
LDFLAGS="-std=c99 -Wall -Wextra -Wshadow -O2"
INCS="-Iinc/"
LIBS="-lm"
OBJS="src/cpucycles.o src/random.o "
SUBMISSIONS=$(find -path './candidates/*/Implementations/crypto_aead/*/mod/encrypt.o')
[ ! -d "compiled" ] && mkdir -p "compiled"

for d in $SUBMISSIONS; do
    CANDIDATE=$(echo $d | cut -d'/' -f3)
    SUBMISSION=$(echo $d | cut -d'/' -f6)
    IMPLEMENTATION=$(echo $d | cut -d'/' -f7)
    COMPILED=""
    INCS2="-I${d%encrypt.o}"
    DUDECT_COMPILED="compiled/${CANDIDATE}/dudect_${SUBMISSION}_${IMPLEMENTATION}"

    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    O_FILES=$(find -path "./candidates/${CANDIDATE}/Implementations/crypto_aead/${SUBMISSION}/${IMPLEMENTATION}/*.o")
    for file in $O_FILES; do
        name=$(echo $file | cut -d'/' -f8)
        [[ "$name" = "genkat_aead.o" ]] && continue
        COMPILED="$COMPILED $file"
    done

    echo "Compiling $DUDECT_COMPILED"
    gcc-5 $LDFLAGS $INCS $INCS2 -o $DUDECT_COMPILED src/afl.c $OBJS $COMPILED $LIBS
done