#!/bin/bash

# Update and Upgrade System
echo "Updating and upgrading system..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Disable Root Login via SSH
echo "Disabling root login via SSH..."
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd


# Disable Unnecessary Services
echo "Disabling unused services..."
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
sudo systemctl disable rsync



# Enforce Minimum Days Between Password Changes
echo "Setting minimum days between password changes..."
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs

# Set File Permissions for Critical Files
echo "Setting file permissions..."
sudo chmod 600 /etc/ssh/sshd_config
sudo chmod 600 /boot/grub/grub.cfg

# Disable IPv6 (Optional, If Not Needed)
echo "Disabling IPv6..."
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sudo echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

# Disable Support for RDS (Reliable Datagram Sockets)
echo "Disabling RDS kernel module..."
sudo echo "install rds /bin/true" >> /etc/modprobe.d/disable-rds.conf
sudo modprobe -r rds

# Ensure Mounting of USB Storage Devices is Disabled
echo "Disabling USB storage devices..."
sudo echo "install usb-storage /bin/true" >> /etc/modprobe.d/disable-usb-storage.conf
sudo modprobe -r usb-storage

# Disable Installation and Use of Unneeded File Systems (e.g., freevxfs)
echo "Disabling unused file systems..."
sudo echo "install freevxfs /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
sudo modprobe -r freevxfs

# Ensure Packet Redirect Sending is Disabled
echo "Disabling packet redirect sending..."
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
sudo sysctl -w net.ipv4.conf.default.send_redirects=0
sudo echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
sudo echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf

# Ensure SSH Uses Appropriate Ciphers
echo "Configuring SSH to use strong ciphers..."
sudo sed -i 's/^#Ciphers.*/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Enable Bootloader Password Protection
echo "Setting bootloader password protection..."
sudo grub-mkpasswd-pbkdf2 <<EOF > /tmp/grub-pass
password
password
EOF
GRUB_PASS=$(grep -oP '(?<=PBKDF2 hash of your password is ).*' /tmp/grub-pass)
sudo echo "set superusers=\"root\"" >> /etc/grub.d/40_custom
sudo echo "password_pbkdf2 root $GRUB_PASS" >> /etc/grub.d/40_custom
sudo update-grub
rm -f /tmp/grub-pass

# Install and Configure Fail2Ban
echo "Installing and configuring Fail2Ban..."
sudo apt-get install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Enable Automatic Security Updates
echo "Enabling automatic updates..."
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
sudo systemctl enable unattended-upgrades




echo "Hardening complete!"
