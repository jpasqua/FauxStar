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

# Update medley to support the VNC -FullScreen option
# Get the actual file that the symbolic link points to
real_file=$(readlink -f `which medley`)
# Apply sed to the real file
sed -i '/"${vncviewer}" -geometry "+${vncv_loc}+${vncv_loc}"/a \ \ \ \ $VNCVIEWER_FULLSCREEN \\' "$real_file"

echo "== END: Lisp Emulator Installation"

# medley -n -s 1024x728 -v +
