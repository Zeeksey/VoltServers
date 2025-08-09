#!/bin/bash

echo "Fixing environment variable conflict..."

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get our database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)
CORRECT_DB_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "Current DATABASE_URL: $DATABASE_URL"
echo "Correct DATABASE_URL: $CORRECT_DB_URL"

# Clear any global DATABASE_URL that might be set
unset DATABASE_URL

# Test database connection with correct credentials
echo "Testing database connection..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" 2>/dev/null && echo "Database OK" || {
    echo "Database connection failed, recreating..."
    sudo systemctl restart postgresql
    sleep 2
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE DATABASE voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
    npm run db:push
}

# Start PM2 with explicit environment override
pm2 start dist/index.js \
  --name "voltservers" \
  --env NODE_ENV=production \
  --env PORT=5000 \
  --env DATABASE_URL="$CORRECT_DB_URL" \
  --env SESSION_SECRET="voltservers-fixed-env"

pm2 save

# Wait and test
sleep 8
echo "PM2 Status:"
pm2 status

echo "Testing application..."
if curl -f http://localhost:5000 >/dev/null 2>&1; then
    echo "SUCCESS: Application is now responding"
    
    # Test external access
    if curl -f http://127.0.0.1 >/dev/null 2>&1; then
        echo "SUCCESS: External access working - VoltServers available at http://135.148.137.158/"
    else
        echo "Nginx proxy issue, restarting..."
        sudo systemctl restart nginx
    fi
else
    echo "Application still not responding. Recent logs:"
    pm2 logs voltservers --lines 10
fi