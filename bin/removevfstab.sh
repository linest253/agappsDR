#!/bin/sh

/usr/local/bin/sed -i -e '1,/^# Start of AGAPPS file systems/!{ /^# End of AGAPPS file systems/,/^# Start of AGAPPS file systems/!d; }' /etc/vfstab

/usr/local/bin/sed -i -e '/^# Start of AGAPPS file systems/d' /etc/vfstab
/usr/local/bin/sed -i -e '/^# End of AGAPPS file systems/d' /etc/vfstab
