#!/bin/bash

# One-command deployment script that creates and runs everything
# Usage: ./one-command-deploy.sh

set -e

echo "🚀 VoltServers One-Command GitHub Deployment"
echo "=============================================="

# Create the deployment script directly on the server
ssh root@135.148.137.158 << 'ENDSSH'
#!/bin/bash

set -e

GITHUB_REPO="https://github.com/Zeeksey/voltservers2.git"
APP_USER="ubuntu"
APP_DIR="/home/$APP_USER/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"
DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "🚀 Starting VoltServers deployment from GitHub..."

# Update system and install dependencies
echo "📦 Installing system dependencies..."
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

# Clone from GitHub
echo "📂 Cloning VoltServers from GitHub..."
rm -rf $APP_DIR
sudo -u $APP_USER git clone $GITHUB_REPO $APP_DIR
chown -R $APP_USER:$APP_USER $APP_DIR

cd $APP_DIR

# Create production environment file
echo "⚙️  Creating environment configuration..."
sudo -u $APP_USER tee .env > /dev/null << EOL
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
PORT=5000
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key_here
EOL

# Install dependencies and build
echo "📦 Installing dependencies..."
sudo -u $APP_USER npm install

echo "🔧 Building application..."
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

# Migrate Apache to port 8080 if running
if systemctl is-active --quiet apache2; then
    echo "🔧 Moving Apache to port 8080..."
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
    sed -i 's/:80>/:8080>/g' /etc/apache2/sites-available/000-default.conf
    systemctl restart apache2
fi

# Start application with PM2
echo "🚀 Starting application with PM2..."
cd $APP_DIR
sudo -u $APP_USER pm2 delete voltservers 2>/dev/null || true
sudo -u $APP_USER pm2 start npm --name "voltservers" -- start
sudo -u $APP_USER pm2 save
sudo -u $APP_USER pm2 startup | tail -1 | bash

echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "=============================================="
echo "🌐 VoltServers is now live at: http://135.148.137.158"
echo "📊 Admin panel: http://135.148.137.158/admin"
echo ""
echo "🔧 Management Commands:"
echo "  sudo -u ubuntu pm2 status"
echo "  sudo -u ubuntu pm2 logs voltservers"
echo "  sudo -u ubuntu pm2 restart voltservers"
echo ""
echo "✅ Your game server hosting platform is ready!"

ENDSSH

echo ""
echo "🎉 Deployment completed! VoltServers should now be live at:"
echo "🌐 http://135.148.137.158"