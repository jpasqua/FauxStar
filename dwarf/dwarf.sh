#!/usr/bin/env bash

usage() {
    echo "Usage: $0 <draco|duchess> <world_name> [emulator_parameters...]"
    echo "Example:"
    echo "  $0 duchess xde -fullscreen"
    echo
    exit 1
}

# Ensure the script receives at least one argument
if [ "$#" -lt 2 ]; then
    usage
fi


# Set BASE_DIR to the full path of the directory containing the script
BASE_DIR=$(realpath "$(dirname "$0")")
# Grab the emulator type and name of the world we want to run
EMULATOR_TYPE=$1
WORLD=$2
# All other parameters will be passed along, so get rid of these 2
shift 2

if [[ "$EMULATOR_TYPE" != "draco" && "$EMULATOR_TYPE" != "duchess" ]]; then
    usage
fi

WORLD_HOME=$BASE_DIR/worlds/$EMULATOR_TYPE/$WORLD
if [ ! -d "$WORLD_HOME" ]; then
    echo "Error: The world $WORLD has not been established at $WORLD_HOME"
    usage
fi

# Change directory to the WORLD directory
cd "$WORLD_HOME" || { echo "Error: Cannot change directory to $WORLD_HOME"; exit 1; }

# Run the Java interpreter with the specified command
java -jar $BASE_DIR/dwarf.jar -"$EMULATOR_TYPE" "$WORLD" "$@"