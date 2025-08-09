#!/bin/bash

echo "=== VoltServers Debug Information ==="

cd /home/ubuntu/voltservers

echo "1. Checking PM2 status:"
pm2 status

echo ""
echo "2. Checking if application files exist:"
ls -la dist/index.js 2>/dev/null || echo "dist/index.js not found"
ls -la ecosystem.config.cjs 2>/dev/null || echo "ecosystem.config.cjs not found"
ls -la .env 2>/dev/null || echo ".env not found"

echo ""
echo "3. Environment variables:"
if [[ -f .env ]]; then
    echo "DATABASE_URL exists: $(grep -c DATABASE_URL .env)"
    echo "PORT exists: $(grep -c PORT .env)"
else
    echo ".env file missing"
fi

echo ""
echo "4. Database status:"
sudo systemctl status postgresql --no-pager | head -3

echo ""
echo "5. Testing database connection:"
DB_PASSWORD=$(cat ~/.voltservers_db_password 2>/dev/null || echo "MISSING")
if [[ "$DB_PASSWORD" != "MISSING" ]]; then
    PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" 2>/dev/null && echo "Database OK" || echo "Database connection failed"
else
    echo "Database password file missing"
fi

echo ""
echo "6. Recent PM2 logs:"
pm2 logs voltservers --lines 10 2>/dev/null || echo "No PM2 logs available"

echo ""
echo "7. Nginx status:"
sudo systemctl status nginx --no-pager | head -3

echo ""
echo "8. Port 5000 usage:"
sudo netstat -tlnp | grep :5000 || echo "Nothing listening on port 5000"

echo ""
echo "9. Application build status:"
if [[ -d dist ]]; then
    echo "dist directory exists with $(ls dist/ | wc -l) files"
else
    echo "dist directory missing - need to build"
fi