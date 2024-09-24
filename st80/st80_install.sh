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

echo "== END: ST80 Emulator Installation"
