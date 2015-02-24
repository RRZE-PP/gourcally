#!/bin/bash

# Copyright (C) 2015 by Dominik Volkamer, RRZE, FAU
# dominik.volkamer@fau.de
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

#usage function
usage(){
cat <<EOF
Usage: $0 [options]

This script renders automatically videos for list of svn repositories with gource. It also checks if a video of the actual revision already exists (to save render time).

  -h		show this help text
  -c [FILE]	path to config file (see config_template for help) [MANDATORY]
  -f		force rendering of all videos (i.e. no check if there is already a up-to-date video)
EOF
}

#check for parameters
FORCE=0
while getopts 'fc:h' OPTION ; do
	case "$OPTION" in
		f)	FORCE=1;;
		c)	CONFIG="$OPTARG";;
		h)	usage
			exit 0;;
		\?)	usage
		    	exit 1;;
	esac
done

#check if there is a config file
if [ -z "$CONFIG" ]; then
	usage
	exit 1
else	
	#load config file
	source "$CONFIG"
fi

#check if the data / copy directory exists
if [ ! -e "$DATADIR" ]; then
	echo "Data directory doesn't exist (see config file). Exiting."
	exit 1
fi

if [ ! -e "$COPYDIR" ]; then
	echo "Copy directory doesn't exist (see config file). Exiting."
	exit 1
fi

#check if gource, svn and avconv are installed
if ! command -v gource  >/dev/null; then
	echo "Please install gource to use this script. Exiting."
	exit 1
fi

if ! command -v avconv  >/dev/null; then
	echo "Please install avconv to use this script. Exiting."
	exit 1
fi

if ! command -v svn >/dev/null; then
	echo "Please install svn to use this script. Exiting."
	exit 1
fi

# begin a for-loop to run the script for each repository in the list in the config file
for i in "${REPOS[@]}"; do

	echo ""
	echo "Running gourcally for the repository $i"
	echo ""

	###############################################################
	#       VARIABLES
	###############################################################
	
	REPO=$i #repository variable
	VID="$DATADIR"/"$REPO"/"${REPO}".mp4 #path to the video file
	LOG="$DATADIR"/"$REPO"/"${REPO}".xml #path to the log file
	LAST="$DATADIR"/"$REPO"/"${REPO}"_lastrevision #path to the file with the last revison
	ACTUAL="$DATADIR"/"$REPO"/"${REPO}"_actualrevision #path to the file with the actual revison
	
	###############################################################
	#       CHECKS
	###############################################################

	#check if force option is set
	if [ $FORCE == 0 ]; then
		#check if last revision exists
		if [ -e "$LAST" ]; then
	
			echo "> Old revision found. Compare the revisions..."
	
			#download the actual revision number of the repository
			svn info --username "$USER" --password "$PASSWD" "$SVN"/"$REPO" | grep -i Revision > "$ACTUAL"
	
			#compare last and actual revision
			diff "$LAST" "$ACTUAL"
	
			#decision if a video should be generated
			if [ $? = 0 ]; then
				echo ">> There are no changes since last video generation. Continue with next repository."
				continue
			else
				echo ">> A newer revision is available. Generating a new video..."
			fi
		fi
	fi
		
	#if there is no directory for the repository in the data directory (first run), create it
	if [ ! -e "${DATADIR}"/"${REPO}" ]; then
		mkdir "$DATADIR"/"$REPO"
	fi
	
	#if there is no log file available, download it from svn
	if [ ! -e "$LOG" ]; then
		echo ">>> Downloading log file..."
		svn log -r 1:HEAD --verbose --xml --quiet --username "$USER" --password "$PASSWD" "$SVN"/"$REPO" > "$LOG" 
	fi
	
	###############################################################
	#       RENDER VIDEO
	###############################################################
	
	#generate video with gource and avconf
	echo ">>> Generating video for repository $REPO..."
	echo ">>> IMPORTANT: Don't close the gource pop-up window, because it will stop the video rendering!"
	sleep 4

	#for gource help see the man page of gource itself (or its wiki), avconv options at the end are copied from the gource wiki
	#for gource options, which end with a variable, have a look to the comments in the config file of this script
	gource "$LOG" \
		-1280x720 \
		--multi-sampling \
		--stop-at-end \
		--seconds-per-day "$SPD" \
		--auto-skip-seconds "$ASS"\
		--bloom-multiplier "$BLOOMM" \
		--bloom-intensity "$BLOOMI" \
		--hide "$HIDE" \
		--file-idle-time "$FILEIDLE" \
		--max-file-lag "$MAXFILELAG" \
		--title "$TITLE" \
		--user-image-dir "$ICONS" \
		--logo "$LOGO" \
		--default-user-image "$DEFICON" \
		--date-format "$DATEFORMAT" \
		--user-scale "$USERSCALE" \
		--max-files "$MAXFILES" \
		-r 60 -o - | avconv \
		-y -r 60 -v quiet -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset ultrafast -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 "$VID"
	
	#if the video is successfully generated, then...
	if [ $? = 0 ]; then
		#delete old log file
		rm -rf "$LOG"
		#create a file with last revision
		svn info --username "$USER" --password "$PASSWD" "$SVN"/"$REPO" | grep -i Revision > "$LAST"
		#copy video to copy directory
		echo ">>> Copying video to $COPYDIR..."
		cp -f "$VID" "$COPYDIR"
	else
		echo ">>> Sorry, here went something wrong. The video couldn't be generated."
	fi
done

echo ""
echo "Congratulation. All videos generated. Exiting."

exit 0