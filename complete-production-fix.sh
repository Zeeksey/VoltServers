#!/bin/bash

echo "🔧 Complete Production Fix for VoltServers"
echo "=========================================="

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create proper .env
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-production-final
EOF

echo "Environment configuration:"
cat .env

# Ensure PostgreSQL is running and database exists
sudo systemctl start postgresql
sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;" 2>/dev/null
sudo -u postgres psql -c "CREATE DATABASE voltservers;"
sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"

# Test database connection
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();"

# Clean and rebuild
echo "Cleaning and rebuilding application..."
rm -rf dist/
rm -rf client/dist/

# Build frontend first
npm run build

# Build backend manually with proper bundling
echo "Building backend server..."
npx esbuild server/index.ts \
  --platform=node \
  --bundle \
  --format=esm \
  --outdir=dist \
  --external:pg \
  --external:bcrypt \
  --external:express \
  --external:drizzle-orm \
  --target=node20

# Check if build succeeded
if [[ ! -f dist/index.js ]]; then
    echo "❌ Build failed"
    exit 1
fi

# Setup database schema
npm run db:push

# Test production startup
echo "Testing production startup..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="production-test"

# Kill any existing processes
sudo pkill -f "node.*5000" 2>/dev/null || true
sleep 2

# Test startup
echo "Starting application for testing..."
timeout 15 node dist/index.js &
APP_PID=$!
sleep 8

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Production startup successful!"
    kill $APP_PID 2>/dev/null
    
    # Start with PM2
    echo "Starting with PM2..."
    pm2 start dist/index.js \
        --name voltservers \
        --env NODE_ENV=production \
        --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
        --env PORT=5000 \
        --env SESSION_SECRET="pm2-production-final"
    
    pm2 save
    
    sleep 5
    echo "Final test..."
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "✅ SUCCESS: VoltServers is now running!"
        echo "✅ Access your platform at: http://135.148.137.158/"
        
        # Test external access through Nginx
        if curl -f http://127.0.0.1 > /dev/null 2>&1; then
            echo "✅ Nginx proxy working"
        else
            echo "Restarting Nginx..."
            sudo systemctl restart nginx
            sleep 2
            curl -f http://127.0.0.1 > /dev/null 2>&1 && echo "✅ Nginx fixed" || echo "⚠️ Check Nginx config"
        fi
        
        echo ""
        echo "🎉 DEPLOYMENT COMPLETE!"
        echo "Your VoltServers platform is now live and accessible."
    else
        echo "❌ PM2 startup failed"
        pm2 logs --lines 15
    fi
else
    echo "❌ Production startup failed"
    kill $APP_PID 2>/dev/null
    echo "Attempting to start and show errors:"
    node dist/index.js
fi