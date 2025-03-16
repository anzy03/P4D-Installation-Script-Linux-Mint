# Perforce Helix Core Server Installation Script

This script automates the installation and configuration of a Perforce Helix Core server (P4D) on a fresh Linux Mint installation.

## Prerequisites

* A fresh installation of Linux Mint.
* `sudo` privileges.
* Internet connection.

## Usage

1.  **Download the Script:**
    * Save the script to a file (e.g., `install_perforce.sh`).
2.  **Make the Script Executable:**
    * Open a terminal and run: `chmod +x install_perforce.sh`
3.  **Run the Script with Root Privileges:**
    * Execute the script as root: `sudo ./install_perforce.sh`
4.  **Follow the Prompts:**
    * The script will prompt you for a Perforce username and password.

## Script Details

### Variables

* `P4_VERSION`: The Perforce Helix Core server version to install. **Important:** Always check the official Perforce downloads page for the latest version and update this variable accordingly.
* `P4_PORT`: The port on which the Perforce server will listen (default: 1666).
* `P4_ROOT`: The directory where the Perforce server data will be stored (default: `/opt/perforce`).
* `P4_USER`: The user under which the Perforce server will run (defaults to the current user).
* `P4_PACKAGE`: The name of the Perforce server `.deb` package.
* `IP_ADDRESS`: The IP address of the Linux Mint machine, automatically detected by the script.

### Functions

* `check_root()`: Checks if the script is run with root privileges.
* `download_package()`: Downloads the Perforce server `.deb` package from Perforce's website. **Note:** This function relies on an external link. It is recommended to download the package manually and store it in the same directory as the script. Then modify the download_package function to use the local file.
* `install_perforce()`: Installs the Perforce server using `dpkg` and resolves dependencies.
* `configure_perforce()`:
    * Creates the `P4_ROOT` directory and sets ownership.
    * Sets the `P4ROOT` and `P4PORT` environment variables.
    * Initializes the Perforce server.
    * Prompts for and creates a Perforce user and sets the password.
    * Starts the Perforce server in the background.
    * Configures the `ufw` firewall to allow connections to the Perforce port.
* `create_systemd_service()`: Creates a systemd service file to automatically start the Perforce server on system boot.

### Output

* The script prints a message indicating successful installation and configuration.
* It displays the server address (`IP_ADDRESS:P4_PORT`).

## Important Notes

* **Perforce Version:** Always verify the latest Perforce version on the official Perforce downloads page and update the `P4_VERSION` variable.
* **Firewall:** The script configures `ufw`. If you use a different firewall, you'll need to modify the script accordingly.
* **Security:** For production environments, implement proper security measures, including strong passwords, SSH key authentication, and firewall rules.
* **Backups:** Regularly back up the `P4_ROOT` directory to prevent data loss.
* **Network:** Ensure your network is properly configured and that the Perforce port is accessible.
* **Download Link:** The download URL in this script is subject to change. For the most reliable approach, manually download the .deb package from the perforce website and then place it in the same folder as this script. Then modify the download_package function to use the local file.
* **Topology Warning:** If you see a topology warning after the server starts, you may need to set the ServerID. Please see the troubleshooting sections of the Perforce documentation.
* **SSH Tunneling:** For remote access, consider using SSH tunneling. This is more secure than port forwarding.
* **Tailscale/ZeroTier:** For simpler and secure remote access, consider using Tailscale or ZeroTier. These services create a virtual LAN and eliminate the need for port forwarding.

## Troubleshooting

* **Download Errors:** If the download fails, verify your internet connection and the download URL.
* **Installation Errors:** If the installation fails, check the error messages and ensure that all dependencies are met.
* **Connection Errors:** If you cannot connect to the Perforce server, verify the server address, port, and firewall settings.
* **Topology Warning:** If you receive a topology warning, follow the instructions in the perforce documentation to set the server ID.
