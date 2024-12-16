#!/bin/bash

# Check if necessary packages are installed
dpkg -l | grep -q libpam-pwquality && echo "libpam-pwquality is installed." || echo "libpam-pwquality is NOT installed."

# Check if root login is disabled via SSH
grep -q "^PermitRootLogin no" /etc/ssh/sshd_config && echo "Root login via SSH is disabled." || echo "Root login via SSH is NOT disabled."

# Check if the USB storage is disabled
lsmod | grep -q usb_storage && echo "USB storage is still enabled." || echo "USB storage is disabled."

# Check if rsync service is disabled
systemctl is-enabled rsync >/dev/null 2>&1 && echo "Rsync service is enabled." || echo "Rsync service is disabled."

# Check if the file systems that are not required are disabled (freevxfs, rds, hfs, etc.)
lsmod | grep -q freevxfs && echo "freevxfs module is still loaded." || echo "freevxfs module is disabled."
lsmod | grep -q rds && echo "rds module is still loaded." || echo "rds module is disabled."
lsmod | grep -q hfs && echo "hfs module is still loaded." || echo "hfs module is disabled."
lsmod | grep -q jffs2 && echo "jffs2 module is still loaded." || echo "jffs2 module is disabled."

# Check if the SSH LoginGraceTime is set to one minute
grep -q "^LoginGraceTime 1m" /etc/ssh/sshd_config && echo "SSH LoginGraceTime is set to 1m." || echo "SSH LoginGraceTime is NOT set to 1m."

# Check if the system accounts are non-login
awk -F: '($3 < 1000 && $7 != "/usr/sbin/nologin" && $7 != "/bin/false") {print $1}' /etc/passwd | while read -r user; do
    echo "System account $user should have a non-login shell."
done

# Check /etc/gshadow and /etc/shadow file permissions
current_permissions=$(stat -c %a /etc/gshadow)
if [ "$current_permissions" -eq 400 ]; then
    echo "Permissions for /etc/gshadow are correct: 400."
else
    echo "Permissions for /etc/gshadow are NOT correct. Expected 400, but got $current_permissions."
fi

current_permissions=$(stat -c %a /etc/shadow)
if [ "$current_permissions" -eq 400 ]; then
    echo "Permissions for /etc/shadow are correct: 400."
else
    echo "Permissions for /etc/shadow are NOT correct. Expected 400, but got $current_permissions."
fi

# Check if /etc/passwd- has correct permissions
current_permissions=$(stat -c %a /etc/passwd-)
if [ "$current_permissions" -eq 600 ]; then
    echo "Permissions for /etc/passwd- are correct: 600."
else
    echo "Permissions for /etc/passwd- are NOT correct. Expected 600, but got $current_permissions."
fi

# Check if password minimum days is set to 7
grep -q "^PASS_MIN_DAYS   7" /etc/login.defs && echo "PASS_MIN_DAYS is set to 7." || echo "PASS_MIN_DAYS is NOT set to 7."

# Check if password creation requirements are configured correctly
grep -q "^minlen = 14" /etc/security/pwquality.conf && echo "Password min length is set to 14." || echo "Password min length is NOT set to 14."
grep -q "^dcredit = -1" /etc/security/pwquality.conf && echo "Password must have at least one digit." || echo "Password must have at least one digit."
grep -q "^ucredit = -1" /etc/security/pwquality.conf && echo "Password must have at least one uppercase letter." || echo "Password must have at least one uppercase letter."
grep -q "^lcredit = -1" /etc/security/pwquality.conf && echo "Password must have at least one lowercase letter." || echo "Password must have at least one lowercase letter."
grep -q "^ocredit = -1" /etc/security/pwquality.conf && echo "Password must have at least one special character." || echo "Password must have at least one special character."

# Check if SSH Idle Timeout Interval is set
grep -q "^ClientAliveInterval 300" /etc/ssh/sshd_config && echo "SSH Idle Timeout Interval is set to 300 seconds." || echo "SSH Idle Timeout Interval is NOT set to 300 seconds."

# Check if core dumps are restricted
grep -q "* hard core 0" /etc/security/limits.conf && echo "Core dumps are restricted." || echo "Core dumps are NOT restricted."

# Check if source routed packets are disabled
current_value=$(sysctl -n net.ipv4.conf.default.accept_source_route)
if [ "$current_value" -eq 0 ]; then
    echo "Source routed packets are disabled on default interface."
else
    echo "Source routed packets are NOT disabled on default interface."
fi

current_value=$(sysctl -n net.ipv4.conf.all.accept_source_route)
if [ "$current_value" -eq 0 ]; then
    echo "Source routed packets are disabled on all interfaces."
else
    echo "Source routed packets are NOT disabled on all interfaces."
fi

# Ensure permissions on cron directories are correct
current_permissions=$(stat -c %a /etc/cron.daily)
if [ "$current_permissions" -eq 700 ]; then
    echo "Permissions for /etc/cron.daily are correct: 700."
else
    echo "Permissions for /etc/cron.daily are NOT correct. Expected 700, but got $current_permissions."
fi

current_permissions=$(stat -c %a /etc/cron.hourly)
if [ "$current_permissions" -eq 700 ]; then
    echo "Permissions for /etc/cron.hourly are correct: 700."
else
    echo "Permissions for /etc/cron.hourly are NOT correct. Expected 700, but got $current_permissions."
fi

current_permissions=$(stat -c %a /etc/cron.monthly)
if [ "$current_permissions" -eq 700 ]; then
    echo "Permissions for /etc/cron.monthly are correct: 700."
else
    echo "Permissions for /etc/cron.monthly are NOT correct. Expected 700, but got $current_permissions."
fi

current_permissions=$(stat -c %a /etc/cron.weekly)
if [ "$current_permissions" -eq 700 ]; then
    echo "Permissions for /etc/cron.weekly are correct: 700."
else
    echo "Permissions for /etc/cron.weekly are NOT correct. Expected 700, but got $current_permissions."
fi

current_permissions=$(stat -c %a /etc/cron.d)
if [ "$current_permissions" -eq 600 ]; then
    echo "Permissions for /etc/cron.d are correct: 600."
else
    echo "Permissions for /etc/cron.d are NOT correct. Expected 600, but got $current_permissions."
fi

# Ensure SSH banner is set
grep -q "Banner /etc/issue.net" /etc/ssh/sshd_config && echo "SSH Banner is correctly configured." || echo "SSH Banner is NOT configured."

# Ensure /etc/grub/grub.cfg file has correct permissions
current_permissions=$(stat -c %a /boot/grub/grub.cfg)
if [ "$current_permissions" -eq 600 ]; then
    echo "Permissions for /boot/grub/grub.cfg are correct: 600."
else
    echo "Permissions for /boot/grub/grub.cfg are NOT correct. Expected 600, but got $current_permissions."
fi

# Restart SSH to apply configurations
echo "Restarting SSH service..."
sudo systemctl restart ssh

echo "Hardening verification completed."
