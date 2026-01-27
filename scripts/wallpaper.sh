#! /bin/bash

WP_FILE=~/wallpaper

if [[ -e $WP_FILE ]]; then
	unlink $WP_FILE
fi

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

ln -s $POSITIONAL_ARGS $WP_FILE

