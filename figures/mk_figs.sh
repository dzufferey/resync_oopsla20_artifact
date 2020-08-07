#!/bin/sh

for f in *.gnuplot; do
    f2=`basename $f .gnuplot`
    echo "processing $f2 ($f)"
    gnuplot < $f
    inkscape $f2.svg --export-pdf=$f2.pdf --export-area-drawing --export-margin=-2
    rm $f2.svg
done
