#!/bin/bash

# Script to install and configure Perforce Helix Core Server on a fresh Linux Mint installation

# Variables
P4_VERSION="2024.1" # Using the latest version as of this response. Double check Perforce's website for the absolute newest.
P4_PORT="1666"
P4_ROOT="/opt/perforce"
P4_USER="$USER" # Uses the currently logged-in user
P4_PACKAGE="perforce-${P4_VERSION}-x86_64-linux26-glibc2.12.deb"
IP_ADDRESS=$(ip a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d'/' -f1)

# Function to check for root privileges
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use 'sudo ./$0'"
    exit 1
  fi
}

# Function to download the Perforce package
download_package() {
  if [ ! -f "$P4_PACKAGE" ]; then
    echo "Downloading Perforce package..."
    wget "https://cdist1.perforce.com/perforce/${P4_VERSION}/bin.linux26x86_64/${P4_PACKAGE}" || {
      echo "Failed to download Perforce package."
      exit 1
    }
  else
    echo "Perforce package already downloaded."
  fi
}

# Function to install the Perforce package
install_perforce() {
  echo "Installing Perforce..."
  dpkg -i "$P4_PACKAGE" || {
    echo "Failed to install Perforce package."
    apt-get update
    apt-get install -y -f
    dpkg -i "$P4_PACKAGE" || {
      echo "Failed to install Perforce package after dependency fix."
      exit 1
    }
  }
}

# Function to configure Perforce
configure_perforce() {
  echo "Configuring Perforce..."
  mkdir -p "$P4_ROOT"
  chown "$P4_USER":"$P4_USER" "$P4_ROOT"

  echo "export P4ROOT=$P4_ROOT" >> ~/.bashrc
  echo "export P4PORT=$IP_ADDRESS:$P4_PORT" >> ~/.bashrc
  source ~/.bashrc

  p4d -r "$P4_ROOT" -p "$P4_PORT" -i

  read -p "Enter Perforce username: " P4_USERNAME
  p4 user "$P4_USERNAME"
  p4 passwd "$P4_USERNAME"

  # Check if ufw is installed and install if not, then enable the port.
  if command -v ufw &> /dev/null; then
      echo "ufw is installed, opening port $P4_PORT..."
      ufw allow "$P4_PORT"
      ufw enable
  else
      echo "ufw is not installed, installing and enabling..."
      apt-get update
      apt-get install -y ufw
      ufw allow "$P4_PORT"
      ufw enable
  fi
}

# Function to create systemd service
create_systemd_service() {
  echo "Creating systemd service..."
  cat <<EOF | sudo tee /etc/systemd/system/perforce.service
[Unit]
Description=Perforce Helix Core Server
After=network.target

[Service]
User=$P4_USER
Group=$P4_USER
Type=forking
ExecStart=/usr/bin/p4d -r $P4_ROOT -p $P4_PORT -d
ExecStop=/usr/bin/p4 admin stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable perforce.service
  systemctl start perforce.service
}

# Main script execution
check_root
download_package
install_perforce
configure_perforce
create_systemd_service

echo "Perforce Helix Core Server setup complete!"
echo "Server address: $IP_ADDRESS:$P4_PORT"