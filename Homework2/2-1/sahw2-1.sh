#!/bin/sh
ls -ARl | egrep "^[-d]" | sort -k5rg | awk 'BEGIN {count=fileNum=dirNum=total=0} /^-/ && $9~/^[^.].*$/ {fileNum++; total+=$5; if (count++ < 5) print count ":" $5, $9 } /^d/ { dirNum ++ } END {print "Dir num: " dirNum "\n" "File num:" fileNum "\n" "Total: " total}'
