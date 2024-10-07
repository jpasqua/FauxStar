#!/usr/bin/env bash

# Initialize variables
portal_mode=""
ADDITIONAL_PARAMS=""
EMULATOR_TYPE=""
WORLD=""
remaining_args=()

# Usage message function
usage() {
    echo "Usage: $0 [-h|--help] -p|--portal -e|--emulator (draco|duchess) -w|--world <world_name> [-- other_params...]"
    echo ""
    echo "  -h, --help          Show this help message"
    echo "  -p, --portal        Enable portal mode (Also sends '-fullscreen' to the emulator)"
    echo "  -e, --emulator      Sets the emulator type to either 'draco' or 'duchess'"
    echo "  -w, --world         Sets the world to the provided value"
    echo "  --                  Pass any other parameters to the emulator"
    echo ""
    echo "With no parameters you will be taken through a guided process"
    exit 0
}

parse_args() {
    # Parse command-line arguments which are passed as a param
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                ;;
            -p|--portal)
                portal_mode="y"
                shift # Move to the next argument
                ;;
            -e|--emulator)
                if [[ "$2" == "draco" || "$2" == "duchess" ]]; then
                    EMULATOR_TYPE="$2"
                    shift 2 # Move past the option and its argument
                else
                    echo "Error: --emulator requires an argument 'draco' or 'duchess'"
                    usage
                fi
                ;;
            -w|--world)
                if [[ -n "$2" ]]; then
                    WORLD="$2"
                    shift 2 # Move past the option and its argument
                else
                    echo "Error: --world requires a non-empty string argument"
                    usage
                fi
                ;;
            --) # End of all options
                shift
                remaining_args=("$@")
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

choose_options() {
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
        ADDITIONAL_PARAMS+=" -fullscreen"
        read -p "Run in portal mode? ([y]/n): " portal_mode
        portal_mode="${portal_mode:-"y"}"
        if [[ "$portal_mode" != "y" ]]; then
            portal_mode=""
        fi
    fi

    # Ask for any additional parameters
    while true; do
        read -p "Additional params ([Enter] for none, [?] for options): " more_params
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
    ADDITIONAL_PARAMS+=" $more_params"

    echo "NOTE: The direct command to launch with these options:"
    echo "$0 $( [[ "$portal_mode" == "y" ]] && echo '-p' ) -e $EMULATOR_TYPE -w $WORLD -- $ADDITIONAL_PARAMS"
    echo ""
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
    choose_options
else
    parse_args "$@"
    if [ ! portal_mode == "y" ]; then
        ADDITIONAL_PARAMS+=" -fullscreen"
    fi
fi


WORLD_HOME=$BASE_DIR/worlds/$EMULATOR_TYPE/$WORLD
if [ ! -d "$WORLD_HOME" ]; then
    echo "Error: The world $WORLD has not been established at $WORLD_HOME"
    usage
fi

# Change directory to the WORLD directory
cd "$WORLD_HOME" || { echo "Error: Cannot change directory to $WORLD_HOME"; exit 1; }

if [[ -z "$portal_mode" ]]; then
    java -jar $BASE_DIR/dwarf.jar -"$EMULATOR_TYPE" "$WORLD" "$@" $ADDITIONAL_PARAMS "${remaining_args[@]}"
else
    $BASE_DIR/../launch_portal.sh java -t FauxStar -s 1152x861 -- -jar $BASE_DIR/dwarf.jar \
            -"$EMULATOR_TYPE" "$WORLD" "${remaining_args[@]}" $ADDITIONAL_PARAMS
fi
