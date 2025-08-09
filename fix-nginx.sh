#!/bin/bash

# Fix Nginx configuration for VoltServers
echo "🔧 Fixing Nginx configuration..."

# Remove the problematic site if it exists
sudo rm -f /etc/nginx/sites-enabled/voltservers
sudo rm -f /etc/nginx/sites-available/voltservers

# Add rate limiting to nginx.conf if not already present
if ! grep -q "limit_req_zone" /etc/nginx/nginx.conf; then
    echo "📝 Adding rate limiting to nginx.conf..."
    sudo sed -i '/http {/a\\n    # Rate limiting for VoltServers\n    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;\n' /etc/nginx/nginx.conf
fi

# Create corrected site configuration
echo "📋 Creating site configuration..."
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

# Enable the site
echo "🔗 Enabling site..."
sudo ln -sf /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
    echo "🔄 Restarting Nginx..."
    sudo systemctl restart nginx
    echo "✅ Nginx restarted successfully"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

echo "🎉 Nginx configuration fixed!"