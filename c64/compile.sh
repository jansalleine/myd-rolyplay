#!/bin/sh
OUTFILE=rolyplayer.prg

rm -f "$OUTFILE"

acme -v4 -f cbm -l labels.asm -o out.prg main.asm

STARTADDR=$(grep "code_start" labels.asm | cut -d$ -f2)
exomizer3 sfx 0x$STARTADDR -o "$OUTFILE" out.prg

rm -f out.prg
rm -f labels.asm

vice -VICIIborders 0 -VICIIfilter 1 "$OUTFILE"
