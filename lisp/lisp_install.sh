#!/usr/bin/env bash

cd $FAUXSTAR_INSTALL_DIR/lisp
echo "== BEGIN: Lisp Emulator Installation"

OS="$(uname -s)"

case "$OS" in
    Darwin)
        ./lisp_install_mac.sh
        ;;
    Linux)
        ./lisp_install_linux.sh
        ;;
    MINGW64*)
        ./lisp_install_win.sh
        exit 1
        ;;
    CYGWIN*|MINGW*|MSYS*|MINGW32*)
        echo "FauxStar is not prepared to install on ${OS}"
        exit 1
        ;;
    *)
        echo "Unknown OS: $OS"
        exit 1
        ;;
esac

echo "== END: Lisp Emulator Installation"
