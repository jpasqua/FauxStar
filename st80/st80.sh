#!/usr/bin/env bash

# Initialize variables
portal_mode=""
ADDITIONAL_PARAMS=""

# Get the current system's timezone offset in minutes from UTC
system_offset_minutes=$(date +%z | awk '{print ($1 / 100) * 60 + ($1 % 100)}')

# Get the current timezone offset in minutes from UTC for Palo Alto, CA (America/Los_Angeles)
palo_alto_offset_minutes=$(TZ="America/Los_Angeles" date +%z | awk '{print ($1 / 100) * 60 + ($1 % 100)}')

# Calculate the difference between the two offsets
offset_difference=$((system_offset_minutes - palo_alto_offset_minutes))

# Usage message function
usage() {
    echo "Usage: $0 [-h|--help] [-p|--portal] [-e|--emulator v2|v6] [-w|--world <world_name>] [additional_params...]"
    echo "With no parameters you will be taken through a guided process, otherwise the parameters are:"
    echo "  -h, --help          Show this help message"
    echo "  -p, --portal        Enable portal mode (Also sends '-fullscreen' to the emulator)"
    echo "  -e, --emulator      Sets the emulator type to either 'v2' or 'v6'"
    echo "  -w, --world         Sets the world to the provided value"
    echo "  [additional_params] Optional parameters to be passed to the emulator"
    exit 0
}

parse_args() {
# Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -p|--portal)
                portal_mode="y"
                ADDITIONAL_PARAMS+=" -fullscreen"
                shift # Move to the next argument
                ;;
            -e|--emulator)
                if [[ "$2" == "v2" || "$2" == "v6" ]]; then
                    EMULATOR_TYPE="$2"
                    shift 2 # Move past the option and its argument
                else
                    echo "Error: --emulator requires an argument 'v2' or 'v6'"
                    usage
                fi
                ;;
            -w|--world)
                if [[ -n "$2" ]]; then
                    world="$2"
                    shift 2 # Move past the option and its argument
                else
                    echo "Error: --world requires a non-empty string argument"
                    usage
                fi
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

    # Validate required parameters
    if [[ -z "$EMULATOR_TYPE" ]]; then
        echo "Error: --emulator is required."
        usage
    fi

    if [[ -z "$WORLD" ]]; then
        echo "Error: --world is required."
        usage
    fi
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
    if [[ "$fullscreen_choice" == "y" || "$fullscreen_choice" == "Y"  || "$fullscreen_choice" == "" ]]; then
        ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS --fullscreen"
        read -p "Run in portal? ([y]/n): " portal_mode
        portal_mode="${portal_mode:-"y"}"
        if [[ "$portal_mode" != "y" ]]; then
            portal_mode=""
        fi
    fi

    # Ask for any additional parameters
    while true; do
        read -p "Additional parameters (press [Enter] for none, [?] for options): " more_params
        if [[ "$more_params" == "?" ]]; then
            echo "  --statusline:    Display a status line if not in fullscreen mode"
            echo "  --stats:         Display some stats when the emulator exits"
            echo "  --timeadjust:nn: Add nn minutes to GMT to correct time in Smalltalk"
            echo "                   (positive for east). Only relevant for v2"
            echo "  --tz:offsetMinutes[:dstFirstDay:dstLastDay]"
            echo "                   Set the timezone and daylight saving parameters"
            echo "                   Only relevant for v6"
            echo "Note: If --timeadjust (for v2) or --tz (for v6) are not given"
            echo "      computed values will be applied automatically."
        else
            break
        fi
    done

	if [ "$EMULATOR_TYPE" == "v2" ] && [[ "$more_params" != *"--timeadjust"* ]]; then
	    more_params="$more_params --timeadjust:$offset_difference"
	fi

	if [ "$EMULATOR_TYPE" == "v6" ] && [[ "$more_params" != *"--tz"* ]]; then
	    more_params="$more_params --tz:$system_offset_minutes"
	fi

    # Append any additional parameters
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS $more_params"

    echo "NOTE: The direct command to launch with these options:"
    echo "$0 $EMULATOR_TYPE $WORLD $ADDITIONAL_PARAMS"
    echo
}

# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")
cd $BASE_DIR

if [ ! -f $BASE_DIR/st80vm.jar ]; then
    echo "There is not a valid Smalltalk-80 (st80) installation."
    exit 1
fi

# Check the number of arguments
if [ $# -eq 0 ]; then
    choose_world
else
    parse_args
    if [ ! portal_mode == "y" ]; then
        if [[ ! " $@ " =~ " -fullscreen " ]]; then
            ADDITIONAL_PARAMS+=" -fullscreen"
        fi
    fi
fi

WORLD_HOME=$BASE_DIR/worlds/$EMULATOR_TYPE/$WORLD
if [ ! -d "$WORLD_HOME" ]; then
    echo "Error: The world $WORLD has not been established at $WORLD_HOME"
    usage
fi

IMAGE_NAME=$(cat worlds/$EMULATOR_TYPE/$WORLD/image_name.txt)

if [[ -z "$portal_mode" ]]; then
    java -jar $BASE_DIR/st80vm.jar "$@" $ADDITIONAL_PARAMS $WORLD_HOME/$IMAGE_NAME
else
    $BASE_DIR/../launch_portal.sh java -t FauxStar -s 1152x861 -- -jar $BASE_DIR/st80vm.jar "$@" $ADDITIONAL_PARAMS $WORLD_HOME/$IMAGE_NAME
fi
