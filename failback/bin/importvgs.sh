#!/bin/sh

for i in `cat ../etc/VGlist.txt`
do
	vxdg import $i
	for j in `vxprint -g $i -ht | grep "^v" | awk '{print $2}'`
	do
		vxvol -g $i start $j
	done

	echo Done with $i
done

