#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Define the virtual environment directory
VENV_DIR="${SCRIPT_DIR}/bl-env"

# Define the Python script path
PYTHON_SCRIPT="${SCRIPT_DIR}/blinkenlights.py"

# Default values for the options
MP_CODE=""
MP_TEXT=""
FAKE_ACTIVITY=false

# Help message
usage() {
    echo "Usage: $0 [-m NUMBER] [-f]"
    echo "  -m, --mpcode NUMBER    Set the Maintenance Panel code to NUMBER"
    echo "  -t, --test STRING      Set the Maintenance Panel to a 4-character string"
    echo "  -f, --fakeactivity     Enable fake LED activity"
    echo "  -s, --stop             Clear the Maintenance Panel and exit"
    echo "  -h, --help             Display this help message"
    exit 1
}

# Parse the command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mpcode) MP_CODE="$2"; shift ;;
        -t|--text) MP_TEXT="$2"; shift ;;
        -f|--fakeactivity) FAKE_ACTIVITY=true ;;
        -s|--stop) STOP_BLINK=true ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
    shift
done

# Build the python command with arguments
PYTHON_ARGS=""
if [ ! -z "$MP_TEXT" ]; then
    PYTHON_ARGS+=" --text $MP_TEXT"
    MP_CODE=""
fi
if [ ! -z "$STOP_BLINK" ]; then
    PYTHON_ARGS+=" --stop"
fi
if [ ! -z "$MP_CODE" ]; then
    PYTHON_ARGS+=" --mpcode $MP_CODE"
fi
if [ "$FAKE_ACTIVITY" = true ]; then
    PYTHON_ARGS+=" --fakeactivity"
fi

# Activate the virtual environment
if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "Virtual environment not found at $VENV_DIR"
    exit 1
fi

# Run the Python script with the built command
python "$PYTHON_SCRIPT" $PYTHON_ARGS

# Deactivate the virtual environment
deactivate
