#!/usr/bin/env bash


cd $FAUXSTAR_INSTALL_DIR/st80
echo "== BEGIN: ST80 Emulator Installation"
# Get the smalltalk emulator from the jpasqua fork of ST80
curl -L -o st80vm.jar https://raw.githubusercontent.com/jpasqua/ST80/master/st80vm.jar

cd worlds/v2
unzip '*.zip'
rm *.zip
cd ../v6
unzip '*.zip'
rm *.zip

cat << EOF >> $FAUXSTAR_INSTALL_DIR/collected_install_notes.txt
* The ST80 Smalltalk emulator has been installed.
  It requires a Java installation. Please install Java version 22 or greater.
EOF

echo "== END: ST80 Emulator Installation"
