#!/bin/bash

for ext in .png .webp
do
    for img in screenshots/*$ext
    do
        echo "Processing: $img..."
        convert "$img"  -auto-orient \
              -thumbnail 250x90   -unsharp 0x.5  ${img/$ext/-thumb.jpg}
    done
done


