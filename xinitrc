#!/bin/bash
# Erik's xinitrc for DWM
# Mon Jan 22 2024

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Turn NumLock on (using numlockx)
if [[ -x /usr/bin/numlockx ]]; then
  /usr/bin/numlockx
fi

# merge in defaults and keymaps

if [[ -f $sysresources ]]; then
    xrdb -merge $sysresources
fi

if [[ -f $sysmodmap ]]; then
    xmodmap $sysmodmap
fi

if [[ -f $userresources ]]; then
    xrdb -merge $userresources
fi

if [[ -f $usermodmap ]]; then
    xmodmap $usermodmap
fi

if [[ -x $HOME/.dwm/bin/dwm ]]; then
	DWM=$HOME/.dwm/bin/dwm
elif [[ -x /usr/local/bin/dwm.bin ]]; then
	DWM=/usr/local/bin/dwm.bin
else
	echo "Could not find a DWM executable"
	exit 1
fi


# Start the window manager:
source $HOME/.xprofile dwm
exec $DWM 2> $HOME/.xerrors
