#!/bin/bash
# Arbitrary but unique message tag
msgTag="mode"

# Change the volume using alsa(might differ if you use PulseAudio)
asusctl profile -n > /dev/null 

mode="$(asusctl profile -p | grep -i "active")"

dunstify -a "asusd" -u low -h string:x-dunst-stack-tag:$msgTag "${mode}"

