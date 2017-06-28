#!/bin/sh
# stop service for refreshing
service tvheadend stop
rm /home/hts/.hts/tvheadend/epgdb.v2

# get epg data
cd /home/hts/btvepg
/usr/bin/java -jar btvepg.jar -re -u -d 3

# autorec processing
/home/kodi/scripts/xmlTitleConverter.php

# start service and insert data
service tvheadend start
sleep 30
cat /home/hts/btvepg/BtvEPG.xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
