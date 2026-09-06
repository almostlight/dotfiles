#!/bin/bash
# Temporary file location
TEMP_IMG="/tmp/ocr_snapshot.png"
TEMP_TXT="/tmp/ocr_output"
# Capture selected region using Spectacle
# -r: capture region, -b: background mode, -n: no notification, -o: output file
spectacle -rbno "$TEMP_IMG"
# Check if the user cancelled capture
if [ ! -f "$TEMP_IMG" ]; then
    exit 1
fi
# Extract text using Tesseract
# 'stdout' sends the text directly to the console instead of a file
tesseract "$TEMP_IMG" stdout -l pol+eng 2>/dev/null | wl-copy
# Cleanup
rm "$TEMP_IMG"
notify-send "Text copied to clipboard."

