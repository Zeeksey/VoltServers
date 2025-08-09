#!/bin/bash

# Quick start script for Ubuntu VoltServers deployment
# This script can be run with: curl -sSL https://raw.githubusercontent.com/Zeeksey/voltservers2/main/quick-start.sh | bash

echo "🚀 VoltServers Quick Deployment"
echo "==============================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Please don't run this script as root. Run as ubuntu user:"
    echo "   sudo su - ubuntu"
    echo "   ./ubuntu-setup.sh"
    exit 1
fi

# Check Ubuntu version
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "❌ This script is designed for Ubuntu. Detected: $(cat /etc/os-release | grep PRETTY_NAME)"
    exit 1
fi

echo "✅ Running on Ubuntu as user: $(whoami)"
echo "✅ Server IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Unable to detect')"

# Download and run the setup script
if [ -f "ubuntu-setup.sh" ]; then
    echo "📋 Found ubuntu-setup.sh, running deployment..."
    chmod +x ubuntu-setup.sh
    ./ubuntu-setup.sh
else
    echo "📥 Downloading ubuntu-setup.sh..."
    curl -sSL -o ubuntu-setup.sh https://raw.githubusercontent.com/Zeeksey/voltservers2/main/ubuntu-setup.sh
    chmod +x ubuntu-setup.sh
    echo "🚀 Starting deployment..."
    ./ubuntu-setup.sh
fi