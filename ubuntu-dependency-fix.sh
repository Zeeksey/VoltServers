#!/bin/bash

# Ubuntu dependency fix script for common OVH server issues
# Run this if you encounter any dependency conflicts

echo "🔧 Fixing Ubuntu dependencies for VoltServers..."

# Fix broken packages
echo "📦 Fixing broken packages..."
sudo apt --fix-broken install -y

# Clean package cache
echo "🧹 Cleaning package cache..."
sudo apt clean
sudo apt autoclean
sudo apt autoremove -y

# Update package lists
echo "📋 Updating package lists..."
sudo apt update

# Install essential build tools
echo "🔨 Installing build essentials..."
sudo apt install -y build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Fix potential Node.js conflicts
echo "🟢 Removing conflicting Node.js packages..."
sudo apt remove -y nodejs npm >/dev/null 2>&1 || true
sudo apt purge -y nodejs npm >/dev/null 2>&1 || true
sudo rm -rf /usr/local/bin/npm /usr/local/share/man/man1/node* /usr/local/lib/dtrace/node.d ~/.npm ~/.node-gyp /opt/local/bin/node /opt/local/include/node /opt/local/lib/node_modules

# Clean npm cache if exists
if command -v npm &> /dev/null; then
    sudo npm cache clean --force >/dev/null 2>&1 || true
fi

echo "✅ Dependencies fixed! You can now run ubuntu-setup.sh"