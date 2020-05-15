#!/bin/bash
CFLAGS="-std=c99 -Wall -Wextra -Wshadow -O2 -Wfatal-errors"
COMPILER="gcc-5"
[[ "$1" == "afl" ]] && COMPILER="/home/morten/Desktop/uni/antifuzz/AFL/afl-gcc"
[[ "$1" == "ctgrind" ]] && CFLAGS="${CFLAGS} -ggdb"
[[ "$1" == "dudect" ]] && CFLAGS="${CFLAGS} " #-fsanitize=address,undefined" dissabled this because it is incompatible with stdbuf and because as it does roughly the same as valgrind and therefore should not impact correctness
INCS="-Iinc/"
C_FILES=$(find -path './candidates/*/Implementations/crypto_aead/*/*/*.c')
[ ! -d "compiled" ] && mkdir -p "compiled"

for file in $C_FILES; do
    CANDIDATE=$(echo $dfile | cut -d'/' -f3)
    NAME=$(echo $file | cut -d'/' -f8)
    [[ "$name" = "genkat_aead.c" ]] && continue
    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    echo "Compiling $file"
    ENCRYPT_COMPILED="${file%.c}.o"
    $COMPILER $CFLAGS $INCS -c $file -o $ENCRYPT_COMPILED
done