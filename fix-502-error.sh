#!/bin/bash

# Quick 502 Error Fix for VoltServers
echo "🔍 Diagnosing 502 Gateway Error..."

echo "1. Checking PM2 status:"
pm2 status

echo ""
echo "2. Checking application logs:"
pm2 logs voltservers --lines 20

echo ""
echo "3. Checking if app is listening on correct port:"
netstat -tlnp | grep :5000 || echo "Port 5000 not found"

echo ""
echo "4. Testing direct connection to app:"
curl -I http://localhost:5000 2>/dev/null || echo "Direct connection failed"

echo ""
echo "5. Checking Nginx status:"
sudo systemctl status nginx --no-pager

echo ""
echo "6. Testing Nginx configuration:"
sudo nginx -t

echo ""
echo "7. Checking Nginx error logs:"
sudo tail -20 /var/log/nginx/error.log

echo ""
echo "📋 Most common fixes:"
echo "   - Restart PM2: pm2 restart voltservers"
echo "   - Restart Nginx: sudo systemctl restart nginx"
echo "   - Check firewall: sudo ufw status"