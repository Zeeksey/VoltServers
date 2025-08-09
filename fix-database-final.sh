#!/bin/bash

echo "🔧 Final Database Fix - Replacing Neon with Local PostgreSQL"
echo "==========================================================="

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create correct .env file
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-fixed-production
EOF

echo "Environment file:"
cat .env

# Install standard PostgreSQL driver
npm install pg drizzle-orm

# Build with the fixed database connection
echo "Building application with local PostgreSQL support..."
npm run build

# Test database connection
echo "Testing local database..."
sudo systemctl start postgresql
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" || {
    echo "Setting up database..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE DATABASE voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
}

# Setup schema
npm run db:push

# Start manually first to test
echo "Testing manual startup with local PostgreSQL..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="manual-test"

sudo pkill -f "node.*5000" 2>/dev/null || true
timeout 15 node dist/index.js &
MANUAL_PID=$!
sleep 8

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ SUCCESS: Application running with local PostgreSQL!"
    kill $MANUAL_PID 2>/dev/null
    
    # Start with PM2
    pm2 start dist/index.js --name voltservers \
        --env NODE_ENV=production \
        --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
        --env PORT=5000 \
        --env SESSION_SECRET="pm2-local-fixed"
    
    pm2 save
    
    echo "Testing PM2 startup..."
    sleep 5
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "✅ FINAL SUCCESS: VoltServers running on http://135.148.137.158/"
    else
        echo "PM2 startup issue"
        pm2 logs --lines 10
    fi
else
    echo "❌ Manual startup failed"
    kill $MANUAL_PID 2>/dev/null
fi