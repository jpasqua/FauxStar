# FauxStar: The Mesa World

The *FauxStar* Mesa World is a packaging of the wonderful [Dwarf emulator for the Xerox 6085](https://github.com/devhawala/dwarf) by [@devhawala](https://github.com/devhawala) along with some disk images and a launch script. It's actually a packaging of my [fork](https://github.com/jpasqua/dwarf) of dwarf which has some changes in the way fullscreen operation is handled and a few other tweaks. For much more detailed information on the emulator, please refer to the original [repo](https://github.com/devhawala/dwarf) and my [fork](https://github.com/jpasqua/dwarf).

Though the name *FauxStar* puts a lot of emphasis on the [Star](https://en.wikipedia.org/wiki/Xerox_Star) part of this, there is actually no Star image included! ViewPoint, the next version of Star is the earliest version of the image to run here. In this context I'm using "Star" as a shorthand for a [Xerox "D" machine](https://en.wikipedia.org/wiki/Xerox_Star#Hardware) capable of running the Star software and the [Xerox Development Environment](https://web.archive.org/web/20041204132344/http://www.apearson.f2s.com/xde.html) (XDE)

## Nomenclature

| Term          | Meaning        |
|:------------- |:---------------|
| Dwarf         | The name for the emulator itself. Dwarf has two emulation types: *draco* and *duchess*      |
| draco         | An emulation of the [Xerox 6085](https://en.wikipedia.org/wiki/Xerox_Daybreak) hardware (known at Xerox as Daybreak)|
| duchess       | A recreation of the [GlobalView](https://en.wikipedia.org/wiki/GlobalView) engine which was an emulator running under Windows. |
| World         | A world corresponds to an environment to run. A world is specific to an emulator type (*draco* or *duchess*) and contains a disk image and a config file with parameters.  |

<a id=”Usage”></a>
## Usage

To run the emulator use the `mesa.sh` script in the `mesa` directory. If you run the script with no parameters you will be guided through the choice of available worlds and options. Alternatively you can specify the emulator and world explicitly.

```
Usage: fauxstar/mesa/mesa.sh [-h|--help] -p|--portal -e|--emulator (draco|duchess) -w|--world <world_name> [-- other_params...]

  -h, --help          Show this help message
  -p, --portal        Enable portal mode (Also sends '-fullscreen' to the emulator)
  -e, --emulator      Sets the emulator type to either 'draco' or 'duchess'
  -w, --world         Sets the world to the provided value
  --                  Pass any other parameters to the emulator

With no parameters you will be taken through a guided process
```

When you're using the guided experience you'll be presented with a list of available worlds. If you add your own world (see below) it will appear in this list. After selecting a world from the list, you'll be asked if you wish to run in full screen mode and whether you'd like to supply any additional parameters. Once you've answered all the questions, the emulator will be launched. The command used to launch it will be displayed in the terminal so if you'd like to run this world again, you can just copy and paste the command rather than going through the menus.

When you're not using the menu, there are two required parameters:

1. `--emulator`: Specifies which version of the emulator to use, *draco* or *duchess*.
2. `--world`: The name of a world in the `worlds` subdirectory. The default worlds are:
	* *draco*
		* vp2.0.5: A ViewPoint 2.0.5 Installation
	   	* xde5.0: A barebones install of the Xerox Development Environment (XDE) 5.0
  		* xde5.0_2xTajo+hacks: An install of XDE 5.0 with extra programs
  		* xde5.0-small: This is like xde5.0_2xTajo+hacks, but the window positions are customized to fit into a 1024x768 area even though the *draco* screen is larger (1152x861)
	* *duchess*
		* gv_2.1_color: GlobalView 2.1 configured with a color display
      	* gv_2.1_mono: GlobalView 2.1 configured with a monochrome display
      	* xde: A barebones install of the XDE based on an image from the [Dawn emulator](https://www.woodward.org/mps/).

You may optionally provide the `--portal` option which is useful for viewing in fullscreen mode on a physical display that is smaller than the emulated display. If you provide the `--portal` option, the `-fullscreen` option will be provided to the emulator automatically.

You may also add parameters that will be passed along to the emulator after the "end-of-parameters" delimiter:  `--`. A full list can be found at the [repo](https://github.com/jpasqua/dwarf?tab=readme-ov-file#command-line-parameters-for-dwarf), including the `-fullscreen` parameter which is described below.

### Fullscreen Notes

Fullscreen mode is available when using *draco* or *duchess* but they have an important difference. In *duchess* the emulator will make the size of the emulated display the same as the physical display (see caveat below). In *draco* the emulator's notion of the screen size is fixed. It doesn't change based on the size of the physical display you are looking at. This means that in all likelihood you will have large empty areas since your display is likely to be much larger than an original 6085 display. Alternatively, if you run on a small physical display (say 1024x768), some of the emulated screen will be clipped away.

When using fullscreen mode the emulator will take over the entire display and will not show the toolbar or status line as usual. This provides a more immersive experience of the emulation. Of course at times you may wish to see status or need to use the toolbar. You can toggle the visibility of these emulator controls by pressing `F12`. Unlike windowed mode, when using fullscreen mode both the toolbar and the status line will appear at the top of the display. Some of the bottom of the emulated screen may be clipped away.

When starting in fullscreen mode you'll see a brief flash on the screen as if a window opens and immediately closes. That is exactly what is happening. This is a "probe" to determine the actual usable screen size.

Using the `--portal` option is useful if your physical display is smaller than the emulated display. In this case you will view the emulated display through a "portal" which is the size of the physical display. The  portal will pan around the emulated display as the mouse hits the edges of the portal.

*Caveat on duchess in fullscreen mode*: If you launch a monochrome world (xde or gv_2.1_mono) in duchess, the width of the screen must be a multiple of 64 pixels. I'm not sure exactly why yet - this was determined experimentally. There is a reason for it to be limited to a mutiple of 16 pixels wide, but in practice it appears to be 64. The screen width will automatically be narrowed if necessary leaving a small border on the left and right of the display.

### Shutting down the system

Unfortunately, shutting down the various worlds is a little inconsistent. You'll need to remember how to properly shut down the world that you are running. In all cases below, if the emulator controls are not displayed, hit `F12` to make them visible.

* **Draco**
	* **XDE**:
		* **xde5.0**: using any of the XDE menus for shutting down the system will produce an unusable disk A system running this disk must be shut down with "Stop"-button Use the `Stop` button in the emulator controls.
		* **xde-1024**, **xde5.0_2xTajo+hacks**: Use the "Boot button" in the "Boot from:" menu in the Herald.
	* **ViewPoint**: Log out, wait until the screen turns black with the bouncing keyboard and then use the `Stop` button.
* **Duchess**
	* **XDE**: Use the "Boot button" in the ["Boot from:"](images/dwarf/XDEBootMenu.png) menu. This is accessed using the middle button over the Herald window. The cursor icon will change to a small three-button mouse with the left button highlighted. Press the left button to confirm the shutdown. If you are running in windowed mode you will get a message on the status line telling you when it is safe to close the window. If you are running fullscreen, the display will close automatically.
	* **GlobalView**: Choose `Exit` from the [Logoff Option Sheet](images/dwarf/LogoffOptionSheet.png), then hit `Start` at the top of that sheet. In this context `Start` means "start the logoff process". If you are running in fullscreen mode, the emulator will exit. If you are running windowed, you'll need to close the window yourself when you see a message telling you to do so in the status line.

## Adding your own worlds

The folder structure for dwarf is relevant if you want to add your own "worlds". You can see the structure below. Note that there may be new worlds or the names may change. The figure is meant to illustrate the overall structure. See the annotations in the figure below to understand the layout.

```
mesa
├── dwarf.jar				# The actual emulator code
├── mesa.sh				# The launcher script
├── keyboard-maps		# Keyboard maps for various keyboards
│   ├── kbd_linux_de_DE.map
│   └── kbd_linux_en_US.map
└── worlds
    | # These are the disk images and configurations for various
    | # "worlds". They are broken down into images that work
    | # with draco (6085) and those that work with duchess (guam).
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
    │   ├── ...
    │   └── xde5.0-1024
    │       ├── ...
    │       └── xde5.0-1024.zdisk
    └── duchess
        ├── gv_2.1_color
        │   ├── GVWIN.GRM
        │   ├── GVWIN001.DSK
        │   ├── floppies
        │   └── gv_2.1_color.properties
        ├── ...
        └── xde
            ├── ...
            └── xde.properties
```

## Internal Notes

When changing or adding to the disk images:

* Decompress either disks-6085.zip or disks-guam.zip
* Add or change the disk image and or germ
* If necessary, update the *Installation* section of this file.
* Recompress the containing folder and delete it afterward. On macOS be sure to get rid of Mac-specific hidden files:

  ```
  zip -r disks-6085.zip disks-6085 -x "*/\.*" -x "__MACOSX"
  rm -rf disks-6085
  zip -r disks-guam.zip disks-guam -x "*/\.*" -x "__MACOSX"
  rm -rf disks-guam
  ```
* Remove the uncompressed folder.

