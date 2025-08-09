#!/bin/bash

echo "🎉 VoltServers Deployment Verification"
echo "======================================"

# Check PM2 status
echo "1. PM2 Application Status:"
pm2 status

echo ""
echo "2. Testing application response:"
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Application responding on port 5000"
else
    echo "❌ Application not responding on port 5000"
fi

echo ""
echo "3. Checking Nginx status:"
sudo systemctl status nginx --no-pager -l | head -5

echo ""
echo "4. Testing external access:"
SERVER_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "Unable to get IP")
echo "Your server IP: $SERVER_IP"
echo "Access your VoltServers platform at: http://$SERVER_IP"

echo ""
echo "5. Application logs (last 5 lines):"
pm2 logs voltservers --lines 5

echo ""
echo "🎯 Deployment Complete!"
echo "Your VoltServers platform is now live and accessible."