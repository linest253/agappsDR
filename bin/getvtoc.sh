for i in emcpower7c emcpower8c emcpower9c emcpower10c emcpower11c emcpower12c emcpower13c
do
	/etc/vx/bin/vxprtvtoc -f $i /dev/rdsk/${i}
done
