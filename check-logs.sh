#!/bin/bash

echo "Checking PM2 logs and application status..."

cd /home/ubuntu/voltservers

echo "1. PM2 logs:"
pm2 logs --lines 20

echo ""
echo "2. PM2 process details:"
pm2 show 0

echo ""
echo "3. What's listening on port 5000:"
sudo netstat -tlnp | grep :5000

echo ""
echo "4. Application files:"
ls -la dist/
ls -la start-voltservers.sh

echo ""
echo "5. Testing startup script manually:"
echo "Running: ./start-voltservers.sh"
timeout 10 ./start-voltservers.sh &
MANUAL_PID=$!
sleep 3
kill $MANUAL_PID 2>/dev/null

echo ""
echo "6. Database connection test:"
DB_PASSWORD=$(cat ~/.voltservers_db_password)
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" 2>/dev/null && echo "Database OK" || echo "Database failed"