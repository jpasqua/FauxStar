#!/usr/bin/env bash

echo "Installing FauxStar into $(pwd)"
if [ -d "FauxStar-main" ]; then
    mv FauxStar-main/fauxstar.sh .
    mv FauxStar-main/install.sh .
    mv FauxStar-main/mesa/ .
    mv FauxStar-main/st80/ .
    mv FauxStar-main/lisp/ .
    rm -rf FauxStar-main/
fi

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
                    rm -f $option/.installed
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

# Empty out/create the notes file
> collected_install_notes.txt

export FAUXSTAR_INSTALL_DIR=`pwd`
# Process the user's selections
for choice in "${selected_options[@]}"; do
    echo "===== Installing ${choice}"
    if [ "$shoice" == "lisp" ]; then
        echo "NOTE: To enable full screen operation of Medley Interlisp, tigervnc"
        echo "server and viewer will be installed automatically. tigervnc server"
        echo "will become the default Xvnc server."
        read -p ">> Is this ok? [y/n]: " -r lisp_install_ok
        if ["$shoice" != "y" ]; then
            echo "lisp will not be installed."
            continue
        fi
    fi
    "$choice/${choice}_install.sh"
    touch "$choice/.installed"
done

cd $FAUXSTAR_INSTALL_DIR

echo "Installation complete with the following notes:"
cat collected_install_notes.txt
echo
echo "Type ./fauxstar.sh to fire up an emalator"
