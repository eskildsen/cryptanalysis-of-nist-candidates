#!/bin/bash
CFLAGS="-std=c99 -Wall -Wextra -Wshadow -fsanitize=address,undefined -O2 -Wfatal-errors"
[[ "$1" == "ctgrind" ]] && CFLAGS="${CFLAGS} -ggdb -no-pie"
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
    gcc-5 $CFLAGS $INCS -c $file -o $ENCRYPT_COMPILED
done