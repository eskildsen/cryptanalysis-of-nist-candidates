#!/bin/bash
CFLAGS="-std=c99 -Wall -Wextra -Wshadow -O2 -Wfatal-errors"
COMPILER="gcc-5"
[[ "$1" == "afl" ]] && COMPILER="afl-gcc"
[[ "$1" == "ctgrind" ]] && CFLAGS="${CFLAGS} -ggdb"
[[ "$1" == "dudect" ]] && CFLAGS="${CFLAGS} " #-fsanitize=address,undefined" dissabled this because it is incompatible with stdbuf and because as it does roughly the same as valgrind and therefore should not impact correctness
INCS="-Iinc/"
C_FILES=$(find -path './candidates/*/Implementations/crypto_aead/*/*/*.c')
[ ! -d "compiled" ] && mkdir -p "compiled"

[[ ! $(which "$COMPILER") ]] && echo "Compiler '$COMPILER' not found. You need to install it first and ensure it is included in your \$PATH" && exit

for file in $C_FILES; do
    CANDIDATE=$(echo $file | cut -d'/' -f3)
    name=$(basename $file)
    [[ "$name" = "genkat_aead.c" ]] && continue
    [ ! -d "compiled/$CANDIDATE" ] && mkdir -p "compiled/$CANDIDATE"

    echo "Compiling $file"
    ENCRYPT_COMPILED="${file%.c}.o"
    $COMPILER $CFLAGS $INCS -c $file -o $ENCRYPT_COMPILED
done