===============================================================================
rolyplay - generates a C64 SID tune player for R0ly                 Version 1.0
                                                            by Spider Jerusalem
===============================================================================

Usage:
======
  rolyplay(.exe) [options] {sidfile}

Command line options:
=====================
  -d duration : length of the tune. format: 03:30.
                [default: 03:30]
  -t title    : title of the tune. lowercase!
                [default: untitled]
  -o outfile  : name of the output file.
                [default: out.prg]

Example:
========
  rolyplay -d"03:41" -t"mein toller titel" -o"meintitel.prg" meintitel.sid
  rolyplay.exe -d"03:41" -t"mein toller titel" -o"meintitel.prg" meintitel.sid

Have fun!
