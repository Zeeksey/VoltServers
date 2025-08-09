#!/bin/bash

echo "🔧 Fixing Database Connection to Use Local PostgreSQL"
echo "=================================================="

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create proper .env with local PostgreSQL (NOT Neon)
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-local-production
EOF

echo "Environment file created:"
cat .env

# Ensure PostgreSQL is running
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Test local database connection
echo ""
echo "Testing local PostgreSQL connection..."
if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" 2>/dev/null; then
    echo "✅ Local PostgreSQL connection successful"
else
    echo "Setting up local database..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE DATABASE voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
    sudo -u postgres psql -d voltservers -c "GRANT ALL ON SCHEMA public TO voltservers;"
fi

# Build application
echo ""
echo "Building application..."
npm run build

# Push database schema to local PostgreSQL
echo "Setting up database schema..."
npm run db:push

# Test manual startup with explicit environment
echo ""
echo "Testing manual startup with local database..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="manual-test"

# Kill any process on port 5000
sudo pkill -f "node.*5000" 2>/dev/null || true
sleep 2

echo "Starting application manually for testing..."
timeout 15 node dist/index.js &
MANUAL_PID=$!
sleep 8

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Manual startup successful - local database working!"
    kill $MANUAL_PID 2>/dev/null
    
    # Start with PM2
    echo ""
    echo "Starting with PM2..."
    pm2 start dist/index.js \
        --name voltservers \
        --env NODE_ENV=production \
        --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
        --env PORT=5000 \
        --env SESSION_SECRET="pm2-local-production"
    
    pm2 save
    
    sleep 5
    echo "Testing PM2 startup..."
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "✅ SUCCESS: VoltServers running with local PostgreSQL!"
        echo "✅ Access your site at: http://135.148.137.158/"
        
        # Test Nginx proxy
        if curl -f http://127.0.0.1 > /dev/null 2>&1; then
            echo "✅ Nginx proxy working"
        else
            echo "Restarting Nginx..."
            sudo systemctl restart nginx
        fi
    else
        echo "❌ PM2 startup failed"
        pm2 logs voltservers --lines 15
    fi
else
    echo "❌ Manual startup failed"
    kill $MANUAL_PID 2>/dev/null
    echo "Application logs:"
    timeout 10 node dist/index.js
fi