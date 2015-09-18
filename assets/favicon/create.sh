#!/bin/bash
SIZES=(16 24 32 48 57 72 114 120 144 152)
for i in ${SIZES[@]}; do
    convert -resize $ix$i -background none favicon.svg favicon-$i.png
done

convert favicon-16.png favicon-24.png favicon-32.png favicon-48.png icon.ico 