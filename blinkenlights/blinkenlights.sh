#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Define the virtual environment directory
VENV_DIR="${SCRIPT_DIR}/bl-env"

# Define the Python script path
PYTHON_SCRIPT="${SCRIPT_DIR}/blinkenlights.py"

# Activate the virtual environment
if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "Virtual environment not found at $VENV_DIR"
    exit 1
fi

# Run the Python script
python "$PYTHON_SCRIPT"

# Deactivate the virtual environment
deactivate

