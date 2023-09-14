#!/bin/sh
OUTFILE=../rolyplayer.prg

rm -f "$OUTFILE"

acme -v4 -f cbm -l labels.asm -o "$OUTFILE" main.asm

if [ -z "$1" ]
then
    rm -f labels.asm
    vice -moncommands res/mon.txt -initbreak 0xa871 -VICIIborders 0 -VICIIfilter 1 "$OUTFILE"
else
    vice -moncommands res/mon.txt -initbreak 0xa871 -VICIIborders 2 -VICIIfilter 0 "$OUTFILE"
fi
