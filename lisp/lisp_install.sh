#!/usr/bin/env bash

cd $FAUXSTAR_INSTALL_DIR/lisp
echo "== BEGIN: Lisp Emulator Installation"

OS="$(uname -s)"

case "$OS" in
    Darwin)
        ./lisp_install_mac.sh
        MEDLEY=$BASE_DIR/medley/medley
        ;;
    Linux)
        ./lisp_install_linux.sh
        MEDLEY="medley"
        ;;
    CYGWIN*|MINGW*|MSYS*|MINGW32*|MINGW64*)
        echo "FauxStar is not yet prepared to install on Windows"
        exit 1
        ;;
    *)
        echo "Unknown OS: $OS"
        exit 1
        ;;
esac

echo "== END: Lisp Emulator Installation"
