#!/bin/sh

zoneadm -z agapps halt
zonecfg -z agapps delete -F

for i in `tail -r /etc/vfstab | grep agapps_mnts | awk '{print $3}'`
do
	umount $i
done

umount /zones/agapps

/opt/agappsDR/bin/removevfstab.sh

/opt/agappsDR/bin/exportvgs.sh

#symclone -g agapps2tuk recreate -tgt -precopy -noprompt
