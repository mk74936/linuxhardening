#!/bin/bash

# Update and Upgrade System
echo "Updating and upgrading system..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Disable Root Login via SSH
echo "Disabling root login via SSH..."
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Configure Firewall (UFW)
echo "Configuring UFW..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Disable Unnecessary Services
echo "Disabling unused services..."
sudo systemctl disable cups
sudo systemctl disable avahi-daemon

# Enforce Password Complexity
echo "Enforcing password complexity..."
sudo apt-get install -y libpam-pwquality
sudo sed -i 's/^# minlen = .*/minlen = 14/' /etc/security/pwquality.conf
sudo sed -i 's/^# retry = .*/retry = 3/' /etc/security/pwquality.conf

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

# Disable Core Dumps
echo "Disabling core dumps..."
sudo echo "* hard core 0" >> /etc/security/limits.conf

# Remove Unused Packages
echo "Removing unused packages..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# Verify and Lock Critical Services
echo "Locking critical services..."
sudo systemctl mask ctrl-alt-del.target
sudo systemctl mask rescue.target
sudo systemctl mask emergency.target

echo "Hardening complete!"
