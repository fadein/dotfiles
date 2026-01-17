#!/bin/sh

# When the environment variable DRYRUN is non-empty, do not
# actually make any changes, but only show what would be done

set -e


# Print a command, then run it (unless $DRYRUN is non-empty)
echodo() {
	echo $@
	[ 0"$DRYRUN" = "0" ] && "$@" || true
}

# Given a source directory and a file's name,
# link the file from the source directory into $HOME.
#
# If a source file exists under the subdirectory named for $HOSTNAME,
# link that file to $HOME instead
linkToHome() {
	if [ $# -lt 2 ]; then
		echo Usage: $0 SRC_DIR SRC_NAME
	else
		SRC_DIR=$1
		SRC_NAME=$2
		DEST_NAME=$HOME/.$SRC_NAME

		if [ -f $SRC_DIR/host-$HOSTNAME/$SRC_NAME ]; then
			SRC_DIR=$SRC_DIR/host-$HOSTNAME
		fi

		if   [ -h $DEST_NAME ]; then
			if [ "$(readlink $DEST_NAME)" != "$SRC_NAME" ]; then
				echo "$DEST_NAME is already a symlink which doesn't point here"
			else
				echo "OK: $DEST_NAME -> $SRC_NAME"
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
			echodo ln -s $SRC_DIR/$SRC_NAME $DEST_NAME
		fi
	fi
}

# Remove a symlink that points into this repository
removeLink() {
	HERE=$1
	DEST_NAME=$HOME/$2

	if ! [ -h $DEST_NAME ]; then
		echo "'$DEST_NAME' is not a symlink, skipping..."
	else
		local DEST_DIR=$(dirname $(readlink $DEST_NAME))
		while [ "$DEST_DIR" != "$HERE" -a "$DEST_DIR" != "/" ]; do
			DEST_DIR=$(dirname $DEST_DIR)
		done
		if [ "$DEST_DIR" != "/" ]; then
			echodo rm "$DEST_NAME"
		else
			echo "'$DEST_NAME' does not link into this repository, skipping..."
		fi
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

# Resolve the location of this script
HERE=$(dirname $(readlink -f "$0"))
FIND_CMD=" find $HERE \( -name '.?*' -o -name linkToHome.sh -o -name 'host-*' \) -prune -o -type f -printf '%P '"

if [ 0"$1" = 0"-r" ]; then
	# Clean up old symlinks
	for F in $(eval $FIND_CMD); do
		removeLink $HERE .$F
	done
else

	# Link these files and directories into $HOME
	for F in $(eval $FIND_CMD); do
		linkToHome $HERE $F
	done
fi

# vim: set noexpandtab:
