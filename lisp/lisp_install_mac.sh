#!/usr/bin/env bash

echo "Installing Dependencies if needed"
if ! command -v Xquartz >/dev/null 2>&1; then
	# Test whether brew is already installed and install it if not
	if ! command -v brew >/dev/null 2>&1; then
	    echo "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	echo "Installing XQuartz"
	brew install --cask xquartz
fi

echo "Downloading Medley Interlisp"
curl -L -o medley_mac.zip https://github.com/Interlisp/medley/releases/download/medley-240911-433ffaf9/medley-full-macos-universal-240911-433ffaf9_240513-4becc6ad.zip

unzip medley_mac.zip
rm medley_mac.zip

cat << EOF >> $FAUXSTAR_INSTALL_DIR/collected_install_notes.txt
* The Medley Interlisp system has been installed.
  On the Mac this requires the installation of the XQuartz X Server
  and may have required the installation of Homebrew (brew)
EOF
