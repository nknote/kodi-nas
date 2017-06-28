#!/bin/sh
# stop service for refreshing
service tvheadend stop
rm /home/hts/.hts/tvheadend/epgdb.v2

sleep 10

# start service and insert data
service tvheadend start

# get epg data
cd /home/hts/epg
./epg2xml.php

# autorec processing
./xmlTitleConverter.php

cat /home/hts/epg/xmltv.xml | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
