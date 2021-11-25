# Evdev-helper

Evdev-helper uses an automated script to make setting up evdev seamless. <br/>
With evdev, you can easily switch your input devices between your host and<br/> guest by simultaneously pressing the left and right control buttons. <br/>

All devices to be shared between the VM and the host need to be connected to USB controllers owend by the host and not the VM. 
Simply put, the host retains control of the devices and allows the VM to use them when requested. 

To use the by-path option, simply run: sudo ./run_ev_helper.sh by-path

_______________________________________________________________

# Requirements

  *Virtual Machine Manager<br/>
  *Any popular Linux distribution as the host<br/>
  *Linux or Windows guest<br/>
  
# Tutorial
For a tutorial, go here:<br/>
https://youtu.be/4XDvHQbgujI

_______________________________________________________________

  
# Sources
* https://python-evdev.readthedocs.io/en/latest/
* https://libvirt.org/kbase/qemu-passthrough-security.html
* https://passthroughpo.st/using-evdev-passthrough-seamless-vm-input/
