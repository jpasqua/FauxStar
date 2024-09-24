#!/usr/bin/env bash


cd $FAUXSTAR_INSTALL_DIR/mesa
echo "== BEGIN: Mesa Emulator Installation"
# Get the dwarf emulator from the jpasqua fork of dwarf
curl -L -o dwarf.jar https://raw.githubusercontent.com/jpasqua/dwarf/master/dwarf.jar

unzip disks-6085.zip
rm -rf disks-6085.zip
cp disks-6085/vp2.0.5.zdisk worlds/draco/vp2.0.5
cp disks-6085/xde5.0_2xTajo+hacks.zdisk worlds/draco/xde5.0_2xTajo+hacks
cp disks-6085/xde5.0.zdisk worlds/draco/xde5.0
cp disks-6085/xde5.0-1024.zdisk worlds/draco/xde5.0-1024
rm -rf disks-6085

unzip disks-guam.zip
rm -rf disks-guam.zip
cp disks-guam/GVWIN001.DSK worlds/duchess/gv_2.1_color
cp disks-guam/GVWIN.GRM worlds/duchess/gv_2.1_color
cp disks-guam/GVWIN001.DSK worlds/duchess/gv_2.1_mono
cp disks-guam/GVWIN.GRM worlds/duchess/gv_2.1_mono
cp disks-guam/Dawn.dsk worlds/duchess/xde
cp disks-guam/Dawn.germ worlds/duchess/xde
rm -rf disks-guam

cat << EOF >> $FAUXSTAR_INSTALL_DIR/collected_install_notes.txt
* The Dwarf Mesa emulator has been installed.
  It requires a Java installation. Please install Java version 22 or greater.
EOF

echo "== END: Mesa Emulator Installation"
