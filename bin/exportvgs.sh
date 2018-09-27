#!/bin/sh

for i in `cat /opt/agappsDR/etc/VGlist.txt`
do
	vxdg deport $i
done

