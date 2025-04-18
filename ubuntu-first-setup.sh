#!/bin/bash

#chmod +x ubuntu-first-setup.sh
#sudo ./ubuntu-first-setup.sh

# Ubuntu Initial Server Setup Script
# Run as root or with sudo: sudo bash ubuntu-first-setup.sh

set -e  # Exit on error

# 1. Update and Upgrade System
echo "🛠️ Updating and upgrading system..."
apt update && apt upgrade -y

# 2. Set Timezone
echo "🌍 Setting timezone to UTC..."
timedatectl set-timezone UTC

# 3. Create a New Sudo User
read -p "👤 Enter new sudo username: " NEW_USER
adduser $NEW_USER
usermod -aG sudo $NEW_USER

# 4. Setup SSH Key Authentication
echo "🔐 Setting up SSH key authentication..."
mkdir -p /home/$NEW_USER/.ssh
read -p "📥 Paste your public SSH key: " PUB_KEY
echo "$PUB_KEY" > /home/$NEW_USER/.ssh/authorized_keys
chmod 600 /home/$NEW_USER/.ssh/authorized_keys
chmod 700 /home/$NEW_USER/.ssh
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh

# 5. Disable Root SSH Login and Password Auth
echo "🚫 Disabling root login and password SSH..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl reload sshd

# 6. Setup UFW Firewall
echo "🔥 Setting up UFW firewall..."
ufw allow OpenSSH
ufw --force enable

# 7. Install Fail2Ban
echo "🛡️ Installing Fail2Ban..."
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# 8. Setup Automatic Security Updates
echo "🔄 Setting up unattended upgrades..."
apt install -y unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades

# 9. Reboot Prompt
echo "✅ All done. It's recommended to reboot the server now."
read -p "Reboot now? (y/n): " REBOOT_ANSWER
if [[ "$REBOOT_ANSWER" =~ ^[Yy]$ ]]; then
    reboot
fi

