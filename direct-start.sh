#!/bin/bash

echo "Direct application start test..."

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null

# Set environment variables
export NODE_ENV=production
export PORT=5000
export SESSION_SECRET="direct-start-secret"

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "Environment set:"
echo "NODE_ENV=$NODE_ENV"
echo "PORT=$PORT"
echo "DATABASE_URL=$DATABASE_URL"

# Test database first
echo "Testing database..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" || {
    echo "Database failed, fixing..."
    sudo systemctl restart postgresql
    sleep 2
    npm run db:push
}

# Start application directly
echo "Starting application directly..."
echo "Command: node dist/index.js"

# Run with timeout to see startup
timeout 30 node dist/index.js