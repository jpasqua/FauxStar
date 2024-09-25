#!/usr/bin/env bash

echo "Installing Dependencies if needed"
sudo apt -y install tigervnc-standalone-server
sudo update-alternatives --force --set Xvnc `which Xtigervnc`

sudo apt -y install tigervnc-viewer

echo "Downloading Medley InterLisp"
curl -L -o medley.deb https://github.com/Interlisp/medley/releases/download/medley-240911-433ffaf9/medley-full-linux-aarch64-240911-433ffaf9_240513-4becc6ad.deb

echo "Installing Medeley"
sudo dpkg -i medley.deb
rm medley.deb

# Update medley to support the VNC -FullScreen option
# Get the actual file that the symbolic link points to
real_file=$(readlink -f `which medley`)
# Apply sed to the real file
sudo sed -i '/"${vncviewer}" -geometry "+${vncv_loc}+${vncv_loc}"/a \ \ \ \ $VNCVIEWER_FULLSCREEN \\' "$real_file"

cat << EOF >> $FAUXSTAR_INSTALL_DIR/collected_install_notes.txt
* The Medley Interlisp system has been installed.
  On a Raspberry Pi this results in the installation of tigervnc
  as the main Xvnc alternative. The tigervnc viewer was also installed.
  This is required for fullscreen operation.
EOF
