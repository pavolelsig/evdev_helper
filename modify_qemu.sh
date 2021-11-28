#!/bin/bash

#Sources: https://libvirt.org/kbase/qemu-passthrough-security.html
#	  https://passthroughpo.st/using-evdev-passthrough-seamless-vm-input/
#	  https://forum.level1techs.com/t/trying-to-setup-evdev-input-passthrough/139157/5


METHOD="by-id"


if [[ $1 == "by-path" ]]; then
	METHOD="by-path"
fi


#This needs to run with elevated privileges
if [ $EUID -ne 0 ]; then
	echo "Please run this as root!" 
	exit 1
fi


#Deleting old temporary qemu.conf files
if [ -a .temp.qemu.conf ]; then
	rm .temp.qemu.conf
fi


#Create a backup copy of /etc/libvirt/qemu.conf
if ! [ -a .backup.qemu.conf ]; then

#Ensuring that apparmor does not block it
	if [ -a /etc/apparmor.d/abstractions/libvirt-qemu ]; then
		echo "/dev/input/* rw," >> /etc/apparmor.d/abstractions/libvirt-qemu
	fi
	
	cp /etc/libvirt/qemu.conf .backup.qemu.conf
fi


cp /etc/libvirt/qemu.conf .temp.qemu.conf


echo ' ' >> .temp.qemu.conf
echo 'cgroup_device_acl = [' >> .temp.qemu.conf
echo '	"/dev/null", "/dev/full", "/dev/zero",' >> .temp.qemu.conf
echo '	"/dev/random", "/dev/urandom",' >> .temp.qemu.conf
echo '	"/dev/ptmx", "/dev/kvm", "/dev/kqemu",' >> .temp.qemu.conf
echo '	"/dev/rtc","/dev/hpet",' >> .temp.qemu.conf


for entry in `ls -l /dev/input/$METHOD/ | grep "event*"`
	do
		KBD_M=`echo "$entry" | rev | cut -c -4 | rev`
		if [ "$KBD_M" = "ouse" ]; then		
			echo '	"/dev/input/'$METHOD'/'$entry'",' >> .temp.qemu.conf
		elif  [ "$KBD_M" = "-kbd" ]; then
			echo '	"/dev/input/'$METHOD'/'$entry'",' >> .temp.qemu.conf
		fi
done


echo "]" >> .temp.qemu.conf
echo "" >> .temp.qemu.conf
echo 'user = "root"' >> .temp.qemu.conf
echo 'group = "root"' >> .temp.qemu.conf
echo "" >> .temp.qemu.conf
echo "clear_emulator_capabilities = 0" >> .temp.qemu.conf

OLD_PERMISSIONS="#security_default_confined = 1"
NEW_PERMISSIONS="security_default_confined = 0"

sed -i -e "s|${OLD_PERMISSIONS}|${NEW_PERMISSIONS}|" .temp.qemu.conf

cp .temp.qemu.conf /etc/libvirt/qemu.conf
rm .temp.qemu.conf
systemctl restart libvirtd


echo "Done: /etc/libvirt/qemu.conf was successfully modified"
