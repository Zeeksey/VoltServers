#!/bin/bash

echo "Manual Application Start"
echo "======================"

cd /home/ubuntu/voltservers

# Set environment
export NODE_ENV=production
export PORT=5000
export DATABASE_URL="postgresql://voltservers:$(cat ~/.voltservers_db_password)@localhost:5432/voltservers"
export SESSION_SECRET="manual-session-secret"

# Test database first
echo "Testing database connection..."
PGPASSWORD="$(cat ~/.voltservers_db_password)" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" || {
    echo "Database connection failed"
    exit 1
}

# Try to start manually first
echo "Starting application manually..."
if [[ -f dist/index.js ]]; then
    echo "Running: node dist/index.js"
    timeout 30 node dist/index.js &
    APP_PID=$!
    sleep 5
    
    # Test if it's responding
    if curl -f http://localhost:5000 >/dev/null 2>&1; then
        echo "SUCCESS: Application responding manually"
        kill $APP_PID 2>/dev/null
        
        # Now try with PM2
        echo "Starting with PM2..."
        pm2 delete all 2>/dev/null || true
        pm2 start dist/index.js --name voltservers --env production
        pm2 save
        
        sleep 3
        curl -I http://localhost:5000
    else
        echo "FAILED: Application not responding manually"
        kill $APP_PID 2>/dev/null
        echo "Application output:"
        timeout 10 node dist/index.js
    fi
else
    echo "ERROR: dist/index.js not found. Running build..."
    npm run build
fi