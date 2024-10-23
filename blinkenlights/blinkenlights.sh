#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Define the virtual environment directory
VENV_DIR="${SCRIPT_DIR}/bl-env"

# Define the Python script path
PYTHON_SCRIPT="${SCRIPT_DIR}/blinkenlights.py"

# Default values for the options
MP_CODE=""
FAKE_ACTIVITY=false

# Help message
usage() {
    echo "Usage: $0 [-m NUMBER] [-f]"
    echo "  -m, --mpcode NUMBER    Set the Maintenance Panel code to NUMBER"
    echo "  -f, --fakeactivity     Enable fake LED activity"
    echo "  -h, --help             Display this help message"
    exit 1
}

# Parse the command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mpcode) MP_CODE="$2"; shift ;;
        -f|--fakeactivity) FAKE_ACTIVITY=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
    shift
done

# Build the python command with arguments
PYTHON_CMD="python $PYTHON_SCRIPT"
if [ ! -z "$MP_CODE" ]; then
    PYTHON_CMD+=" --mpcode $MP_CODE"
fi
if [ "$FAKE_ACTIVITY" = true ]; then
    PYTHON_CMD+=" --fakeactivity"
fi

# Activate the virtual environment
if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "Virtual environment not found at $VENV_DIR"
    exit 1
fi

# Run the Python script with the built command
eval "$PYTHON_CMD"

# Deactivate the virtual environment
deactivate
