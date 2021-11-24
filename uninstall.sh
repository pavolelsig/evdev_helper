#!/bin/bash

#This needs to run with elevated privileges
if [ $EUID -ne 0 ]; then
		echo "Please run this as root!" 
		exit 1
fi

if [ -a .backup.qemu.conf ]; then
	cp .backup.qemu.conf /etc/libvirt/qemu.conf
	echo "qemu.conf was successfully modified"
else
	echo "No changes made to qemu.conf"
fi