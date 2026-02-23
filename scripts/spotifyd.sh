#!/bin/bash
# Example URL:
# https://github.com/Spotifyd/spotifyd/releases/download/v0.4.2/spotifyd-linux-x86_64-full.tar.gz

TARGET="$HOME/.local/bin"
LOC="/tmp/spotifyd.tar.gz"
URL=$(curl -s https://api.github.com/repos/Spotifyd/spotifyd/releases/latest \
	| grep "browser_download_url" | grep "spotifyd-linux-$(uname -m)-default.tar.gz" \
	| awk '{ print $2 }' \
	| sed 's/,$//'       \
	| sed 's/"//g' )     \

curl -L -o $LOC $URL
tar -xzf $LOC -C $TARGET/
chmod +x $TARGET/spotifyd

