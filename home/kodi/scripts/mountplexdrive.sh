#!/bin/bash

## GLOBAL VARS
LOGFILE="/home/kodi/logs/mountplexdrive.log"
MPOINT="/mnt/plexdrive/"

## UNMOUNT IF SCRIPT WAS RUN WITH unmount PARAMETER
if [[ $1 = "unmount" ]]; then
    echo "Unmounting $MPOINT"
    fusermount -uz $MPOINT
    fusermount -uz /mnt/gdremote/
    fusermount -uz /mnt/eddy/
    exit
fi

## CHECK IF MOUNT ALREADY EXIST AND MOUNT IF NOT
if mountpoint -q $MPOINT ; then
    echo "$MPOINT already mounted"
else
    echo "Mounting $MPOINT"
    # Unmount before remounting
    fusermount -uz /mnt/eddy/
    fusermount -uz /mnt/gdremote
    fusermount -uz $MPOINT
    /usr/bin/plexdrive $MPOINT \
                       -o allow_other \
                       --uid=1000 --gid=1000 --umask=002 \
                       --clear-chunk-max-size=50G \
                       --chunk-size=20M \
                       --refresh-interval=1m \
                       -v 1 &>>$LOGFILE &
    sleep 10
    /usr/bin/sshfs -o uid=1000,gid=1000,allow_other,umask=002 root@localhost:/mnt/plexdrive /mnt/gdremote
    sleep 10
    /usr/bin/unionfs-fuse -o allow_other -o cow -o direct_io -o auto_cache -o sync_read -o uid=1000 -o gid=1000 /mnt/gdlocal=RW:/mnt/gdremote=RO /mnt/eddy
    sleep 10
    echo "Restarting tvheadend"
    /etc/init.d/tvheadend restart
    sleep 10
    echo "Restarting kodi"
    systemctl restart kodi
fi
exit
