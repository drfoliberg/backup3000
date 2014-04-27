backup3000
==========

Contains various backup scripts (not always really tested).

### backup.bash
A backup script that makes sure no backup is lost over a network share.

### tarMover.bash
A file mover to a network share. Moves all files inside directory with logging.  
Files should be archives.

Simple usage exemple :
```
tarMover.bash "/home/user/tobackup" "/media/user/network_share/dumps" >> /home/user/log/my.log 2>&1
```
