#! /bin/bash

# Generate icons from an SVG. This script requires ImageMagick installed locally
# and expects to be run from this directory.

mkdir -p icons

convert -background none favicon.svg -scale 24 icons/favicon-24x24.png
convert -background none favicon.svg -scale 32 icons/favicon-32x32.png
convert -background none favicon.svg -scale 64 icons/favicon-64x64.png
convert -background none favicon.svg -scale 96 icons/favicon-96x96.png
convert -background none favicon.svg -scale 128 icons/favicon-128x128.png
# 180x180 is used by iOS
convert -background none favicon.svg -scale 180 icons/favicon-180x180.png
# 192x192 is used by Android
convert -background none favicon.svg -scale 192 icons/favicon-192x192.png
convert -background none favicon.svg -scale 256 icons/favicon-256x256.png
convert -background none favicon.svg -scale 512 icons/favicon-512x512.png

# Pack an icon file
convert icons/* favicon.ico

# Move icons where they need to be
mv favicon.ico ../static/favicon.ico
mv icons/favicon-32x32.png ../static/favicon-32x32.png
mv icons/favicon-180x180.png ../static/apple-touch-icon.png
mv icons/favicon-192x192.png ../static/android-chrome-192x192.png
mv icons/favicon-512x512.png ../static/android-chrome-512x512.png

# Clean up temp directory
rm -r icons
