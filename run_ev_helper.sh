#!/bin/bash


KBD_COUNT=1
MOUSE_COUNT=1
METHOD="by-id"


if [[ $1 == "by-path" ]]; then
	METHOD="by-path"
fi

chmod 755 modify_qemu.sh
chmod 755 uninstall.sh

#This needs to run with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi



#checking for evdev devices, removing old changes, updating qemu.conf
	./uninstall.sh
	./modify_qemu.sh $METHOD

NEW_DOMAIN="<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>"

echo $NEW_DOMAIN > evdev.txt
echo "" >> evdev.txt

echo " <qemu:commandline>" >> evdev.txt

for entry in `ls -l /dev/input/$METHOD/ | grep "event*"`
do
	KBD_M=`echo "$entry" | rev | cut -c -4 | rev`
	if [ "$KBD_M" = "ouse" ]
		then
			echo "	<qemu:arg value='-object'/>" >> evdev.txt
    			echo "	<qemu:arg value='input-linux,id=mouse"$MOUSE_COUNT",evdev=/dev/input/$METHOD/$entry'/>" >> evdev.txt
			((++MOUSE_COUNT))
	elif  [ "$KBD_M" = "-kbd" ]
	then
			echo "	<qemu:arg value='-object'/>" >> evdev.txt
    			echo "	<qemu:arg value='input-linux,id=kbd"$KBD_COUNT",evdev=/dev/input/$METHOD/$entry,grab_all=on,repeat=on'/>" >> evdev.txt
			((++KBD_COUNT))
	fi
done

echo "  </qemu:commandline>" >> evdev.txt

echo "Success! Results are in evdev.txt "
