#!/usr/bin/env bash

cd $FAUXSTAR_INSTALL_DIR/lisp
echo "== BEGIN: Lisp Emulator Installation"

echo "Installing Dependencies"
sudo apt -y install tigervnc-standalone-server
sudo update-alternatives --force --set Xvnc `which Xtigervnc`

sudo apt -y install tigervnc-viewer

echo "Downloading Medley InterLisp"
curl -L -o medley.deb https://github.com/Interlisp/medley/releases/download/medley-240911-433ffaf9/medley-full-linux-aarch64-240911-433ffaf9_240513-4becc6ad.deb

echo "Installing Medeley"
sudo dpkg -i medley.deb

echo "== END: Lisp Emulator Installation"

# medley -n -s 1024x728 -v +
