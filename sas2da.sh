#!/bin/sh

# -----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# zmey20000@yahoo.com wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Mikhail Zakharov
# -----------------------------------------------------------------------------

# SAS addresses to /dev/daXXs with drive sizes + drive serials and vendor info.
# Output is sorted by "Serial numbers" to group the same drives together 
# in case they have several SAS connections.
#
# sas2da.sh depends on geom_show.sh: https://github.com/mezantrop/geom_show
#
# 2018/06/01    v0.1    Initial
# 2018/06/02    v0.2    Fixed the bug while "camcontrol smpphylist" parsing
# 2018/06/03    v0.3    Monor changes and bugfixes
#

GEOM_SHOW="./geom_show.sh"

gs=`mktemp /tmp/sas2da.XXX`
$GEOM_SHOW -l -c DISK | awk -F, '{print $2, $3, $10, $11}' | sort > $gs
# Provider Mediasize Ident Description
# da0 8001563222016 VJGSNV0X HGST HUH728080AL5204
# da1 8001563222016 VJGSNV0X HGST HUH728080AL5204
# da10 8001563222016 VJGTAP3X HGST HUH728080AL5204
# ...

# Filter SCSI BUS and Target IDs on SES devices (drive enclosures) only
scbus_targets=`camcontrol devlist | 
        awk 'BEGIN {FS="scbus|target |lun"} /ses/ {print $2, $3}'`
# 4  0 
# 11  0 
# 12  28 
# ...

da_addr=`mktemp /tmp/sas2da.XXX`
printf "$scbus_targets\n" | while read bus target; do
        camcontrol smpphylist "$bus:$target" -l -q 2>/dev/null | 
                grep -v 'ses' | 
                awk 'BEGIN {FS="0x|<.*>"}
                        {
                                match($3, "da[0-9]+");
                                if (RSTART) {
                                        da=substr($3, RSTART, RLENGTH);
                                        print(da, $2)
                                }
                        }'
done | sort > $da_addr
# da0 5000cca2612b0b0d
# da1 5000cca2612b0b0e
# da10 5000cca2612c4402
# ...

echo "Address Dev Size Serial Vendor Model"

join $da_addr $gs | awk '{print $2, $1, $3, $4, $5, $6}' | sort -k 4 
# 5000cca2612b0b0d da0 8001563222016 VJGSNV0X HGSTHUH728080AL5204
# 5000cca2612b0b0e da1 8001563222016 VJGSNV0X HGSTHUH728080AL5204
# 5000cca2612c4402 da10 8001563222016 VJGTAP3X HGSTHUH728080AL5204
# 5000cca2612c4401 da11 8001563222016 VJGTAP3X HGSTHUH728080AL5204
# 5000cca26128680e da12 8001563222016 VJGR6WGX HGSTHUH728080AL5204
# ...

rm $gs $da_addr 
