#!/bin/bash

KERNEL=/home/xp4ns3/git/kernels/staging/
DEVICE_NAME="ASUSTek Computer, Inc. Realtek 8188EUS [USB-N10 Nano]"
BUS=$(lsusb | grep "$DEVICE_NAME" | awk '{print $2}')
DEVICE=$(lsusb | grep "$DEVICE_NAME" | awk '{print $4}' | head -c -2 | sed -r 's/^0+|0+$//g')


qemu-system-x86_64 \
	-m 4G \
	-smp 2 \
	-kernel $KERNEL/arch/x86/boot/bzImage \
	-initrd /boot/init
	-append "console=ttyS0 root=/dev/mapper/cr_root rw panic_on_warn=off earlyprintk=serial" \
	-drive file=./usb.img,format=raw \
	-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
	-net nic,model=e1000 \
	-enable-kvm \
	-nographic \
	-pidfile vm.pid \
	-device qemu-xhci \
	-usb -device usb-host,hostbus=$BUS,hostaddr=$DEVICE,guest-reset=false,id=tp \
	-virtfs local,path=./share,mount_tag=host0,security_model=passthrough,id=host0 \
	2>&1 | tee vm.log
