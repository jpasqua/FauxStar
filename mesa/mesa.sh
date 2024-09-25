#!/usr/bin/env bash

ADDITIONAL_PARAMS=""

usage() {
    echo "Usage: $0 [-?]|[<draco|duchess> <world_name>] [emulator_parameters...]"
    echo "Example:"
    echo "  $0 duchess xde -fullscreen"
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
            # echo $EMULATOR_TYPE $WORLD    
            break
        else
            echo "Invalid option. Please try again."
        fi
    done

    # Ask the user a yes/no question about fullscreen mode
    read -p "Fullscreen mode? ([y]/n): " fullscreen_choice
    fullscreen_choice="${fullscreen_choice:-"y"}"

    # Append "-fullscreen" if the user answers 'y' or 'Y'
    if [[ "$fullscreen_choice" == "y" || "$fullscreen_choice" == "Y"  || "$fullscreen_choice" == "" ]]; then
        ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS -fullscreen"
    fi

    # Ask for any additional parameters
    while true; do
        read -p "Additional parameters (press [Enter] for none, [?] for options): " more_params
        if [[ "$more_params" == "?" ]]; then
            echo "  -merge:         Merge the disk image. Don't run the emulator"
            echo "  -run:           Start the emulator, override 'autostart' in the config file"
            echo "  -v:             Dump the config file parameters"
            echo "  -logkeypressed: Log the key press events to the console"
            echo "  -autoclose:     Same as setting autoclose to true in the config file"
        else
            break
        fi
    done

    # Append any additional parameters
    ADDITIONAL_PARAMS="$ADDITIONAL_PARAMS $more_params"

    echo "NOTE: The direct command to launch with these options:"
    echo "$0 $EMULATOR_TYPE $WORLD $ADDITIONAL_PARAMS"
    echo
}


# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")
cd $BASE_DIR

if [ ! -f $BASE_DIR/dwarf.jar ]; then
    echo "There is not a valid Mesa (dwarf) installation."
    exit 1
fi

if [ "$#" -eq 0 ]; then
    # If we were given no arguments, provide a list of choices
    choose_world
elif [ "$#" -lt 2 ]; then
    # If we weren't given enough options, provide usage details
    usage
else
    # Grab the emulator type and name of the world we want to run
    EMULATOR_TYPE=$1
    WORLD=$2
    # All other parameters will be passed along, so get rid of these 2
    shift 2
    if [[ "$EMULATOR_TYPE" != "draco" && "$EMULATOR_TYPE" != "duchess" ]]; then
        usage
    fi
fi


WORLD_HOME=$BASE_DIR/worlds/$EMULATOR_TYPE/$WORLD
if [ ! -d "$WORLD_HOME" ]; then
    echo "Error: The world $WORLD has not been established at $WORLD_HOME"
    usage
fi

# Change directory to the WORLD directory
cd "$WORLD_HOME" || { echo "Error: Cannot change directory to $WORLD_HOME"; exit 1; }

java -jar $BASE_DIR/dwarf.jar -"$EMULATOR_TYPE" "$WORLD" "$@" $ADDITIONAL_PARAMS
