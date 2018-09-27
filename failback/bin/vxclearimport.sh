vxdctl enable
vxdisk scandisks

for i in `cat ../etc/disklist.txt`
do
	vxdisk clearimport $i
done
