#!/usr/bin/env bash

ADDITIONAL_PARAMS=""


usage() {
    echo "Usage: $0 [--fullscreen] [emulator_parameters...]"
    echo "Example:"
    echo "  $0 --fullscreen"
    echo
    echo "For a guided process, provide no parameters"
    echo "  $0"
    echo
    exit 1
}

choose_options() {
    # Append "--fullscreen" if the user answers 'y' or 'Y'
    read -p "Fullscreen mode? ([y]/n): " fullscreen_choice
    if [[ "$fullscreen_choice" == "y" || "$fullscreen_choice" == "Y" || "$fullscreen_choice" == "" ]]; then
        export MEDLEY_DO_FULLSCREEN=true
        dims=$(xrandr 2>/dev/null | grep '*' | awk '{print $1}')
        ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -n -s ${dims} -v +"
    fi
}


# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")

# Check the number of arguments
if [ $# -eq 0 ]; then
    choose_options
elif [ $# -eq 1 ]; then
	usage
fi

echo medley $ADDITIONAL_PARAMS $@