#!/bin/bash

# tarMover.bash source destination

# Author Justin Duplessis

# Will move all files in a given directory.
# Used to move local tar backups to a remote server.
# Designed to be called with redirection from stderr/stdout to a file.
# Source should be like path/to/

# exit 0: script executed with no error
# exit 1: permission error
# exit 2: parameter count is invalid
# exit 3: invalid directory given (file given or directory does not exist)

LOGTIME=$(date '+%c');

if [ ! $# -eq 2 ] ; then
   echo "Usage: $0 tar_folder_path tar_destination_path";
   echo "Source should be like /path/to/";
   echo "[CRIT] [$LOGTIME] Script received $# arguments expected 2 arguments";
   exit 2;
fi

SOURCE=$1;
DESTINATION=$2;

# check source exists
if [ ! -d $SOURCE ]; then
	echo "[CRIT] [$LOGTIME] The source directory '$SOURCE' to backup was not found on the system or is not a directory!";
    exit 3;
fi

# check source can be read
if [ ! -r $SOURCE ]; then
	echo "[CRIT] [$LOGTIME] The source directory '$SOURCE' is not readable !";
    exit 1;
fi

# check destination
if [ ! -d $DESTINATION ]; then
	echo "[CRIT] [$LOGTIME] The destination directory '$DESTINATION' was not found on the system or is not a directory!";
    exit 3;
fi

# check destination can be written
if [ ! -w $DESTINATION ]; then
	echo "[CRIT] [$LOGTIME] The source directory '$DESTINATION' is not writable !";
    exit 1;
fi

# loop for each file in directory
cd $SOURCE;
for f in *
do
	# update time
	LOGTIME=$(date '+%c');
	if [ ! -f "$f" ]; then
		echo "[WARN] [$LOGTIME] The source '$f' is ignored because it's not a regular file";
	elif [ -f "$DESTINATION$f" ]; then
		echo "[WARN] [$LOGTIME] The source file '$f' is ignored because the file name exists in destination";
	else
		start_time=$(date '+%s');
		size=$(du -h "$f")
		echo "[INFO] [$LOGTIME] Starting to move file $f of size $size .";
		mv "$f" "$DESTINATION$f"
		LOGTIME=$(date '+%c');
		end_time=$(date '+%s');
		echo "[INFO] [$LOGTIME] Finished to move file $f. Took $(expr $end_time - $start_time) seconds.";
	fi
done

LOGTIME=$(date '+%c');
echo "[INFO] [$LOGTIME] Exiting script cleany.";
exit(0);
