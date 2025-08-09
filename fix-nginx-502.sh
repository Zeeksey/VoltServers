#!/bin/bash

echo "Fixing Nginx 502 Gateway Error..."

# Check if Nginx configuration exists
if [[ ! -f /etc/nginx/sites-available/voltservers ]]; then
    echo "Creating Nginx configuration..."
    
    # Create Nginx config for VoltServers
    sudo tee /etc/nginx/sites-available/voltservers > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=1r/s;
    
    # API routes with rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static files and main application
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
echo "Testing Nginx configuration..."
if sudo nginx -t; then
    echo "Nginx configuration is valid"
else
    echo "Nginx configuration has errors"
    exit 1
fi

# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Check Nginx status
echo "Checking Nginx status..."
sudo systemctl status nginx --no-pager

# Test application connectivity
echo "Testing application connectivity..."
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "Application is responding on port 5000"
else
    echo "Application not responding on port 5000"
    pm2 logs voltservers --lines 5
    exit 1
fi

# Test external access
echo "Testing external access..."
if curl -f http://127.0.0.1 > /dev/null 2>&1; then
    echo "SUCCESS: External access working"
else
    echo "External access still failing. Checking logs..."
    sudo tail -5 /var/log/nginx/error.log
fi

echo "Nginx configuration complete!"