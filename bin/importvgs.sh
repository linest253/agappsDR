#!/bin/sh

for i in agappsdg1 agappsvg dssdg rewardsdg swvg system techsup1vg techsup2vg vistadg tukvvldap01vg
do
	vxdg import $i
	for j in `vxprint -g $i -ht | grep "^v" | awk '{print $2}'`
	do
		vxvol -g $i start $j
	done

	echo Done with $i
done

