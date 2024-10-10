#!/bin/bash

show_help() {
    echo "Usage: $(basename $0) [OPTIONS]"
    echo "This script sets up a secure SSH environment on a fresh, unconfigured system."
    echo "It generates a random port for SSH access, configures password authentication options,"
    echo "installs UFW and Fail2Ban for enhanced security, and adds the specified public key."
    echo
    echo "Arguments:"
    echo "  PUBLIC_KEY        The client's public key to be added for SSH access"
    echo
    echo "Options:"
    echo "  -h, --help        Display this help message"
    echo
    echo "For support or inquiries, find me via: https://ya.ru/search/?text=atarwn"
}

if ! grep -q -E '^(ID=debian|ID_LIKE=debian)' /etc/os-release; then
    echo "Error: This script is intended to be run on a Debian-based system."
    exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "atarwn's ssh configurator"
    echo
    show_help
    exit 0
fi

clear
echo "atarwn's ssh configurator"
echo
echo "/!\ This script should ONLY be run on a fresh, unconfigured system!"
echo "/!\ If you have changed any settings in ssh, ufw, and/or fail2ban, I do not recommend running this script."
echo "For support or inquiries, find me via: https://ya.ru/search/?text=atarwn"
echo
echo "Tip: run the script with the --help key, for help. 8)"
echo

read -p "Do you really want to continue? (y/n) " answer

if echo "$answer" | grep -iq "^y"; then
    echo
else
    echo ":: Exiting..."
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "You did not specify the client's public key as argument. Please enter it here: "
    read -p "> " PUBLIC_KEY
else
    PUBLIC_KEY=$1
fi

if [ -z "$PUBLIC_KEY" ]; then
    echo "Error: The public key cannot be empty. Exiting..."
    exit 1
fi

NEW_PORT=$(shuf -i 1024-65535 -n 1)

echo ":: New port for SSH: $NEW_PORT"

# Prompt for service installation options
echo
echo "Select which services you want to install/configure:"
echo "1. Install UFW (Firewall)"
echo "2. Install Fail2Ban (Brute-force protection)"
echo "3. Configure SSH (Random port, disable password authentication)"
echo "4. All of the above"
echo
read -p "Enter your choice (1-4): " choice

install_ufw=false
install_fail2ban=false
configure_ssh=false

case $choice in
    1)
        install_ufw=true
        ;;
    2)
        install_fail2ban=true
        ;;
    3)
        configure_ssh=true
        ;;
    4)
        install_ufw=true
        install_fail2ban=true
        configure_ssh=true
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

# SSH Configuration
if [ "$configure_ssh" = true ]; then
    SSH_CONFIG="/etc/ssh/sshd_config"
    echo "# SSH secure access setup script by atarwn" >> $SSH_CONFIG
    echo "# Find me via https://ya.ru/search/?text=atarwn" >> $SSH_CONFIG

    echo "Port $NEW_PORT" >> $SSH_CONFIG

    read -p "Disable password access? (y/n) " disable_password_auth

    if echo "$disable_password_auth" | grep -iq "^y"; then
        echo "PasswordAuthentication no" >> $SSH_CONFIG
    else
        echo ":: Password authentication will remain enabled."
    fi

    sudo systemctl restart sshd
    echo ":: SSH configuration updated and service restarted."
fi

# UFW Installation and Configuration
if [ "$install_ufw" = true ]; then
    sudo apt update && sudo apt install -y ufw
    sudo ufw allow $NEW_PORT/tcp
    sudo ufw enable
    echo ":: UFW firewall installed and configured to allow traffic on port $NEW_PORT."
fi

# Fail2Ban Installation and Configuration
if [ "$install_fail2ban" = true ]; then
    sudo apt update && sudo apt install -y fail2ban
    FAIL2BAN_JAIL="/etc/fail2ban/jail.local"
    if [ ! -f $FAIL2BAN_JAIL ]; then
        sudo touch $FAIL2BAN_JAIL
    fi

    sudo bash -c "cat > $FAIL2BAN_JAIL" <<EOL
[sshd]
enabled  = true
port     = $NEW_PORT
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
bantime  = 3600
EOL

    sudo systemctl restart fail2ban
    echo ":: Fail2Ban installed and configured for SSH protection."
fi

# Adding Public Key
sudo mkdir -p /root/.ssh
echo "$PUBLIC_KEY" | sudo tee -a /root/.ssh/authorized_keys > /dev/null
sudo chmod 600 /root/.ssh/authorized_keys
sudo chmod 700 /root/.ssh

echo ":: The public key has been successfully added to /root/.ssh/authorized_keys."

# Final Summary
echo " - - - - - - - - - - - - - - - "
echo "Done! The script has configured your system to use SSH more securely. Here's what we changed:"
echo "1. Generated a new random port for SSH access: $NEW_PORT"
if [ "$configure_ssh" = true ]; then
    echo "2. Updated the SSH configuration to use the new port."
    if echo "$disable_password_auth" | grep -iq "^y"; then
        echo "3. Disabled password authentication for SSH."
    else
        echo "3. Password authentication remains enabled."
    fi
fi
if [ "$install_ufw" = true ]; then
    echo "4. Installed and configured UFW (Uncomplicated Firewall) to allow traffic on port $NEW_PORT."
fi
if [ "$install_fail2ban" = true ]; then
    echo "5. Installed and configured Fail2Ban to protect against brute-force attacks on SSH."
fi
echo "6. Added the provided public key to /root/.ssh/authorized_keys."
