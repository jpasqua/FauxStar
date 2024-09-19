#!/bin/bash

# Get the directory where the script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to that directory
cd "$script_dir" || exit 1

ADDITIONAL_PARAMS=""

# Get the current system's timezone offset in minutes from UTC
system_offset_minutes=$(date +%z | awk '{print ($1 / 100) * 60 + ($1 % 100)}')

# Get the current timezone offset in minutes from UTC for Palo Alto, CA (America/Los_Angeles)
palo_alto_offset_minutes=$(TZ="America/Los_Angeles" date +%z | awk '{print ($1 / 100) * 60 + ($1 % 100)}')

# Calculate the difference between the two offsets
offset_difference=$((system_offset_minutes - palo_alto_offset_minutes))

usage() {
    echo "Usage: $0 [-?]|[<v2|v6> <world_name>] [emulator_parameters...]"
    echo "Example:"
    echo "  $0 v6 vanilla --fullscreen"
    echo
    echo "For a guided process, provide no parameters"
    echo "  $0"
    echo
    exit 1
}

choose_world() {
    menu_options=()

    # Loop through each subfolder in the worlds directory
    for world in worlds/*; do
        if [ -d "$world" ]; then
            world_name=$(basename "$world")

            # Loop through each subfolder within the world folder
            for subfolder in "$world"/*; do
                if [ -d "$subfolder" ]; then
                    subfolder_name=$(basename "$subfolder")
                    
                    # Add the combination to the menu_options array
                    menu_options+=("$world_name $subfolder_name")
                fi
            done
        fi
    done

    # Add a "Quit" option to the menu
    menu_options+=("Quit")

    # Display the menu menu_options
    echo "Select a world to emulate:"
    PS3="Enter the number of your choice: "

    select opt in "${menu_options[@]}"; do
        if [ "$opt" == "Quit" ]; then
            echo "Goodbye"
            exit 1
        fi
        if [ -n "$opt" ]; then
            # Split the selected option into the world and subfolder
            EMULATOR_TYPE=$(echo "$opt" | awk '{print $1}')
            WORLD=$(echo "$opt" | awk '{print $2}')
            break
        else
            echo "Invalid option. Please try again."
        fi
    done

    # Ask the user a yes/no question about fullscreen mode
    read -p "Fullscreen mode? ([y]/n): " fullscreen_choice
    fullscreen_choice="${fullscreen_choice:-"y"}"

    # Append "--fullscreen" if the user answers 'y' or 'Y'
    if [[ "$fullscreen_choice" == "y" || "$fullscreen_choice" == "Y" ]]; then
        ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS --fullscreen"
    fi

    # Ask for any additional parameters
    while true; do
        read -p "Additional parameters (press [Enter] for none, [?] for options): " more_params
        if [[ "$more_params" == "?" ]]; then
            echo "  --statusline:    Display a status line if not in fullscreen mode"
            echo "  --stats:         Display some stats when the emulator exits"
            echo "  --timeadjust:nn: Add nn minutes to GMT to correct time in Smalltalk (positive values for east)."
            echo "                   Only relevant for v2"
            echo "  --tz:offsetMinutes[:dstFirstDay:dstLastDay]"
            echo "                   Set the timezone and daylight saving parameters"
            echo "                   Only relevant for v6"
        else
            break
        fi
    done

	if [ "$EMULATOR_TYPE" == "v2" ] && [[ "$more_params" != *"--timeadjust"* ]]; then
	    more_params="$more_params --timeadjust:$offset_difference"
	fi

	if [ "$EMULATOR_TYPE" == "v6" ] || [[ "$more_params" != *"--tz"* ]]; then
	    more_params="$more_params --tz:$system_offset_minutes"
	fi

    # Append any additional parameters
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS $more_params"

    echo "$0 $EMULATOR_TYPE $WORLD $ADDITIONAL_PARAMS"
}

# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")
cd $BASE_DIR

# Check the number of arguments
if [ $# -eq 0 ]; then
    choose_world
elif [ $# -ge 2 ]; then
    # Grab the emulator type and name of the world we want to run
    EMULATOR_TYPE=$1
    WORLD=$2
    # All other parameters will be passed along, so get rid of these 2
    shift 2
    if [[ "$EMULATOR_TYPE" != "v2" && "$EMULATOR_TYPE" != "v6" ]]; then
        usage
    fi
else
    usage
fi

WORLD_HOME=$BASE_DIR/worlds/$EMULATOR_TYPE/$WORLD
if [ ! -d "$WORLD_HOME" ]; then
    echo "Error: The world $WORLD has not been established at $WORLD_HOME"
    usage
fi

IMAGE_NAME=$(cat worlds/$EMULATOR_TYPE/$WORLD/image_name.txt)

java -jar $BASE_DIR/st80vm.jar $WORLD_HOME/$IMAGE_NAME "$@" $ADDITIONAL_PARAMS