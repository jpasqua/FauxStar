# FauxStar: The Lisp World

Using the instructions below you can add Lisp capabilities to *FauxStar* based on the very impressive [Medley Interlisp Project](https://interlisp.org) which can be found in this [GitHub repo](https://github.com/Interlisp/medley).

Special thanks to [Paola Amoroso](https://github.com/pamoroso) for answering all my questions about getting Medley up and running.

I don't know my way around the Lisp world, so this is a bare-bones installation of Medley. For many more details on the operation of the emulator, please refer to extensive documentation provided by the [Medley Interlisp Project](https://interlisp.org). In particular take a look at [Using Medley InterLisp](https://interlisp.org/doc/info/Using.html).

***Windows***: The Lisp installation on Windows is largely a manual process. When asked to do so, please follow the process found on the [Medley GitHub Site](https://interlisp.org/software/install-and-run/windows/native/) that describes how to do a native Windows installation.

As part of the process you will be asked where you want to install the files. Do not accept the default folder it suggests. The installation script will tell you the folder to use before you are asked.

<a id=”Usage”></a>
## Usage

To run the emulator use the `lisp.sh` script in the `lisp` directory. If you run the script with no parameters you will be guided through the choice of available options. At the moment that is simply whether you want to run in fullscreen mode.

```
Usage: lisp/lisp.sh [-?]|[-fullscreen] [emulator_parameters...]
Example:
  lisp/lisp.sh -fullscreen

For a guided process, provide no parameters
  lisp/lisp.sh
```

Any additional parameters that you provide will be passed along to the emulator. A full list can be found at the [repo](https://github.com/Interlisp/medley).

### Fullscreen Notes

When using the --fullscreen option the emuator window will occupy the entire display. There will be no window controls or scrollbars. The emulated display will be made the same size as the physical display. When you exit the Medley Lisp environment, the fullscreen window will close automatically.

### Shutting down the system

From the [Medley documentation](https://github.com/Interlisp/medley?tab=readme-ov-file#exiting-the-system):

The system may be exited from the Interlisp prompt by typing:

```
(LOGOUT)
```

Or from the Common Lisp prompt with:

```
(IL:LOGOUT)
```

When you log out of the system, Medley automatically creates a binary dump of your system located in your home directory named lisp.virtualmem. The next time you run the system, if you don't specify a specific image to run, Medley restores that image so that you can continue right where you left off.



