#!/bin/bash

for img in screenshots/*.png
do
	echo "Processing: $img..."
	convert "$img"  -auto-orient \
          -thumbnail 250x90   -unsharp 0x.5  ${img/.png/-thumb.jpg}
done


