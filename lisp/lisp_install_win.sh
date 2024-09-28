#!/usr/bin/env bash

cat << EOM
Please follow the installation process in the Medley documentation:
  https://interlisp.org/software/install-and-run/windows/native/
Once you have completed the process, Answer 'y' below indicating
that you've done so.
 
NOTE:
    When you perform the installation you will be asked
    where you want the files installed. It will probably use
    a folder in your home directory as the default. Please be
    sure to enter this directory: " $(pwd)

EOM

not_installed=1

while [ "$not_installed" -eq 1 ]; do
    read -p "Have you completed the insatallation? (y/n/q): " response
    case $response in
        yes|y|Y)
			# Test whether the installation was successful
			if [ ! -e "medley.bat" ]; then
                echo
                echo "Lisp does not seem to have been installed in the proper directory."
                echo "Please try the installation process again."
                echo
    			continue
            else
                not_installed=0
			fi
            break
            ;;
        no|n|N)
            echo "Please complete installation before proceeding."
            break
            ;;
        quit|q|Q)
            echo "Installation cancelled."
            echo "* The Medley Interlisp install was cancelled by the user." \
                     >> $FAUXSTAR_INSTALL_DIR/collected_install_notes.txt
            exit 1
            break
            ;;
        *)
            echo "Please answer yes, no, or quit."
            ;;
    esac
done

touch .installed
cat << EOF >> $FAUXSTAR_INSTALL_DIR/collected_install_notes.txt
* The Medley Interlisp system has been installed.
  On Windows this involves a full installation of Cygwin.
  The combination of Cygwin and Medley Interlisp consumes
  a sizable chunk of storage.
EOF
