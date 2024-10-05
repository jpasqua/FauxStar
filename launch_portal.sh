#!/usr/bin/env bash

usage() {
    echo "Run a program in a virtual screen of a given size and view"
    echo "that program full screen on the current display. If the"
    echo "virtual screen is larger than the physical screen, the"
    echo "contents will pan within the physical screen portal."
    echo ""
    echo "Usage: $0 prog [-t|--title STRING] [-s|--screenSize wxh] [params...]"
    echo ""
    echo "  prog                : The program to be run (positional, must come first)"
    echo "  -t, --title STRING  : A string to use in a title area"
    echo "  -s, --screenSize wxh: The desired screen size, width and height (e.g., 1152x861)"
    echo "  [params...]         : All remaining parameters will be passed to prog"
    echo ""
    exit 1
}

# Check if at least one argument (the program) is provided
if [ "$#" -lt 1 ]; then
    usage
fi

# Initialize default values
title=""
screenSize="1152x861"

# Extract the program name (first positional argument)
prog=$1
shift

# Parse the remaining options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--title)
            title=$2
            shift 2
            ;;
        -s|--screenSize)
            screenSize=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            break
            ;;
    esac
done

# If no title was supplied, use the name of the program as the title
if [ "$title" == "" ]; then
  title=prog
fi

ip_addr() {
  echo "127.0.0.1"
}

find_open_display() {
  local_ctr=1
  local_result=-1
  while [ ${local_ctr} -lt 64 ];
  do
    if [ ! -e /tmp/.X${local_ctr}-lock ];
    then
      local_result=${local_ctr}
      break
    else
      local_ctr=$(( local_ctr+1 ))
    fi
  done
  echo ${local_result}
}

find_open_port() {
  local_ctr=5900
  local_result=-1
  while [ ${local_ctr} -lt 6000 ];
  do
    ss -a | grep -q "LISTEN.*:${local_ctr}[^0-9]"
    if [ $? -eq 1 ];
    then
      local_result=${local_ctr}
      break
    else
      local_ctr=$(( local_ctr+1 ))
    fi
  done
  echo ${local_result}
}

#
# Make sure prequisites for vnc support are in place
#
if [ -z "$(which Xvnc)" ] || [ "$(Xvnc -version 2>&1 | grep -iq tigervnc; echo $?)" -eq 1 ]
then
  echo "Error: The -v or --vnc flag was set."
  echo "But it appears that that TigerVNC server \(Xvnc\) has not been installed."
  echo "Please install the TigerVNC server and try again.  On Debian and Ubuntu, use:"
  echo "\"sudo apt install tigervnc-standalone-server\". On most other Linux distros, use the"
  echo "distro's package manager to install the \"tigervnc-server\" package."
  echo "Exiting."
  exit 4
fi

if [ -z "$(which vncviewer)" ] || [ "$(vncviewer -v 2>&1 | head -2 | grep -iq tigervnc; echo $?)" -eq 1 ]
then
  echo "Error: The -v or --vnc flag was set."
  echo "But it appears that that the TigerVNC viewer \(vncviewer\) is not installed on your system."
  echo "Please install the TigerVNC viewer and try again.  On Debian and Ubuntu, use:"
  echo "\"sudo apt install tigervnc-viewer\".  On most other Linux distros, use the"
  echo "the distro's package manager to install the \"tigervnc-viewer\" (or sometimes just \"tigervnc\")"
  echo "package."
  echo "Exiting."
  exit 5
else
   vncviewer="$(which vncviewer)"
fi

#
#  Start the log file so we can trace any issues with vnc, etc
#

# Get the process ID (PID) of the current script
PID=$$

# Define the log file path in /tmp, using the process ID to make it unique
SCRIPT_NAME=$(basename "$0")
LOG="/tmp/${SCRIPT_NAME}_${PID}.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting ${prog})..." >> "$LOG"


# are we running in background - used for pretty-fying the echos
case $(ps -o stat= -p $$) in
  *+*) bg=false ;;
  *) bg=true ;;
esac

#
#    find an unused display and an available port
#
ORIGINAL_DISPLAY="${DISPLAY}"
OPEN_DISPLAY="$(find_open_display)"
if [ "${OPEN_DISPLAY}" -eq -1 ];
then
  echo "Error: cannot find an unused DISPLAY between 1 and 63"
  echo "Exiting"
  exit 33
else
  if [ "${bg}" = true ]; then echo; fi
  echo "Using DISPLAY=:${OPEN_DISPLAY}" > $LOG
fi
DISPLAY=":${OPEN_DISPLAY}"
export DISPLAY
VNC_PORT="$(find_open_port)"
export VNC_PORT
if [ "${VNC_PORT}" -eq -1 ];
then
  echo "Error: cannot find an unused port between 5900 and 5999"
  echo "Exiting"
  exit 33
else
  echo "Using VNC_PORT=${VNC_PORT}" > $LOG
fi
#
#  Start the Xvnc server
#
Xvnc "${DISPLAY}" \
     -rfbport "${VNC_PORT}" \
     -geometry "${screenSize}" \
     -SecurityTypes None \
     -NeverShared \
     -DisconnectClients=0 \
     -desktop "${title}" \
     --MaxDisconnectionTime=10 \
     >> "${LOG}" 2>&1 &

sleep .5

#
# Run the specified prog, handing over the pass-on args which are all thats left in the main args array
#
{
  "${prog}" "$@"
  if [ -n "$(pgrep -f "${vnc_exe}.*:${VNC_PORT}")" ]; then vncconfig -disconnect; fi
} &
# Give "prog" time to start.
sleep .5

#
#  Start the vncviewer
#
start_time=$(date +%s)
export DISPLAY="${ORIGINAL_DISPLAY}"
"${vncviewer}"				       \
	-FullScreen 			         \
	-RemoteResize=0            \
  -AlertOnFatalError=0		   \
  -ReconnectOnError=0		     \
  "$(ip_addr)":"${VNC_PORT}" \
  >>"${LOG}" 2>&1			&
wait $!
echo "$(date '+%Y-%m-%d %H:%M:%S') - Exiting" >> "$LOG"

if [ $(( $(date +%s) - start_time )) -lt 5 ]
then
  if [ -z "$(pgrep -f "Xvnc ${DISPLAY}")" ]
  then
    echo "Xvnc server failed to start."
    echo "See log file at ${LOG}"
    echo "Exiting"
    exit 3
  else
    echo "VNC viewer failed to start.";
    echo "See log file at ${LOG}";
    echo "Exiting" ;
    exit 4;
  fi
fi

true
