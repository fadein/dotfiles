#!/bin/sh

# When the environment variable DRYRUN is non-empty, do not
# actually make any changes, but only show what would be done


PAYLOAD_FILES="ackrc csirc dircolors gitconfig inputrc Xdefaults xinitrc xprofile config/picom.conf"

set -e

echodo() {
	echo $@
	[ 0"$DRYRUN" = "0" ] && $@ || true
}

linkToHome() {
	if [ $# -lt 2 ]; then
		echo Usage: $0 SOURCE_NAME DEST_NAME
	else
		SOURCE_NAME=$1
		DEST_NAME=$HOME/$2

		if [ -h   $DEST_NAME ]; then
			if [ "$(readlink $DEST_NAME)" != "$SOURCE_NAME" ]; then
				echo "$DEST_NAME is already a symlink which doesn't point here"
			fi

		elif [ -d $DEST_NAME ]; then
			echo  $DEST_NAME already exists and is a directory

		elif [ -b $DEST_NAME ]; then
			echo  $DEST_NAME already exists as a block special

		elif [ -c $DEST_NAME ]; then
			echo  $DEST_NAME already exists as a character special

		elif [ -p $DEST_NAME ]; then
			echo  $DEST_NAME already exists as a named pipe

		elif [ -S $DEST_NAME ]; then
			echo  $DEST_NAME already exists as a socket

		elif [ -f $DEST_NAME ]; then
			echo  $DEST_NAME already exists as a regular file

		elif [ -e $DEST_NAME ]; then
			echo  $DEST_NAME already exists
		else
			echodo ln -s $SOURCE_NAME $DEST_NAME
		fi
	fi
}

removeLink() {
	DEST_NAME=$HOME/$1

	if ! [ -h $DEST_NAME ]; then
		echo "'$DEST_NAME' is not a symlink, skipping..."
	else
		echodo rm $DEST_NAME
	fi
}

# make sure that $HOME is defined
if [ 0"$HOME" = "0" ]; then
	echo "HOME is empty or unset!"
	exit 1
fi

if [ 0"$DRYRUN" != "0" ]; then
	echo ====================
	echo THIS IS A DRY RUN!!!
	echo ====================
	echo
fi


if [ 0"$1" = 0"-r" ]; then
	# Clean up old symlinks
	for F in $(echo $PAYLOAD_FILES); do
		removeLink .$F
	done
else
	# Resolve the location of this script
	HERE=$(dirname $(readlink -f $0))

	# Link these files and directories into $HOME
	for F in $(echo $PAYLOAD_FILES); do
		linkToHome $HERE/$F .$F
	done
fi
