#!/bin/bash

# VoltServers Ubuntu Direct Setup Script
# Run this directly on your Ubuntu server to deploy VoltServers

set -e

GITHUB_REPO="https://github.com/Zeeksey/voltservers2.git"
APP_DIR="/home/ubuntu/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"
DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "🚀 Setting up VoltServers on Ubuntu server..."
echo "Repository: $GITHUB_REPO"
echo "Installation directory: $APP_DIR"

# Update system packages
echo "📦 Updating system packages..."
sudo apt update -qq
sudo apt upgrade -y -qq

# Install required packages
echo "📦 Installing dependencies..."
sudo apt install -y curl wget git ufw build-essential postgresql postgresql-contrib nginx

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp >/dev/null 2>&1
sudo ufw allow 80/tcp >/dev/null 2>&1
sudo ufw allow 443/tcp >/dev/null 2>&1
sudo ufw allow 8080/tcp >/dev/null 2>&1
sudo ufw --force enable >/dev/null 2>&1

# Install Node.js 20.x
echo "🟢 Installing Node.js 20.x..."
sudo apt remove -y nodejs npm >/dev/null 2>&1 || true
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >/dev/null 2>&1
sudo apt install -y nodejs >/dev/null 2>&1

# Verify Node.js installation
echo "✅ Node.js version: $(node --version)"
echo "✅ NPM version: $(npm --version)"

# Install PM2 globally
echo "⚡ Installing PM2..."
sudo npm install -g pm2 >/dev/null 2>&1

# Setup PostgreSQL
echo "🗄️  Setting up PostgreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database user and database
echo "🗄️  Creating database and user..."
sudo -u postgres psql << 'EOSQL'
DROP DATABASE IF EXISTS voltservers;
DROP USER IF EXISTS voltservers;
CREATE USER voltservers WITH PASSWORD 'VoltPass2025!!';
CREATE DATABASE voltservers OWNER voltservers;
GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;
\q
EOSQL

# Clone application from GitHub
echo "📂 Cloning VoltServers from GitHub..."
if [ -d "$APP_DIR" ]; then
    echo "Removing existing directory..."
    rm -rf $APP_DIR
fi

git clone $GITHUB_REPO $APP_DIR
cd $APP_DIR

# Create production environment file
echo "⚙️  Creating production environment..."
cat > .env << EOL
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
PORT=5000
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key_here
EOL

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Build application
echo "🔧 Building application..."
npm run build

# Setup database schema
echo "🗄️  Setting up database schema..."
npm run db:push

# Configure Nginx
echo "🌐 Configuring Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/voltservers > /dev/null << 'EOL'
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
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
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
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
    }
    
    # API rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static assets with caching
    location /assets {
        proxy_pass http://localhost:5000;
        proxy_cache_valid 200 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOL

# Enable site and restart nginx
sudo ln -sf /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Handle existing Apache if present
if sudo systemctl is-active --quiet apache2; then
    echo "🔧 Moving Apache to port 8080..."
    sudo sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
    sudo sed -i 's/:80>/:8080>/g' /etc/apache2/sites-available/000-default.conf
    sudo systemctl restart apache2
fi

# Start application with PM2
echo "🚀 Starting VoltServers with PM2..."
pm2 delete voltservers 2>/dev/null || true
pm2 start npm --name "voltservers" -- start
pm2 save
pm2 startup | tail -1 | sudo bash

# Create management scripts
echo "📝 Creating management scripts..."

# Status check script
cat > check-status.sh << 'EOF'
#!/bin/bash
echo "=== VoltServers Status Check ==="
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"
echo ""
echo "=== PM2 Status ==="
pm2 status
echo ""
echo "=== Services Status ==="
sudo systemctl status nginx --no-pager -l
sudo systemctl status postgresql --no-pager -l
echo ""
echo "=== Database Connection ==="
psql $DATABASE_URL -c "SELECT version();" 2>/dev/null && echo "✅ Database connected" || echo "❌ Database connection failed"
echo ""
echo "=== Application Logs (last 10 lines) ==="
pm2 logs voltservers --lines 10
EOF

# Restart script
cat > restart-app.sh << 'EOF'
#!/bin/bash
echo "🔄 Restarting VoltServers..."
pm2 restart voltservers
echo "✅ Application restarted"
pm2 status
EOF

chmod +x check-status.sh restart-app.sh

echo ""
echo "🎉 VOLTSERVERS DEPLOYMENT COMPLETED!"
echo "================================================"
echo "🌐 VoltServers is now live at: http://$(curl -s ifconfig.me)"
echo "🌐 Local access: http://localhost"
echo "📊 Admin panel: http://$(curl -s ifconfig.me)/admin"
echo ""
echo "🔧 Management Commands:"
echo "  ./check-status.sh     - Check all services status"
echo "  ./restart-app.sh      - Restart the application"
echo "  pm2 logs voltservers  - View application logs"
echo "  pm2 status           - Check PM2 processes"
echo ""
echo "📁 Application directory: $APP_DIR"
echo "🗄️  Database: voltservers (user: voltservers)"
echo ""
echo "✅ Your game server hosting platform is ready!"