#!/bin/bash
REF=""
[[ $2 = 1 ]] && REF="_ref"
PROGRAMS=$(find -path "./compiled/*/*${REF}")

OUT_DIR="out"
[ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"

echo "Found $(echo "$PROGRAMS" | wc -l) dudect files to run"
printf "Using $1 seconds timeout for each dudect file\n\n"


for program in $PROGRAMS; do
    CANDIDATE=$(echo $program | cut -d'/' -f3)
    FILE=$(echo $program | cut -d'/' -f4)
    [ ! -d "${OUT_DIR}/${CANDIDATE}" ] && mkdir -p "${OUT_DIR}/${CANDIDATE}"

    echo "Running ${CANDIDATE}/${FILE}"
    timeout $1 $program > "${OUT_DIR}/${CANDIDATE}/${FILE}.out"
    OUTPUT=$(tail -n 2 ${OUT_DIR}/${CANDIDATE}/${FILE}.out)
    
    [[ "$OUTPUT" =~ "Definitely not" ]] && printf "\tDefinitely not constant time.\n" && continue
    [[ "$OUTPUT" =~ "Probably not" ]] && printf "\tProbably not constant time.\n" && continue
    [[ "$OUTPUT" =~ "maybe" ]] && printf "\tMaybe constant time.\n" && continue
done