#!/usr/bin/env bash

echo "Installing FauxStar into $(pwd)"
mv FauxStar-main/fauxstar.sh .
mv FauxStar-main/mesa/ .
mv FauxStar-main/st80/ .
mv FauxStar-main/lisp/ .
rm -rf FauxStar-main/

# Array of installation options
install_options=("mesa" "st80" "lisp")

# Array to keep track of the user's choices
selected_options=()

# Function to prompt the user for each component
prompt_installation() {
    for option in "${install_options[@]}"; do
        while true; do
            read -p "  $option? (Y/n): " -r response
            case "$response" in
                [Nn]* )
                    break
                    ;;
                "" | [Yy]* )
                    selected_options+=("$option")
                    break
                    ;;
                * )
                    echo "Please type y, Y, or [Enter] for Yes"
                    echo "            n or N for No."
                    ;;
            esac
        done
    done
}

# Prompt the user for installation choices
echo "Please choose which emulators you'd like to install"
prompt_installation

# Check if any options were selected
if [ ${#selected_options[@]} -eq 0 ]; then
    echo "You didn't select anything to install..."
    echo "Goodbye"
    exit 0
fi

export FAUXSTAR_INSTALL_DIR=`pwd`
# Process the user's selections
for choice in "${selected_options[@]}"; do
    echo "===== Installing ${choice}"
    "$choice/${choice}_install.sh"
done

cd $FAUXSTAR_INSTALL_DIR

echo "Installation complete"
echo "Type ./fauxstar.sh to fire up an emalator"
