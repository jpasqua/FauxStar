#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Find all subdirectories
emulator_dirs=($(find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

# Check if there are any subdirectories
if [ ${#emulator_dirs[@]} -eq 0 ]; then
    echo "No emulators found."
    exit 1
fi

# Function to display usage message
usage() {
    emulators=$(IFS='|' ; echo "${emulator_dirs[*]}")
    echo "Usage: $0 [$emulators] [additional parameters]"
    echo "  * If you provide no arguments you will be asked to choose an emulation"
    echo "    type and then be given a menu of options specific to that emulator."
    echo "  * If you provide only the emulation type, you will be presented with"
    echo "    a menu of options specific to that emulation"
    echo "  * If you provide an emulation type and additional parameters, the"
    echo "    chosen emulator will be run with those options and no additional"
    echo "    input is requested"
    exit 1
}

ADDITIONAL_PARAMETERS=""

# Check the number of arguments
if [ $# -eq 0 ]; then
    # Display menu
    menu_options=()
    for i in "${!emulator_dirs[@]}"; do
        menu_options+=("${emulator_dirs[$i]}")
    done
    menu_options+=("Quit")

    echo "Select an emulator to run:"
    PS3="Enter the number of your choice: "

    select opt in "${menu_options[@]}"; do
        if [ "$opt" == "Quit" ]; then
            echo "Goodbye"
            exit 1
        fi
        if [ -n "$opt" ]; then
            echo "opt = " $opt
            selected_emulator=$opt
            break
        else
            echo "Invalid option. Please try again."
        fi
    done
elif [ $# -eq 1 ]; then
    selected_emulator=$1
else
    # More than one argument, assume it is a complete specification
    selected_emulator=$1
    shift 1
    ADDITIONAL_PARAMETERS=$@
fi

# Script to execute
script_to_run="$SCRIPT_DIR/$selected_emulator/$selected_emulator.sh"

# Check if the script exists
if [ -f "$script_to_run" ]; then
    # Execute the script
    bash "$script_to_run" $ADDITIONAL_PARAMETERS
else
    usage
fi