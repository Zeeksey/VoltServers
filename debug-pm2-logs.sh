#!/bin/bash

echo "🔍 Debugging PM2 Process and Logs"
echo "================================="

cd /home/ubuntu/voltservers

echo "1. PM2 Status:"
pm2 status

echo ""
echo "2. PM2 Logs (last 20 lines):"
pm2 logs --lines 20

echo ""
echo "3. What's listening on port 5000:"
sudo netstat -tlnp | grep :5000

echo ""
echo "4. PM2 Process Details:"
pm2 show voltservers 2>/dev/null || pm2 show 0

echo ""
echo "5. Environment variables check:"
pm2 env 0 2>/dev/null || echo "Cannot get PM2 environment"

echo ""
echo "6. Manual test with same environment:"
export NODE_ENV=production
DB_PASSWORD=$(cat ~/.voltservers_db_password)
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="manual-debug"

echo "Starting manual test for 5 seconds..."
timeout 5 npm run dev 2>&1 | head -10