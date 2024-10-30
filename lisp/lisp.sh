#!/usr/bin/env bash

# Initialize variables
portal_mode=""
fullscreen=""
ADDITIONAL_PARAMS=""
export VNCVIEWER_FULLSCREEN=""
BASE_DIR=$(realpath "$(dirname "$0")")

# Usage message function
usage() {
    echo "Usage: $0 [-h|--help] [-p|--portal] [-f|--fullscreen] [additional_params...]"
    echo "With no parameters you will be taken through a guided process, otherwise the parameters are:"
    echo "  -h, --help          Show this help message"
    echo "  -p, --portal        Enable portal mode (Also sets '--fullscreen')"
    echo "  -f, --fullscreen    Run in full screen mode"
    echo "  [additional_params] Optional parameters to be passed to the emulator"
    exit 0
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -p|--portal)
                portal_mode="y"
                shift # Move to the next argument
                ;;
            -f|--fullscreen)
                fullscreen="y"
                ;;
            --) # End of all options
                shift
                break
                ;;
            -*)
                echo "Unknown option: $1"
                usage
                ;;
            *)
                break
                ;;
        esac
    done
}

choose_options() {
    read -p "Fullscreen mode? ([y]/n): " fullscreen
    fullscreen="${fullscreen:-"y"}"
    if [[ "$fullscreen" != "y" ]]; then
        fullscreen=""
    else
        read -p "Run in portal? ([y]/n): " portal_mode
        portal_mode="${portal_mode:-"y"}"
        if [[ "$portal_mode" != "y" ]]; then
            portal_mode=""
        fi
    fi

    read -p "Start with default apps? ([y]/n): " apps_choice
    if [[ "$apps_choice" == "y" || "$apps_choice" == "Y" || "$apps_choice" == "" ]]; then
        ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -a -e"
    fi

    read -p "Additional parameters for the emulator (press [Enter] for none): " more_params
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS $more_params"

    echo "NOTE: The direct command to launch with these options:"
    echo "$0 $( [[ "$portal_mode" == "y" ]] && echo '-p' ) $( [[ "$fullscreen" == "y" ]] && echo '-f' ) $ADDITIONAL_PARAMS"
    echo
}

MEDLEY=`which medley`
if [ "$MEDLEY" == "" ]; then
    echo "There is not a valid Lisp (Medley) installation."
    exit 1
fi

if [ "$#" -eq 0 ]; then
    # If we were given no arguments, provide a list of choices
    choose_options
else
    parse_args
fi

echo "portal_mode: ${portal_mode}"
echo "fullscreen: ${fullscreen}"

if [ "$portal_mode" == "y" ]; then
    export VNCVIEWER_FULLSCREEN=" -FullScreen -RemoteResize=0 "
    dims="1152x862"
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -n -s ${dims} -v +"
    echo "in (portal_mode=y) case: VNCVIEWER_FULLSCREEN=${VNCVIEWER_FULLSCREEN}"
    echo "in (portal_mode=y) case: ADDITIONAL_PARAMS=${ADDITIONAL_PARAMS}"
elif [ "$fullscreen" == "y" ]; then
    export VNCVIEWER_FULLSCREEN=" -FullScreen"
    dims=$(xrandr 2>/dev/null | grep '*' | awk '{print $1}')
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -n -s ${dims} -v +"
    echo "in (fullscreen=y) case: VNCVIEWER_FULLSCREEN=${VNCVIEWER_FULLSCREEN}"
    echo "in (fullscreen=y) case: ADDITIONAL_PARAMS=${ADDITIONAL_PARAMS}"
fi

BLINK="${BASE_DIR}/../blinkenlights/blinkenlights.sh"
START_BLINK="${BLINK} -t l15p"

echo "VNCVIEWER_FULLSCREEN=${VNCVIEWER_FULLSCREEN}"
echo "Launch Command: " $MEDLEY $ADDITIONAL_PARAMS "$@"
$MEDLEY $ADDITIONAL_PARAMS "$@" | $START_BLINK

$BLINK --stop
