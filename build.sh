#!/bin/sh

set -e
cd "`dirname "$0"`"

TYPE="${1:-cross}"
VERSION="$2"
TAPE="${3:-$VERSION/lap6.linc}"

SIMH="$PWD/open-simh/BIN/linc"
ASSEMBLER="$PWD/lap6-tools/lap6.py"
FILING="$PWD/lap6-tools/lap6"

filing() {
    command="$1"
    shift
    "$FILING" "$command" "$TAPE" "$@"
}

stripped() {
    if test -x "$VERSION/strip.sh"; then
        "$VERSION/strip.sh" "$1"
    else
        cat "$1"
    fi
}

assemble() {
    x=""; test -n "$2" && x=", $2"
    echo "Assembling $1$x"
    rm -f manuscript.lap6
    for i in "$@"; do
        stripped "$VERSION/$i" >> manuscript.lap6
    done
    "$ASSEMBLER" manuscript.lap6 > output.oct
}

quarters() {
    quarters="$1"
    block="$2"
    case "$quarters" in
        *\ *)
            set $quarters
            x=`expr $1 + $2 - 1`
            test "$x" = 9 && x=7
            q="s $1-$x";;
        *)
            q=" $1";;
    esac
    echo "Quarter$q to block $block"
    ./quarters.py $quarters < output.oct | filing wb "$block"
}

save_manuscript() {
    stripped "$VERSION/$1"| filing sm "$1" 2>/dev/null
}

assemble_cross() {
    assemble "MSDISPLY"
    quarters "0 10" 300

    assemble "FILECOMS"
    quarters "0 4" 320

    assemble "MSDISPLY" "ADDMS LO"
    quarters "3" 324

    assemble "COPYFILE"
    quarters "0 3" 314

    assemble "COPY"
    quarters "0 2" 336

    assemble "CONVERT"
    quarters "0 3" 330

    assemble "CV DIS"
    quarters "0 2" 310

    assemble "DISX PX" "TELETYPE"
    quarters "0 2" 325

    assemble "PRINT MS" "TELETYPE"
    quarters 2 322

    assemble "LIST" "TELETYPE"
    quarters 1 333
    quarters 2 327
    quarters 3 335
    quarters "6 2" 312
    quarters 6 317
}

assemble_simh() {
    test -r "`dirname "$FILING"`"/.gitignore || git submodule update --init
    test -x "$SIMH" || (cd "`dirname "$SIMH"`/.." && make linc)
    "$SIMH" build.do "$TAPE" | tee build.log | grep '!'
}

test -r "`dirname "$FILING"`"/.gitignore || git submodule update --init
test -x "$FILING" || (cd "`dirname "$FILING"`" && make)

# LAP6 saves its state to tape, so use a copy.
cp bootstrap.linc clobbered.linc

filing mk
filing mx
(TAPE="clobbered.linc"
 save_manuscript "MSDISPLY"
 save_manuscript "ADDMS LO"
 save_manuscript "FILECOMS"
 save_manuscript "COPYFILE"
 save_manuscript "COPY"
 save_manuscript "CONVERT"
 save_manuscript "CV DIS"
 save_manuscript "DISX PX"
 save_manuscript "PRINT MS"
 save_manuscript "LIST"
 save_manuscript "TELETYPE")

"assemble_$TYPE"

