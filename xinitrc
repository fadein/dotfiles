#!/bin/sh
# Erik's xinitrc for DWM
# Thu Dec 22 2022

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

if [ -x $HOME/.dwm/bin/dwm ]; then
	DWM=$HOME/.dwm/bin/dwm
elif [ -x /usr/local/bin/dwm.bin ]; then
	DWM=/usr/local/bin/dwm.bin
else
	echo "Could not find an executable for dwm"
	exit 1
fi


# Start the window manager:
source $HOME/.xprofile dwm
exec $DWM 2> $HOME/.xerrors
