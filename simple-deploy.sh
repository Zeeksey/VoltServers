#!/bin/bash

# Simple deployment script for VoltServers
# This creates all necessary files for manual deployment

set -e

echo "🚀 Creating VoltServers deployment package..."

# Create deployment directory
mkdir -p deployment

# Create the server setup script
cat > deployment/server-setup.sh << 'EOF'
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
EOF

# Create the application setup script
cat > deployment/app-setup.sh << 'EOF'
#!/bin/bash

# VoltServers Application Setup Script
# Run this as the ubuntu user after uploading files

set -e

APP_DIR="/home/ubuntu/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"
DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "🚀 Setting up VoltServers application..."

cd $APP_DIR

# Create production environment file
echo "⚙️  Creating environment configuration..."
cat > .env << EOL
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
PORT=5000
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key_here
EOL

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Build application
echo "🔧 Building application..."
npm run build

# Setup database schema
echo "🗄️  Setting up database schema..."
npm run db:push

# Start with PM2
echo "🚀 Starting application with PM2..."
pm2 delete voltservers 2>/dev/null || true
pm2 start npm --name "voltservers" -- start
pm2 save
pm2 startup | tail -1 | sudo bash

echo "✅ Application setup completed!"
echo "🌐 Application running on port 5000"
EOF

# Create Nginx configuration
cat > deployment/nginx-setup.sh << 'EOF'
#!/bin/bash

# Nginx configuration for VoltServers
set -e

echo "🌐 Configuring Nginx for VoltServers..."

# Create Nginx site configuration
cat > /etc/nginx/sites-available/voltservers << 'EOL'
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

echo "✅ Nginx configuration completed!"
echo "🌐 VoltServers will be available at: http://your-server-ip"
EOF

# Create deployment archive
echo "📦 Creating deployment archive..."
tar -czf deployment/voltservers-app.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='dist' \
  --exclude='*.log' \
  --exclude='.env' \
  --exclude='deployment' \
  --exclude='*.tar.gz' \
  .

# Make scripts executable
chmod +x deployment/*.sh

echo "✅ Deployment package created in ./deployment/ directory"
echo ""
echo "📋 Manual deployment steps for server 135.148.137.158:"
echo ""
echo "1. Upload files to server:"
echo "   scp -r deployment/ root@135.148.137.158:/tmp/"
echo ""
echo "2. Run server setup (as root):"
echo "   ssh root@135.148.137.158 'bash /tmp/deployment/server-setup.sh'"
echo ""
echo "3. Upload application files:"
echo "   ssh root@135.148.137.158 'cd /home/ubuntu/voltservers && tar -xzf /tmp/deployment/voltservers-app.tar.gz'"
echo ""
echo "4. Setup application (as ubuntu user):"
echo "   ssh root@135.148.137.158 'sudo -u ubuntu bash /tmp/deployment/app-setup.sh'"
echo ""
echo "5. Configure Nginx (as root):"
echo "   ssh root@135.148.137.158 'bash /tmp/deployment/nginx-setup.sh'"
echo ""
echo "🌐 After completion, VoltServers will be available at: http://135.148.137.158"