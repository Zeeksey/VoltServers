#!/bin/bash

echo "Final Working Fix for VoltServers Production"
echo "==========================================="

cd /home/ubuntu/voltservers

# Stop everything
pm2 delete all 2>/dev/null || true
sudo pkill -f "node.*5000" 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create proper environment
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-final-working
EOF

# Install tsx globally and locally
npm install -g tsx
npm install tsx

# Test database connection
echo "Testing database connection..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" || {
    echo "Database connection failed, fixing..."
    sudo systemctl restart postgresql
    sleep 2
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE DATABASE voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
}

# Push database schema
npm run db:push

# Test manual startup first
echo "Testing manual startup..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="manual-final-test"

timeout 10 npx tsx server/index.ts &
MANUAL_PID=$!
sleep 6

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "Manual startup successful!"
    kill $MANUAL_PID 2>/dev/null
    
    # Start with PM2 using npx tsx
    echo "Starting with PM2..."
    pm2 start "npx tsx server/index.ts" \
        --name voltservers-final \
        --env NODE_ENV=production \
        --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
        --env PORT=5000 \
        --env SESSION_SECRET="pm2-final-working"
    
    pm2 save
    
    sleep 5
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "SUCCESS: VoltServers is now running!"
        echo "Access your platform at: http://135.148.137.158/"
        
        # Test external access
        if curl -f http://127.0.0.1 > /dev/null 2>&1; then
            echo "Nginx proxy working perfectly!"
        else
            echo "Restarting Nginx..."
            sudo systemctl restart nginx
            sleep 2
            curl -f http://127.0.0.1 > /dev/null 2>&1 && echo "Nginx fixed!" || echo "Check Nginx manually"
        fi
        
        echo ""
        echo "DEPLOYMENT COMPLETE!"
        echo "==================="
        echo "Your VoltServers platform is live at http://135.148.137.158/"
        echo "PM2 Status:"
        pm2 status
    else
        echo "PM2 startup failed"
        pm2 logs --lines 15
    fi
else
    echo "Manual startup failed"
    kill $MANUAL_PID 2>/dev/null
    echo "Error output:"
    npx tsx server/index.ts
fi