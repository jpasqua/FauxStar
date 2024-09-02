# Dwarf Installation and Usage Notes

This is a repackaging of the wonderful [Dwarf emulator](https://github.com/devhawala/dwarf) by [@devhawala](https://github.com/devhawala). There are small changes to the emulator to allow for full screen operation without a status line or toolbar. The changes can be found in [this fork](https://github.com/jpasqua/dwarf).

***Limitations***: This packaging has only been tested on Raspberry Pi and Mac. There are no .cmd files for Windows. However, you can use the `dwarf.jar` file from this repo as a drop in replaement for the one in the original repo and use the install/operation process described there.

## Installation

Download the repo from github using any means you like. For example:

```
wget ...
```

## Usage

To run the emulator use the `dwarf.sh` script in the dwarf directory:

```
Usage: ./dwarf.sh <draco|duchess> <world_name> [emulator_parameters...]
Example:
  ./dwarf.sh duchess xde -fullscreen
```

There are two required positional parameters:

1. Emulator Type: Dwarf has two modes of operation named *draco* and *duchess*. The former emulates a Xerox 6085 workstation while the latter recreates the GlobalView emulator. When starting Dwarf you must specify which emulation you want to use by giving its name.
2. World: A world is a combonation of a disk image and a properties file that provides configuration information. There are several *draco* worlds provided and several *duchess* worlds. You can also add your own by creating a disk image or customizing a configuration. The default worlds are:
	* *draco*
		* vp2.0.5: A ViewPoint 2.0.5 Installation
	   	* xde5.0: A barebones install of the Xerox Development Environment (XDE) 5.0
  		* xde5.0_2xTajo+hacks: An isntall of XDE 5.0 with extra programs
	* *duchess*
		* gv_2.1_color: GlobalView 2.1 configured with a color display
      	* gv_2.1_mono: GlobalView 2.1 configured with a monochrome display
      	* xde: A barebones install of the XDE based on an image from the [Dawn emulator](https://www.woodward.org/mps/).

You may also add parameters after the first two that will be passed along to the emulator. A full list can be found at the [repo](https://github.com/jpasqua/dwarf?tab=readme-ov-file#command-line-parameters-for-dwarf). Of most interest here is the `-fullscreen` parameter that can be used with *duchess*. It is described below.

### Fullscreen Notes

Fullscreen mode is available when using the *duchess* emualtor type. When using this mode the emulator will take over the entire display and will not show the toolbar or status line as usual. This provides a more immersive experience of the emulation. Of course at times you may wish to see status or need to use the toolbar. You can toggle the visibility of these emulator controls by pressing `F12`. Unlike windowed mode, when using fullscreen mode both the toolbar and the status line will appear at the top of the display and a small area of the emulated screen will be clipped off the bottom of the physical display. 

When starting *duchess* in fullscreen mode you'll see a brief flash on the screen as if a window opens and immediately closes. That is exactly what is happening. This is a "probe" to determine the actual usable screen size.

### Shutting down the system

In all cases below, if the emulator controls are not displayed, hit `F12` to make them visible.

* **Draco**
	* **XDE**: Use the `Stop` button in the emulator controls. 
	* **ViewPoint**: Log out, wait until the screen turns black with the bouncing keyboard and then use the `Stop` button.
* **Duchess**
	* **XDE**: Use the "Boot button" in the ["Boot from:"](images/XDEBootMenu.png) menu. This is accessed using the middle button over the Herald window. The cursor icon will change to a small three-button mouse with the left button highlighted. Press the left button to confirm the shutdown.
	* **GlobalView**: Choose `Exit` from the [Logoff Option Sheet](images/LogoffOptionSheet.png), then hit `Start` at the top of that sheet. In this context `Start` means "start the logoff process". If you are running in fullscreen mode, the emulator will exit. If you are running windowed, you'll need to close the window yourself.

## Structure

The folder structure for dwarf is relevant if you want to add your own "worlds". You can see the structure below. Note that there may be new worlds or the names may change. The figure is meant to illisustrate the overall structure. See the annotations in the figure below to understand the layout.


```
dwarf
├── disks-6085
|   | # Clean copies of disk images that can be used to create your own worlds
|   | # These are for use with draco
│   ├── vp2.0.5.zdisk
│   ├── xde5.0.zdisk
│   └── xde5.0_2xTajo+hacks.zdisk
├── disks-duchess
|   | # Clean copies of disk images/germs that can be used to create your own worlds
|   | # These are for use with duchess
│   ├── Dawn.dsk       # An barebones XDE image
│   ├── Dawn.germ      # A germ for use in an XDE environment
│   ├── GVWIN001.DSK   # A clean install of GlobalView
│   └── GVWIN.GRM      # A germ for use in an XDE environment
├── dwarf.jar				# The actual emulator code
├── dwarf.sh				# The launcher script
├── keyboard-maps		# Keyboard maps for various keyboards
│   ├── kbd_linux_de_DE.map
│   └── kbd_linux_en_US.map
└── worlds
    | # These are the emulator "images" and configurations for various
    | # different "worlds". They are broken down into images that work
    | # with draco and those that work with duchess.
    | # Each world contains a .properties file with the same name as
    | # as the world. The launcher script relies on this. The properties
    | # file points to the disk image, the germ (if necessary), the default
    | # location for floppy images, and provides other setup information
    | # such as the keymap file to use.
    ├── draco
    │   ├── vp2.0.5
    │   │   ├── floppies
    │   │   ├── vp2.0.5.properties
    │   │   └── vp2.0.5.zdisk
    │   ├── xde5.0
    │   │   ├── floppies
    │   │   ├── xde5.0.properties
    │   │   └── xde5.0.zdisk
    │   └── xde5.0_2xTajo+hacks
    │       ├── floppies
    │       ├── xde5.0_2xTajo+hacks.properties
    │       └── xde5.0_2xTajo+hacks.zdisk
    └── duchess
        ├── gv_2.1_color
        │   ├── GVWIN.GRM
        │   ├── GVWIN001.DSK
        │   ├── floppies
        │   └── gv_2.1_color.properties
        ├── gv_2.1_mono
        │   ├── GVWIN.GRM
        │   ├── GVWIN001.DSK
        │   ├── floppies
        │   └── gv_2.1_mono.properties
        └── xde
            ├── Dawn.dsk
            ├── Dawn.germ
            ├── floppies
            └── xde.properties
```

## License: [![CC BY-NC 4.0][cc-by-nc-shield]][cc-by-nc]

This work is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License][cc-by-nc].

[![CC BY-NC 4.0][cc-by-nc-image]][cc-by-nc]

[cc-by-nc]: https://creativecommons.org/licenses/by-nc/4.0/
[cc-by-nc-image]: https://licensebuttons.net/l/by-nc/4.0/88x31.png
[cc-by-nc-shield]: https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg

The license for Dwarf can be found at the [Dwarf repo](https://github.com/devhawala/dwarf).