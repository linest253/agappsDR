#!/bin/sh

FILE=/opt/agappsDR/etc/newvfstab

for i in `cat $FILE | awk '{print $3}' `
do
	mkdir -p ${i}
done

cat $FILE >> /etc/vfstab

mountall
