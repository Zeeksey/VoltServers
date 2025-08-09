#!/bin/bash

# VoltServers Production Deployment Script
# Deploys the working application to Ubuntu server at 135.148.137.158

set -e

SERVER_IP="135.148.137.158"
SERVER_USER="root"
APP_USER="ubuntu" 
APP_DIR="/home/$APP_USER/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"

echo "🚀 Deploying VoltServers to production server..."

# Step 1: Create the deployment archive with working code
echo "📦 Creating deployment package..."
tar -czf voltservers-deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='dist' \
  --exclude='*.log' \
  --exclude='.env' \
  --exclude='voltservers-deploy.tar.gz' \
  .

echo "📤 Uploading files to server..."
scp -o StrictHostKeyChecking=no voltservers-deploy.tar.gz $SERVER_USER@$SERVER_IP:/tmp/

echo "🔧 Setting up application on server..."
ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << 'ENDSSH'
set -e

# Variables
APP_USER="ubuntu"
APP_DIR="/home/$APP_USER/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"
DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "🔄 Updating system..."
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
echo "📦 Installing Node.js..."
apt remove -y nodejs npm >/dev/null 2>&1 || true
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null 2>&1
apt install -y nodejs >/dev/null 2>&1

# Install PM2
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

# Create app user and directory
echo "👤 Setting up application user..."
id -u $APP_USER &>/dev/null || useradd -m -s /bin/bash $APP_USER
mkdir -p $APP_DIR
chown -R $APP_USER:$APP_USER $APP_DIR

# Extract application files
echo "📁 Extracting application files..."
cd $APP_DIR
sudo -u $APP_USER tar -xzf /tmp/voltservers-deploy.tar.gz
chown -R $APP_USER:$APP_USER $APP_DIR

# Create production environment file
echo "⚙️  Creating environment configuration..."
sudo -u $APP_USER tee $APP_DIR/.env > /dev/null << EOL
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
PORT=5000
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key_here
EOL

# Install dependencies and build
echo "📦 Installing dependencies..."
cd $APP_DIR
sudo -u $APP_USER npm install --production
sudo -u $APP_USER npm run build

# Setup database schema
echo "🗄️  Setting up database schema..."
sudo -u $APP_USER npm run db:push

# Configure Nginx
echo "🌐 Configuring Nginx..."
tee /etc/nginx/sites-available/voltservers > /dev/null << 'EOL'
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy strict-origin-when-cross-origin;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # Handle static assets
    location /assets {
        proxy_pass http://localhost:5000;
        proxy_cache_valid 200 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOL

# Enable site and restart nginx
ln -sf /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
systemctl enable nginx

# Setup PM2 process
echo "🚀 Starting application with PM2..."
cd $APP_DIR
sudo -u $APP_USER pm2 delete voltservers 2>/dev/null || true
sudo -u $APP_USER pm2 start npm --name "voltservers" -- start
sudo -u $APP_USER pm2 save
sudo -u $APP_USER pm2 startup | tail -1 | bash

# Migrate Apache to port 8080 if running
if systemctl is-active --quiet apache2; then
    echo "🔧 Moving Apache to port 8080..."
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
    sed -i 's/:80>/:8080>/g' /etc/apache2/sites-available/000-default.conf
    systemctl restart apache2
fi

echo "✅ Deployment completed successfully!"
echo "🌐 VoltServers is now available at: http://$SERVER_IP"
echo "📊 Admin panel: http://$SERVER_IP/admin"
echo "📈 PM2 status: sudo -u $APP_USER pm2 status"

ENDSSH

# Cleanup
rm voltservers-deploy.tar.gz

echo "🎉 Production deployment completed!"
echo "🌐 Your application is now live at: http://$SERVER_IP"
echo ""
echo "🔍 To check status:"
echo "  ssh root@$SERVER_IP 'sudo -u ubuntu pm2 status'"
echo ""
echo "🔧 To view logs:"
echo "  ssh root@$SERVER_IP 'sudo -u ubuntu pm2 logs voltservers'"