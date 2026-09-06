#!/bin/bash
# Arbitrary but unique message tag
msgTag="backlight"

# Change the volume using alsa(might differ if you use PulseAudio)
brightnessctl set "$@" 

level="$(brightnessctl -m | awk -F, '{print substr($4, 0, length($4))}')"

dunstify -a "brightnessctl" -u low -h string:x-dunst-stack-tag:$msgTag -h int:value:"$level" "Brightness: ${level}"

