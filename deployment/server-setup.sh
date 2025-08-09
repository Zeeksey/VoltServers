#!/bin/bash

# VoltServers Ubuntu Server Setup Script
set -e

echo "🚀 Setting up VoltServers on Ubuntu..."

# Variables
APP_USER="ubuntu"
APP_DIR="/home/$APP_USER/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"
DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

# Update system
echo "📦 Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt upgrade -y -qq
apt install -y curl wget git ufw build-essential postgresql postgresql-contrib nginx

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow 22/tcp >/dev/null 2>&1
ufw allow 80/tcp >/dev/null 2>&1  
ufw allow 443/tcp >/dev/null 2>&1
ufw allow 8080/tcp >/dev/null 2>&1
ufw --force enable >/dev/null 2>&1

# Install Node.js 20.x
echo "🟢 Installing Node.js 20.x..."
apt remove -y nodejs npm >/dev/null 2>&1 || true
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null 2>&1
apt install -y nodejs >/dev/null 2>&1

# Install PM2
echo "⚡ Installing PM2..."
npm install -g pm2 >/dev/null 2>&1

# Setup PostgreSQL
echo "🗄️  Setting up PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql

# Create database user and database
sudo -u postgres psql << 'EOSQL'
DROP DATABASE IF EXISTS voltservers;
DROP USER IF EXISTS voltservers;
CREATE USER voltservers WITH PASSWORD 'VoltPass2025!!';
CREATE DATABASE voltservers OWNER voltservers;
GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;
EOSQL

# Create app user if doesn't exist
id -u $APP_USER &>/dev/null || useradd -m -s /bin/bash $APP_USER

# Create app directory
mkdir -p $APP_DIR
chown -R $APP_USER:$APP_USER $APP_DIR

echo "✅ Server setup completed!"
echo "📁 Application directory ready at: $APP_DIR"
echo "🗄️  Database 'voltservers' created with user 'voltservers'"
echo ""
echo "📝 Next steps:"
echo "1. Upload your application files to $APP_DIR"
echo "2. Run the app-setup.sh script as the ubuntu user"
