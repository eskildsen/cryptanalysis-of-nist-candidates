#!/bin/bash
REF=""
TIMEOUT=$1
BATCH_SIZE=$3
[[ $2 = 1 ]] && REF="_ref"
PROGRAMS=$(find -path "./compiled/*/*${REF}")

OUT_DIR="out"
[ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"
OUT_DIR="${OUT_DIR}/dudect"
[ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"

echo "Found $(echo "$PROGRAMS" | wc -l) dudect files to run"
printf "Using $1 seconds timeout for each dudect file\n\n"

dudect () {
    local program=$1
    CANDIDATE=$(echo $program | cut -d'/' -f3)
    FILE=$(echo $program | cut -d'/' -f4)
    [ ! -d "${OUT_DIR}/${CANDIDATE}" ] && mkdir -p "${OUT_DIR}/${CANDIDATE}"

    #echo "Running ${CANDIDATE}/${FILE}"
    timeout $TIMEOUT stdbuf -oL $program > "${OUT_DIR}/${CANDIDATE}/${FILE}.out"
    OUTPUT=$(tail -n 2 ${OUT_DIR}/${CANDIDATE}/${FILE}.out)
    
    [[ "$OUTPUT" =~ "Definitely not" ]] && printf "${CANDIDATE}/${FILE} is definitely not constant time.\n" && return
    [[ "$OUTPUT" =~ "Probably not" ]] && printf "${CANDIDATE}/${FILE} is probably not constant time.\n" && return
    [[ "$OUTPUT" =~ "maybe" ]] && printf "${CANDIDATE}/${FILE} is maybe constant time.\n" && return
    printf "${CANDIDATE}/${FILE} gave no output.\n"
}

N=$BATCH_SIZE
(
    for program in $PROGRAMS; do
        ((i=i%N)); ((i++==0)) && wait
        dudect "$program" &
    done
)