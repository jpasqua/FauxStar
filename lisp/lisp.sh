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
    read -p "Start with default apps? ([y]/n): " apps_choice
    if [[ "$apps_choice" == "y" || "$apps_choice" == "Y" || "$apps_choice" == "" ]]; then
        ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -a -e"
    fi

    echo "NOTE: The direct command to launch with these options:"
    echo "$0 ${VNCVIEWER_FULLSCREEN:+-fullscreen} $ADDITIONAL_PARAMS"
    echo
}


# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")

if ! which medley > /dev/null 2>&1; then
    echo "There is not a valid Lisp (medley) installation."
    exit 1
fi

new_args=()  # Array to store arguments that aren't -fullscreen or -?


# Now you can use the new_args array which contains all the remaining arguments
echo "Remaining arguments: ${new_args[@]}"
# Check the number of arguments
if [ $# -eq 0 ]; then
    choose_options
else
    for arg in "$@"; do
        case "$arg" in
            -fullscreen)
                do_fullscreen  # Call the fullscreen handler
                ;;
            -\?)
                usage  # Call the usage function
                ;;
            *)
                new_args+=("$arg")  # Keep other arguments
                ;;
        esac
    done
fi

medley $ADDITIONAL_PARAMS "${new_args[@]}"