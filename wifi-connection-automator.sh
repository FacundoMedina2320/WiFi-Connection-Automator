#!/bin/bash

# ================================================================
# WiFi Connection Setup Script
# ================================================================
# This script automates the process of connecting to a WiFi network.
# It handles both predefined and user-selected networks, installs 
# necessary software, and ensures network configurations are secure.
#
# Author: Facundo Medina
# Date: 05/12/2024
# ================================================================

# ================================================================
# Check if the script is being run as root
# ================================================================
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31m[ERROR]\033[0m Please run this script as root or with sudo."
    exit 1
fi

# ================================================================
# Configuration Variables
# ================================================================
PREDEFINED_SSID="YourSSID"         # Replace with the predefined SSID
PREDEFINED_PASSWORD="YourPassword" # Replace with the predefined password
CONNECTION_NAME="WiFi_WPA3"        # Connection name to manage configurations

# ================================================================
# Log file for monitoring
# ================================================================
LOG_FILE="/var/log/wifi_connection.log"
echo -e "\n\033[1;36mStarting WiFi connection setup...\033[0m" | tee -a $LOG_FILE

# ================================================================
# Check if NetworkManager is installed
# ================================================================
if ! command -v nmcli &> /dev/null; then
    echo -e "\033[1;33m[INFO]\033[0m NetworkManager is not installed. Installing..." | tee -a $LOG_FILE
    apt update && apt install -y network-manager
fi

# ================================================================
# Ensure NetworkManager is active
# ================================================================
echo -e "\033[1;32m[INFO]\033[0m Ensuring NetworkManager is active..." | tee -a $LOG_FILE
systemctl enable --now NetworkManager

# ================================================================
# Delete previous configurations with the same name
# ================================================================
echo -e "\033[1;32m[INFO]\033[0m Deleting previous configurations..." | tee -a $LOG_FILE
nmcli connection delete "$CONNECTION_NAME" 2>/dev/null

# ================================================================
# Attempt to connect automatically to the predefined network
# ================================================================
echo -e "\n\033[1;34mAttempting to connect to the predefined network ($PREDEFINED_SSID)...\033[0m" | tee -a $LOG_FILE
nmcli dev wifi connect "$PREDEFINED_SSID" password "$PREDEFINED_PASSWORD" >/dev/null 2>&1

# Check if connection was successful
if [ $? -eq 0 ]; then
    echo -e "\033[1;32m[SUCCESS]\033[0m Successfully connected to $PREDEFINED_SSID!" | tee -a $LOG_FILE
else
    echo -e "\033[1;31m[ERROR]\033[0m Could not connect to the predefined network ($PREDEFINED_SSID)." | tee -a $LOG_FILE
    echo -e "\033[1;34m[INFO]\033[0m Scanning available networks..." | tee -a $LOG_FILE

    # List available networks and assign numbers
    NETWORKS=$(nmcli dev wifi list | awk 'NR>1 {print NR-1, $2}')
    echo "$NETWORKS" | tee -a $LOG_FILE

    # Ask the user to select a network by number
    echo -e "\n\033[1;33mPlease enter the number of the network you want to connect to:\033[0m" | tee -a $LOG_FILE
    read SELECTED_NETWORK

    # Extract the SSID corresponding to the selected number
    SELECTED_SSID=$(echo "$NETWORKS" | sed -n "${SELECTED_NETWORK}p" | awk '{print $2}')

    # Validate network selection
    if [ -z "$SELECTED_SSID" ]; then
        echo -e "\033[1;31m[ERROR]\033[0m Invalid selection. Exiting." | tee -a $LOG_FILE
        exit 1
    fi

    # Ask user for the password
    echo -e "\033[1;33mEnter the password for the network:\033[0m" | tee -a $LOG_FILE
    read -s SELECTED_PASSWORD

    # Attempt to connect to the selected network
    echo -e "\n\033[1;34mAttempting to connect to $SELECTED_SSID...\033[0m" | tee -a $LOG_FILE
    nmcli dev wifi connect "$SELECTED_SSID" password "$SELECTED_PASSWORD"

    # Check connection status
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m[SUCCESS]\033[0m Successfully connected to $SELECTED_SSID!" | tee -a $LOG_FILE
        # Set the network to auto-connect
        nmcli connection modify "$SELECTED_SSID" connection.autoconnect yes
    else
        echo -e "\033[1;31m[ERROR]\033[0m Could not connect to $SELECTED_SSID. Please check the credentials." | tee -a $LOG_FILE
        exit 1
    fi
fi

# ================================================================
# Additional configuration for the predefined network
# ================================================================
if nmcli connection show "$CONNECTION_NAME" >/dev/null 2>&1; then
    nmcli connection modify "$CONNECTION_NAME" connection.autoconnect yes
fi

# ================================================================
# Clear command history for security
# ================================================================
history -c
echo -e "\n\033[1;33m[INFO]\033[0m Command history has been cleared." | tee -a $LOG_FILE

# ================================================================
# Remove the script to ensure no trace of configuration remains
# ================================================================
echo -e "\033[1;31m[SECURITY]\033[0m Removing the script to ensure no traces of the configuration..." | tee -a $LOG_FILE
rm -- "$0"

# ================================================================
# Secure the password by using secret-tool to store it in the keyring
# ================================================================
echo "$PREDEFINED_PASSWORD" | secret-tool store --label="WiFi Password" ssid "$PREDEFINED_SSID"

# ================================================================
# Final message
# ================================================================
echo -e "\n\033[1;32m[INFO]\033[0m Configuration complete. The system is ready!" | tee -a $LOG_FILE

# ================================================================
# End of Script
# ================================================================
