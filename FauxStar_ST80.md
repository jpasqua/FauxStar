# FauxStar: The Smalltalk-80 World

Using the instructions below you can add Samlltalk-80 capabilities to *FauxStar* based on the excellent [ST80](https://github.com/devhawala/ST80) by [@devhawala](https://github.com/devhawala). We will actually use my fork of *ST80* which has minor tweaks for fullscreen operation for a more immersive experience on the *FauxStar* replica.

For many more details on the operation of the emulator, refer to the original, and much more comprehensive, documentation provided by [@devhawala](https://github.com/devhawala)

## Nomenclature

| Term          | Meaning        |
|:------------- |:---------------|
| ST80   | The name of the emulator itself, not a command for running it.    |
| Version: *v2*, *v6*   | The version of Smalltalk-80 that will be emulated.    |
| World   | A world corresponds to an environment to run. A world is specific to an emulator version (*v2* or *v6*) and contains all the components necessary for the emulation.    |

<a id=”Usage”></a>
## Usage

To run the emulator use the `st80.sh` script in the `st-80` directory. If you run the script with no parameters you will be guided through the choice of available worlds and options. Alternatively you can specify the emulator and world explicitly.

```
Usage: fauxstar/st80/st80.sh [-h|--help] -p|--portal -e|--emulator (v2|v6) -w|--world <world_name> [-- other_params]

  -h, --help          Show this help message
  -p, --portal        Enable portal mode (Also sends '-fullscreen' to the emulator)
  -e, --emulator      Sets the emulator type to either 'v2' or 'v6'
  -w, --world         Sets the world to the provided value
  --                  Pass any other parameters to the emulator

With no parameters you will be taken through a guided process
```

When you're using the guided experience you'll be presented with a list of available worlds. If you add your own world (see below) it will appear in this list. After selecting a world from the list, you'll be asked if you wish to run in full screen mode and whether you'd like to supply any additional parameters. Once you've answered all the questions, the emulator will be launched. The command used to launch it will be displayed in the terminal so if you'd like to run this world again, you can just copy and paste the command rather than going through the menus.

When you're not using the menu, there are two required parameters:

1. `--emulator`: Specifies which version of the emulator to use, v2 or v6.
2. `--world`: The name of a world in the `worlds` subdirectory. The worlds are organized around which version of Smalltalk-80:
	* *v2*: 
		* alto
	* *v6*
		* analyst
		* vanilla

You may optionally provide the `--portal` option which is useful for viewing in fullscreen mode on a physical display that is smaller than the emulated display. If you provide the `--portal` option, the `--fullscreen` option will be provided to the emulator automatically.

You may also add parameters that will be passed along to the emulator after the "end-of-parameters" delimiter:  `--` . A full list can be found at the [repo](https://github.com/devhawala/ST80#invoking-st80), including the `--fullscreen` option which is described below.

### Fullscreen Notes

When using the --fullscreen option the emuator window will occupy the entire display. There will be no window controls and no status bar (even if you used the `--statusline` option). This is useful for *FauxStar* to create an immersive experience. When you exit Smalltalk, the fullscreen window will close automatically.

When you launch in fullscreen mode the emulator will try to match the emualted display size to the physical display size. This will not happen in two circumstances. First, if the Smalltalk image contains an explicit setting for the display size. For example:

```
	DisplayScreen displayExtent: 1152@862
```

In this case the display will take on that size whether it is bigger or smaller than the physical display. Second, if the physical screen size is larger than the emulator can accommodate. The emualted screen can be at most 1,048,576 pixels. For example, 1024x1024. If the physical screen is larger than that, the emulated display size will be set to an arbitrary size that is below the limit.

At any time in the emulated environment you may change the emulated screen size by sending a displayExtent: message to DisplayScreen:

```
	DisplayScreen displayExtent: 1024@768
```

Using the `--portal` option is useful if your physical display is smaller than the emulated display. In this case you will view the emulated display through a "portal" which is the size of the physical display. The  portal will pan around the emulated display as the mouse hits the edges of the portal.

### Shutting down the system

Shutting down a running emulation can be done in a couple of ways:

1. Use the middle mouse button over the "desktop". That will [pop up a menu](images/st80/QuitMenu.png) which includes the "quit" option. Select that. Once you do, you'll get another pop-up asking whether you'd like to save before quitting. Make your selection and soon after, the emulation will terminate.
2. If you are running in windowed mode, not fullscreen, you can simply close the window. You'll get a confirmation dialog that [looks like this](images/st80/CloseConfirm.png) that lets you save before quitting if desired.
3. Finally, you can kill the emulator from the command line where it was launched (CTRL-C), or with a task manager. In this case any changes youve made will be lost.

## Adding your own worlds

The folder structure for st-80 is relevant if you want to add your own "worlds". You can see the structure below. Note that there may be new worlds or the names may change. The figure is meant to illustrate the overall structure. For a detailed description of what all these files are and how they are used, refer to [@devhawala's](https://github.com/devhawala) [readme file](https://github.com/jpasqua/ST80/blob/master/readme.md).

You'll notice that each world contains a file named `image_name.txt`. This is used by the launch script to indicate the path to the image to be used. If you add a world, be sure to add this file.

```
st80
├── st80vm.jar	# The emulator code
├── st80.sh		# The script used to launch the emulator
└── worlds
    ├── v2
    │   └── alto
    │       ├── image_name.txt
    │       ├── altodisk-files
    │       │   ├── Biplane.form
    │       │   └── ...
    │       └── snapshot.im
    └── v6
        ├── analyst
        │   ├── image_name.txt
        │   ├── ;searchpath.txt
        │   ├── data
        │   │   ├── 1100.image
        │   │   └── ...
        │   └── system
        │       ├── Analyst-DV6.initialChanges
        │       ├── ...
        │       └── ST80-DV6.sources
        └── vanilla
        │   ├── image_name.txt
            ├── ;searchpath.txt
            └── Smalltalk
                ├── Goodies
                │   ├── Animation-DV6.st
                │   └── ...
                ├── ...
                └── snapshot.im
```

## Internal Notes

The worlds are stored in compressed form on git. When they are to be updated, remember to exclude any OS specific files that might get included. When changing or adding to the worlds, follow this process to update the associated zip file:

* Decompress the file of interest, for example, `worlds/v2/alto.zip`
* Add or change files in the folder that resulted from unzipping
* If the change merits update to the documentation (e.g. a new world), then do so.
* Recompress the containing folder and delete the folder afterward. On macOS be sure to get rid of Mac-specific hidden files.
* Let's say you've made changes to the files in `worlds/v2/alto` and you want to regenerate `alto.zip`. 

  ```
  cd worlds/v2/
  zip -r alto.zip alto -x "*/\.*" -x "__MACOSX"
  ```
