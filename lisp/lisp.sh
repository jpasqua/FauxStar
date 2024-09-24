#!/usr/bin/env bash

ADDITIONAL_PARAMS=""


usage() {
    echo "Usage: $0 [-?]|[-fullscreen] [emulator_parameters...]"
    echo "Example:"
    echo "  $0 -fullscreen"
    echo
    echo "For a guided process, provide no parameters"
    echo "  $0"
    echo
    exit 1
}

do_fullscreen() {
    export VNCVIEWER_FULLSCREEN="-FullScreen"
    dims=$(xrandr 2>/dev/null | grep '*' | awk '{print $1}')
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -n -s ${dims} -v +"
}

choose_options() {
	# VNCVIEWER_FULLSCREEN is used by our custom medley_vnc.sh script
	export VNCVIEWER_FULLSCREEN=""
    read -p "Fullscreen mode? ([y]/n): " fullscreen_choice
    if [[ "$fullscreen_choice" == "y" || "$fullscreen_choice" == "Y" || "$fullscreen_choice" == "" ]]; then
        do_fullscreen
    fi
}


# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")

if ! which medley > /dev/null 2>&1; then
    echo "There is not a valid Lisp (medley) installation."
    exit 1
fi

# Check the number of arguments
if [ $# -eq 0 ]; then
    choose_options
elif [ $# -eq 1 ]; then
    if [ $1 == "-?" ]; then
    	usage
    fi
    if [[ "${1,,}" == "-fullscreen" ]]; then
        shift
        do_fullscreen
    fi
fi

medley $ADDITIONAL_PARAMS $@