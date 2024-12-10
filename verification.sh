#!/bin/bash

# Check if SSH root login is disabled
grep "PermitRootLogin no" /etc/ssh/sshd_config && echo "Root login via SSH is disabled." || echo "Root login via SSH is NOT disabled."

# Check if password authentication is disabled
grep "PasswordAuthentication no" /etc/ssh/sshd_config && echo "Password authentication is disabled." || echo "Password authentication is NOT disabled."

# Check if unnecessary services are disabled
for service in cups avahi-daemon rsync; do
    systemctl is-enabled $service && echo "$service is disabled." || echo "$service is NOT disabled."
done

# Check if IPv6 is disabled
sysctl net.ipv6.conf.all.disable_ipv6 | grep "1" && echo "IPv6 is disabled." || echo "IPv6 is NOT disabled."

# Check if USB storage is disabled
grep "install usb-storage /bin/true" /etc/modprobe.d/disable-usb-storage.conf && echo "USB storage is disabled." || echo "USB storage is NOT disabled."

# Check if packet redirect sending is disabled
sysctl net.ipv4.conf.all.send_redirects | grep "0" && echo "Packet redirect sending is disabled." || echo "Packet redirect sending is NOT disabled."

# Check if bootloader password protection is enabled
grep "password_pbkdf2" /etc/grub.d/40_custom && echo "Bootloader password protection is enabled." || echo "Bootloader password protection is NOT enabled."

# Check if SSH strong ciphers are configured
grep "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" /etc/ssh/sshd_config && echo "SSH is using strong ciphers." || echo "SSH is NOT using strong ciphers."
