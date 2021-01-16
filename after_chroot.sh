#!/bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
emerge-webrsync
emerge --sync
eselect profile set 7
emerge -atvuDN @world
echo 'en_US.UTF-8 UTF-8'>> /etc/locale.gen
echo 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
emerge --ask sys-kernel/gentoo-kernel-bin
emerge --ask sys-kernel/linux-firmware
emerge sys-boot/grub:2
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m -G users,wheel,audio -s /bin/bash aki
echo user:pass | /usr/sbin/chpasswd
echo root:pass | /usr/sbin/chpasswd
rm /stage3-*.tar.*
systemctl enable NetworkManager
exit

