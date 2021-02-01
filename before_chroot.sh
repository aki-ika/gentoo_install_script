#!/bin/bash
set -e
mkdir -p /mnt/gentoo
mkfs.ext4 /dev/nvme0n1p3
mkfs.vfat /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mount /dev/nvme0n1p3 /mnt/gentoo
cd /mnt/gentoo
wget http://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt
wget http://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/$(cat latest-stage3-amd64-systemd.txt |grep tar | awk '{print $1}')
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
mount /dev/nvme0n1p1 /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/home
sed s/"-O2 -pipe"/"-march=native -O2 -pipe"/ /mnt/gentoo/etc/portage/make.conf
echo 'L10N = "ja en"' >> /mnt/gentoo/etc/portage/make.conf
echo 'GRUB_PLATFORMS="efi-64"' >> /mnt/gentoo/etc/portage/make.conf
echo 'ACCEPT_LICENSE="*"' >> /mnt/gentoo/etc/portage/make.conf
echo 'GENTOO_MIRRORS="http://ftp.jaist.ac.jp/pub/Linux/Gentoo/"' >> /mnt/gentoo/etc/portage/make.conf
echo 'USE="-consolekit -games bluetooth cjk fontconfig networkmanager systemd xft"' >> /mnt/gentoo/etc/portage/make.conf
echo 'VIDEO_CARDS="nvidia"' >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm/
fstabgen -U /mnt/gentoo > /mnt/gentoo/etc/fstab
nano -w /mnt/gentoo/etc/fstab
chroot /mnt/gentoo after_chroot.sh
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
swapoff /dev/nvme0n1p2
reboot
