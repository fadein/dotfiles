#!/bin/bash
# Erik's xinitrc for DWM
# Sat Feb 24 2024

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
[[ -x $HOME/.xprofile ]] && source $HOME/.xprofile dwm

# Fixes broken Spotify, Discord
exec dbus-launch --sh-syntax --exit-with-session $DWM 2> $HOME/.xerrors

# original exec line:
# exec $DWM 2> $HOME/.xerrors
