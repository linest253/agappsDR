#!/bin/sh

# Find out whether this is a test or for real.
# I'm asking now, but wont use the answer until file systems are mounted
# because it'll take a while to get there and I don't want to catch someone
# napping.
echo ""
echo ""
echo "Is this a test? Because if it is, I'd like to remove the Xtivia DB Alerts"
echo "and TWS so no one will think agapps is having problems."
echo "Is this a DR test? (Y/N)"
read ANS
echo ""
echo ""

ANS=`echo $ANS | tr y Y`

# Split off the mirror volume on vsadmin@tukvvsan03
ssh vsadmin@tukvvsan03 snapmirror quiesce -destination-path vsadmin@tukvvsan03:seavvsolvm01_mirror
ssh vsadmin@tukvvsan03 snapmirror break -destination-path vsadmin@tukvvsan03:seavvsolvm01_mirror
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/agappsdg1 -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/agappsvg -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/dssdg -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/rewardsdg -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/swvg -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/system -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/techsup1vg -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/techsup2vg -igroup tukvvsolvm01
ssh vsadmin@tukvvsan03 lun map -path /vol/seavvsolvm01_mirror/vistadg -igroup tukvvsolvm01


# some of the following is directory dependent, so go there.
cd /opt/agappsDR/bin

# Clear the flags from the clones that say the disks belong to the McGee Bldg
echo "Clearing disk import flags"
./vxclearimport.sh

# Import the VGs and activate all 5 bajillion volumes.
echo "Importing volume groups and starting volumes. This could take 5-10 minutes."
./importvgs.sh
echo "Volume import done."

echo "Mounting file systems"

# Add entries to /etc/vfstab and mount everything
./add2vfstab.sh

# If this is just a test, we disable things that people might find alarming.
if [ $ANS = Y ]
then
	rm /zones/agapps/agapps_root/root/var/spool/cron/crontabs/vdba
	rm /zones/agapps/agapps_root/root/etc/rc2.d/S99maestro
fi

# Fix the IP addresses so they'll work at Qwest 
echo "Changing IP addresses"
sed  's/159.49.42.249\/22/10.70.106.26\/23/' /zones/agapps/DR/agapps.cfg >/zones/agapps/DR/agapps.cfg1
sed  's/159.49.42.251\/22/10.70.106.27\/23/' /zones/agapps/DR/agapps.cfg1 >/zones/agapps/DR/agapps.cfg2
sed  's/aggr33/nxge0/' /zones/agapps/DR/agapps.cfg2 >/zones/agapps/DR/agapps.cfg3
cp /zones/agapps/agapps_root/root/etc/hosts /zones/agapps/agapps_root/root/etc/hosts.PREMUNGED
sed  's/159.49.42.249/10.70.106.26/' /zones/agapps/agapps_root/root/etc/hosts > /tmp/agappshost1
sed  's/159.49.42.251/10.70.106.27/' /tmp/agappshost1 > /tmp/agappshost
cp /tmp/agappshost /zones/agapps/agapps_root/root/etc/hosts

# make the VxVM stuff visible to the container
rm -rf /zones/agapps/agapps_root/dev/vx
cd /dev
tar cvpf - vx | ( cd /zones/agapps/agapps_root/dev; tar xvpf - )
chmod a+rx /zones/agapps/agapps_root/dev/vx
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/agappsdg1
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/agappsvg
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/dssdg
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/rewardsdg
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/vistadg
chmod -R 660 /zones/agapps/agapps_root/dev/vx
chown -R informix:informix /zones/agapps/agapps_root/dev/vx
find /zones/agapps/agapps_root/dev/vx -type d -exec chmod 770 {} \;


zonecfg -z agapps -f /zones/agapps/DR/agapps.cfg3
zoneadm -z agapps attach -F
/usr/lib/brand/solaris9/s9_p2v agapps

echo ""
echo Now you can boot the zone with "zoneadm -z agapps boot".
echo Open a separate window and run "zlogin -C agapps" first.
