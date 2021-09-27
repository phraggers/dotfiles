#!/bin/bash
#dependencies: imagemagick scrot i3lock

IMAGE=/tmp/i3lock.png
SCREENSHOT="scrot $IMAGE"

# Blurs (from slowest to fastest)
#BLURTYPE="0x5"
#BLURTYPE="0x2"
#BLURTYPE="5x2"
#BLURTYPE="2x3"
BLURTYPE="2x8"

$SCREENSHOT
convert $IMAGE -blur $BLURTYPE $IMAGE
set -e
xset s off dpms 0 10 0
i3lock -i $IMAGE --show-failed-attempts --nofork
rm $IMAGE
xset s off -dpms
