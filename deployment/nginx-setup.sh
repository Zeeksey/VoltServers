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
