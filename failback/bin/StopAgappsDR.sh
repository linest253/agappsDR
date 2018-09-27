#!/bin/sh

echo ""
echo ""
echo "A couple questions first:
echo "
echo "Are the disks for seavvsolvm01 copied back split and mapped? If not, Ctrl-C out of here and take care of that first."
echo "Otherwise, press any key to continue."
echo ""
echo ""
read ANS

cfgadm -al
devfsadm
vxdctl initdmp
vxdctl enable

# Clear the flags from the clones that say the disks belong to the McGee Bldg
echo "Clearing disk import flags"
./vxclearimport.sh

echo ""
echo ""
echo "Is it OK? Press return to continue or else Ctrl-C."
echo ""
echo ""
read ANS

# Import the VGs and activate all 5 bajillion volumes.
echo "Importing volume groups and starting volumes. This could take 5-10 minutes."
./importvgs.sh
echo "Volume import done."

echo ""
echo ""
echo "Is it OK? Press return to continue or else Ctrl-C."
echo ""
echo ""
read ANS

echo "Mounting file systems"

# Add entries to /etc/vfstab and mount everything
./add2vfstab.sh

# Fix the /etc/hosts file:
cp /zones/agapps/agapps_root/root/etc/hosts /zones/agapps/agapps_root/root/etc/hosts.PREMUNGED
sed  's/10.70.106.26/159.49.42.249/' /zones/agapps/agapps_root/root/etc/hosts > /tmp/agappshost1
sed  's/10.70.106.27/159.49.42.251/' /tmp/agappshost1 > /tmp/agappshost
cp /tmp/agappshost /zones/agapps/agapps_root/root/etc/hosts

# make the VxVM stuff visible to the container
rm -rf /zones/agapps/agapps_root/dev/vx
cd /dev
tar cvpf - vx | ( cd /zones/agapps/agapps_root/dev; tar xvpf - )
chmod -R 770 /zones/agapps/agapps_root/dev/vx
chmod a+rx /zones/agapps/agapps_root/dev/vx
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/agappsdg1
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/agappsvg
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/dssdg
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/rewardsdg
chmod a+rx /zones/agapps/agapps_root/dev/vx/rdsk/vistadg
chown -R informix:informix /zones/agapps/agapps_root/dev/vx
find /zones/agapps/agapps_root/dev/vx -type d -exec chmod 770 {} \;

# Re-import the ORIGINAL zone definition:
zonecfg -z agapps -f /zones/agapps/DR/agapps.cfg
zoneadm -z agapps attach -F
/usr/lib/brand/solaris9/s9_p2v agapps

echo ""
echo Now you can boot the zone with "zoneadm -z agapps boot".
echo Open a separate window and run "zlogin -C agapps" first.

echo "Also, add techsup1 and 2 back"
