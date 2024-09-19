# FauxStar: The Smalltalk-80 World

Using the instructions below you can add Samlltalk-80 capabilities to *FauxStar* based on the excellent [ST80](https://github.com/devhawala/ST80) by [@devhawala](https://github.com/devhawala). We will actually use my fork of *ST80* which has minor tweaks for fullscreen operation for a more immersive experience on the *FauxStar* replica.

For many more details on the operation of the emulator, refer to the original, and much more comprehensive, documentation provided by [@devhawala](https://github.com/devhawala)

***Limitations***: I've tested this on Mac, Raspberry Pi (Bookworm), and Windows 11; however, all of the instructions and scripts are [Bash scripts](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). To use them directly on Windows you'll have to use something like [git bash](https://gitforwindows.org) or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install). I tested with git bash.

## Nomenclature

| Term          | Meaning        |
|:------------- |:---------------|
| To Be Added   | To Be Added    |
| To Be Added   | To Be Added    |
| To Be Added   | To Be Added    |
| To Be Added   | To Be Added    |

## Installation

If it doesn't already exist, create a directory named `fauxstar` any where you'd like including your home directory. Change directory (`cd`) to the `fauxstar` directory and execute the commands below. They will download and organize the necessary files leaving you with a new subdirectory named `smalltalk-80 `. 

```
curl -L -o ST80-master.zip https://github.com/jpasqua/ST80/archive/refs/heads/master.zip
unzip ST80-master.zip
rm ST80-master.zip
unzip ST80-master/sample-env.zip -d .
mv sample-env smalltalk-80
rm -rf ST80-master
```

## Usage

To run the emulator use the `st80.sh` script in the `smalltalk-80` directory. If you run the script with no parameters you will be guided through the choice of available worlds and options. Alternatively you can specify the emulator and world explicitly.

```
Usage: smalltalk-80/st80.sh [-?]|[<v2|v6> <world_name>] [emulator_parameters...]
Example:
  smalltalk-80/st80.sh v6 analyst -fullscreen

For a guided process, provide no parameters
  smalltalk-80/st80.sh
```

When you're using the guided experience you'll be presented with a list of available worlds. If you add your own world (see below) it will appear in this list. After selecting a world from the list, you'll be asked if you wish to run in full screen mode and whether you'd like to supply any additional parameters. Once you've answered all the questions, the emulator will be launched. The command used to launch it will be displayed in the terminal so if you'd like to run this world again, you can just copy and paste the command rather than going through the menus.

When you're not using the menu, there are two required positional parameters:

1. Smalltalk-80 Version: v2 or v6.
2. World: The name of a world in the `worlds` subdirectory. The worlds are organized around which version of Smalltalk-80:
	* *v2*: 
		* ...
		* ...
		* ...
	* *v6*
		* ...
		* ...
		* ...

You may also add parameters after the first two that will be passed along to the emulator. A full list can be found at the [repo](https://github.com/devhawala/ST80#invoking-st80). Of interest here is the `--fullscreen` parameter which is described below.

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

### Shutting down the system

Shutting down a running emulation can be done in a couple of ways:

1. Use the middle mouse button over the "desktop". That will [pop up a menu](images/st80/QuitMenu.png) which includes the "quit" option. Select that. Once you do, you'll get another pop-up asking whether you'd like to save before quitting. Make your selection and soon after, the emulation will terminate.
2. If you are running in windowed mode, not fullscreen, you can simply close the window. You'll get a confirmation dialog that [looks like this](images/st80/CloseConfirm.png) that lets you save before quitting if desired.
3. Finally, you can kill the emulator from the command line where it was launched (CTRL-C), or with a task manager. In this case any changes youve made will be lost.

## Adding your own worlds

The folder structure for smalltalk-80 is relevant if you want to add your own "worlds". You can see the structure below. Note that there may be new worlds or the names may change. The figure is meant to illustrate the overall structure. See the annotations in the figure below to understand the layout.

```
smalltalk-80
├── st80vm.jar			# The actual emulator code
├── st80.sh				# The launcher script
└── worlds
    ├── v2
    │   ├── vanilla
    │   │   ├── blah
    │   │   ├── blah
    │   │   └── blah
    │   ├── ...
    │   └── analyst
    └── v6
        ├── vanilla
        │   ├── blah
        │   ├── blah
        │   └── blah
        ├── vanilla-1024
        ├── ...
        └── analyst
            ├── ...
            └── blah
```

## License: [![CC BY-NC 4.0][cc-by-nc-shield]][cc-by-nc]

The license for Dwarf can be found at the [Dwarf repo](https://github.com/devhawala/dwarf).

This work is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License][cc-by-nc].

[![CC BY-NC 4.0][cc-by-nc-image]][cc-by-nc]

[cc-by-nc]: https://creativecommons.org/licenses/by-nc/4.0/
[cc-by-nc-image]: https://licensebuttons.net/l/by-nc/4.0/88x31.png
[cc-by-nc-shield]: https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg
