# WiFi Connection Automator

## Overview

The **WiFi Connection Automator** is a Bash script that simplifies and automates the process of connecting to WiFi networks. The script can connect to a predefined WiFi network automatically, or allow the user to select from a list of available networks. It ensures security by clearing command history, removing traces of the script, and securely storing WiFi credentials in the system keyring.

### Features:
- **Predefined Network**: Connect to a predefined WiFi network automatically.
- **Network Selection**: Scan and select available networks from a list.
- **Secure Storage**: Store WiFi credentials securely in the keyring.
- **History Management**: Clear shell history after execution for privacy.
- **Cleanup**: Automatically deletes the script after execution to leave no trace.
  
### Prerequisites:
- **Root Privileges**: The script needs to be run with root privileges.
- **NetworkManager**: Ensure that NetworkManager is installed on your system.

### Installation:

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/wifi-connection-automator.git
   cd wifi-connection-automator
   
2. Make the script executable:
    ```bash
    chmod +x wifi-connection-automator.sh
  
3. Run the script as root:
    ```bash
   sudo ./wifi-connection-automator.sh
