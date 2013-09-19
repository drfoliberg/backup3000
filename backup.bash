#!/bin/bash
#backup.bash backupName folderToBackup destination fallback [tmp=/tmp]
#author Justin Duplesis
# exit 0: script executed with no error
# exit 1: permission error
# exit 2: parameter error
# exit 3: invalid directory/file

LOGTIME=$(date '+%c');
STARTTIME=$(date '+%s');
SCRIPT="$(readlink -f ${BASH_SOURCE[0]})";
BASE=$(dirname $SCRIPT);
SCRIPTLOGDIR="$BASE/logs";
SCRIPTLOGFILE="script.log";
SCRIPTLOG="$SCRIPTLOGDIR/$SCRIPTLOGFILE";
USER=$(whoami);
DATE=$(date +%y%m%d-%H%M);

#Script log directory
if [ ! -d $SCRIPTLOGDIR ] ; then
    echo "[INFO] [NOW!] The script log folder does not exist. Atempting to create the directory.";
    if [ ! -w $BASE ] ; then
		echo "[CRIT] The directory '$BASE' is write protected. Cannot create log directory as user: $USER";
		exit 1;
	fi
	$(mkdir $SCRIPTLOGDIR);
fi
if [ ! -r $SCRIPTLOGDIR ] ; then
    echo "[CRIT] [NOW!] The script log folder is read protected!. Executing as $USER ";
    exit 1;
fi
if [ ! -w $SCRIPTLOGDIR ] ; then
    echo "[CRIT] [NOW!] The script log folder is write protected!. Executing as $USER ";
    exit 1;
fi

#parsing parameters
echo "[INFO] [$LOGTIME] Script called parsing parameters..." >> $SCRIPTLOG;

if [ $# -lt 4 ] || [ $# -gt 5 ] ; then
   echo "Usage: $0 backupName folderToBackup destinationFolder fallbackFolder [tmpFolder]";
   echo "[CRIT] [$LOGTIME] Script received $# arguments expected 4 to 5" >> $SCRIPTLOG;
   exit 2;
fi

backup_name=$1;
backu_origin=$2;
backup_destination=$3;
backup_fallback=$4;
backup_tmp="/tmp";
backup_log="SCRIPTLOGDIR/$backup_name.log";
fallback_mode=false;

if [ $# -gt 4 ] ; then
   backup_tmp=$5;
fi

#validating parameters

#backup name
if [[ "$backup_name" == *"/"* ]]; then
	echo "[CRIT] [$LOGTIME] The backup name '$backup_name' contains invalid caracters!" >> $SCRIPTLOG;
    exit 2;
fi

#log file
if [ ! -f $backup_log ]; then
	echo "[INFO] [$LOGTIME] [$backup_name] The log file for the backup does not exist. Creating base file." >> $SCRIPTLOG;
	touch $backup_log;
	echo "[INFO] [$LOGTIME] Log file created !" >> $backup_log;
fi

#backup origin
if [ ! -d $backup_origin ]; then
	echo "[CRIT] [$LOGTIME] [$backup_name] The directory '$backup_origin' to backup was not found on the system ! " >> $SCRIPTLOG;
    exit 3;
fi

if [ ! -r $backup_origin ]; then
	echo "[CRIT] [$LOGTIME] [$backup_name] The script's user ($USER)' was denied read access to '$backup_origin' !" >> $SCRIPTLOG;
    exit 2;
fi

#backup fallback
if [ ! -d $backup_fallback ]; then
	echo "[CRIT] [$LOGTIME] [$backup_name] The fallback directory '$backup_fallback' was not found on the system ! " >> $SCRIPTLOG;
    exit 3;
fi

if [ ! -w $backup_fallback ]; then
	echo "[CRIT] [$LOGTIME] [$backup_name] The script's user ($USER)' was denied write access to '$backup_fallback' !" >> $SCRIPTLOG;
    exit 2;
fi

#we switch to the backup's log file for logging at this point.
echo "[INFO] [$LOGTIME] [$backup_name] Arguments OK!. Switching to the backup's log in $backup_log !" >> $SCRIPTLOG;

LOGTIME=$(date '+%c');
echo "[INFO] [$LOGTIME] Backup script called with valid arguments" >> $SCRIPTLOG;

#checking if destination directory exists
if [ ! -d $backup_destination  ] || [ ! -w $backup_destination ]; then
	echo "[WARN] [$LOGTIME] The destination directory '$backup_destination' is not available. Falling back to the directory '$backup_fallback' !" >> $backup_log;
	fallback_mode=true;
else
	echo "[INFO] [$LOGTIME] The destination directory '$backup_destination' is available." >> $backup_log;
fi

#executing tar with xz to tmp file
file_name="$backup_name$DATE.tar.xz";
tmp_file="$backup_tmp/file_name.tmp";
tar -cJPF $backup_origin $tmp_file;

#moving tmp file to final directory
if [ $fallback_mode ]; then
	(cd $backup_fallback; mv $tmp_file $file_name);
else
	(cd $backup_destination; mv $tmp_file $file_name);
fi

#checking for older backups in the fallback directory to move
if [ ! $fallback_mode ]; then
	(cd $backup_fallback; mv $backup_name* $backup_destination );
fi

