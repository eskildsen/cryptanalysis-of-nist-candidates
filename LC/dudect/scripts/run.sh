#!/bin/bash
REF=""
TIMEOUT=$1
BATCH_SIZE=$3
APPLICATION=$4
[[ ${APPLICATION} = "ctgrind" ]] && BATCH_SIZE=1 
[[ $2 = 1 ]] && REF="_ref"
PROGRAMS=$(find -path "./compiled/*/${APPLICATION}_*${REF}")

OUT_DIR="out"
[ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"
OUT_DIR="${OUT_DIR}/${APPLICATION}"
[ ! -d "$OUT_DIR" ] && mkdir -p "$OUT_DIR"

echo "Found $(echo "$PROGRAMS" | wc -l) ${APPLICATION} files to run"
[[ "${APPLICATION}" == "dudect" ]] && printf "Using ${TIMEOUT} seconds timeout for each dudect file"
printf "\n\n"

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

ctgrind () {
    local program=$1
    CANDIDATE=$(echo $program | cut -d'/' -f3)
    FILE=$(echo $program | cut -d'/' -f4)
    [ ! -d "${OUT_DIR}/${CANDIDATE}" ] && mkdir -p "${OUT_DIR}/${CANDIDATE}"

    #echo "Running ${CANDIDATE}/${FILE}"
    valgrind $program > "${OUT_DIR}/${CANDIDATE}/${FILE}.out" 2>&1
    OUTPUT=$(tail -n 1 ${OUT_DIR}/${CANDIDATE}/${FILE}.out)

    [[ "$OUTPUT" =~ "ERROR SUMMARY" ]] && printf "${CANDIDATE}/${FILE} ${OUTPUT}\n" && return
    printf "${CANDIDATE}/${FILE} gave no output.\n"
}

N=$BATCH_SIZE
(
    for program in $PROGRAMS; do
        ((i=i%N)); ((i++==0)) && wait
        ${APPLICATION} "$program" &
    done
)
