#!/bin/bash
LDFLAGS="-std=c99 -Wall -Wextra -Wshadow -O2 --disable-shared"
INCS="-Iinc/"
LIBS="-lm"
OBJS="src/random.o"
SUBMISSIONS=$(find -path './candidates/*/Implementations/crypto_aead/*/*/encrypt.o')
[ ! -d "compiled" ] && mkdir -p "compiled"

for d in $SUBMISSIONS; do
    CANDIDATE=$(echo $d | cut -d'/' -f3)
    SUBMISSION=$(echo $d | cut -d'/' -f6)
    IMPLEMENTATION=$(echo $d | cut -d'/' -f7)
    COMPILED=""
    INCS2="-I${d%encrypt.o}"
    AFL_COMPILED="compiled/${CANDIDATE}/afl_${SUBMISSION}_${IMPLEMENTATION}"

    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    O_FILES=$(find -path "./candidates/${CANDIDATE}/Implementations/crypto_aead/${SUBMISSION}/${IMPLEMENTATION}/*.o")
    for file in $O_FILES; do
        name=$(echo $file | cut -d'/' -f8)
        [[ "$name" = "genkat_aead.o" ]] && continue
        COMPILED="$COMPILED $file"
    done

    echo "Compiling $AFL_COMPILED"
    afl-gcc $LDFLAGS $INCS $INCS2 -o $AFL_COMPILED src/afl.c $OBJS $COMPILED $LIBS
done