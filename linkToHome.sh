#!/bin/sh

# When the environment variable DRYRUN is non-empty, do not
# actually make any changes, but only show what would be done

set -e

# Resolve the location of this script
HERE=$(dirname $(readlink -f "$0"))

# Files to link into $HOME
FIND_CMD=" find $HERE \( -name '.?*' -o -name linkToHome.sh -o -name 'host-*' \) -prune -o -type f -printf '%P '"

if [ -t 1 ]; then
	RED=$'\x1b[1;31m'
	GRN=$'\x1b[1;32m'
	YLW=$'\x1b[1;33m'
	CYN=$'\x1b[1;36m'
	RST=$'\x1b[0m'
else
	RED=''
	GRN=''
	YLW=''
	CYN=''
	RST=''
fi

# Print a command, then run it (unless $DRYRUN is non-empty)
echodo() {
	echo ${GRN}✓ $@$RST
	[ 0"$DRYRUN" = "0" ] && "$@" || true
}

# Given a source directory and a file's name,
# link the file from the source directory into $HOME.
#
# If a source file exists under the subdirectory named for $HOSTNAME,
# link that file to $HOME instead
linkToHome() {
	if [ $# -lt 1 ]; then
		echo "${RED}Usage: $0 SRC_NAME [DEST_NAME]$RST"
	else

		local SRC_NAME SRC
		if [ "0$1" == 0. ]; then
			SRC_NAME=$HERE
			SRC=$HERE
		else
			SRC_NAME=$1
			SRC=$HERE/$SRC_NAME
		fi

		local HOST_SRC=$HERE/host-$HOSTNAME/$SRC_NAME
		local DEFAULT
		if [ -f $HOST_SRC ]; then
			DEFAULT=$SRC
			SRC=$HOST_SRC
		fi

		local DEST_NAME
		if [ "0$2" == 0 ]; then
			DEST_NAME=$HOME/.$SRC_NAME
		else
			DEST_NAME=$HOME/.$2
		fi

		if [ -h $DEST_NAME ]; then
			local DEST_LINK="$(readlink $DEST_NAME)" 

			# DEST_LINK is a broken link, remove it
			if [ ! -e "$DEST_LINK" ]; then
				echo "${RED}≠ $DEST_NAME is a broken link, cleaning it up$RST"
				echodo ln -sf $SRC $DEST_NAME

			# upgrade to host-specific link
			elif [ -n "$DEFAULT" -a "$DEST_LINK" == "$DEFAULT" ]; then
				echo "${YLW}≠ $DEST_NAME points to $DEFAULT, updating$RST"
				echodo ln -sf $SRC $DEST_NAME

			# IGNORE: DEST_NAME points to non-managed file
			elif [ -n "$DEST_LINK" -a "$DEST_LINK" != "$SRC" ]; then
				echo "${YLW}≠ $DEST_NAME is already a symlink which doesn't point here$RST"

			# DEST_NAME already points to the correct file
			elif [ "$DEST_LINK" == "$SRC" ]; then
				echo "${CYN}✓ $DEST_NAME → $SRC$RST"

			else
				echo "${RED}█ Not sure what happened here$RST"
			fi

		elif [ -d $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists as a directory$RST"

		elif [ -b $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists as a block special$RST"

		elif [ -c $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists as a character special$RST"

		elif [ -p $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists as a named pipe$RST"

		elif [ -S $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists as a socket$RST"

		elif [ -f $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists as a regular file$RST"

		elif [ -e $DEST_NAME ]; then
			echo  "$YLW✗ $DEST_NAME already exists$RST"
		else
			echodo ln -s $SRC $DEST_NAME
		fi
	fi
}

# Remove a symlink that points into this repository
removeLink() {
	DEST_NAME=$HOME/$1

	if [ -h $DEST_NAME -a ! -e $DEST_NAME ]; then
		echo "$CYN‡ $DEST_NAME is a broken link; cleaning up$RST"
		echodo rm "$DEST_NAME"
	elif [ ! -e $DEST_NAME ]; then
		echo "$RED✗ $DEST_NAME does not exist$RST"
	elif [ ! -h $DEST_NAME ]; then
		echo "$YLW∅ $DEST_NAME is not a symlink$RST"
	else
		local DEST_DIR=$(readlink $DEST_NAME)
		while [ "$DEST_DIR" != "$HERE" -a "$DEST_DIR" != "/" ]; do
			DEST_DIR=$(dirname $DEST_DIR)
		done
		if [ "$DEST_DIR" != "/" ]; then
			echodo rm "$DEST_NAME"
		else
			echo "${YLW}≠ $DEST_NAME is already a symlink which doesn't point here$RST"
		fi
	fi
}


# make sure that $HOME is defined
if [ 0"$HOME" = "0" ]; then
	echo "${RED}✗ HOME is empty or unset!$RST"
	exit 1
fi

if [ 0"$DRYRUN" != "0" ]; then
	echo "${YLW}====================$RST"
	echo "${YLW}THIS IS A DRY RUN!!!$RST"
	echo "${YLW}====================$RST"
	echo
fi

if [ 0"$1" = 0"-r" ]; then
	# Clean up old symlinks
	for F in $(eval $FIND_CMD); do
		removeLink .$F
	done
else

	# Link these files and directories into $HOME
	for F in $(eval $FIND_CMD); do
		linkToHome $F
	done
fi

# vim: set noexpandtab:
