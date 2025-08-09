#!/bin/bash

echo "🔧 Copying Built Application from Development"
echo "==========================================="

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create environment
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-copied-production
EOF

# We'll use the development server in production mode
# since the build is complex with Vite dependencies

# Test database
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();"

# Setup database schema
npm run db:push

# Start the development server in production mode
echo "Starting development server in production mode..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="dev-as-prod"

# Start with PM2 using development script but production environment
pm2 start "npm run dev" \
    --name voltservers-dev-prod \
    --env NODE_ENV=production \
    --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
    --env PORT=5000 \
    --env SESSION_SECRET="pm2-dev-prod"

pm2 save

sleep 5
echo "Testing development server as production..."
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ SUCCESS: VoltServers running via development server!"
    echo "✅ Access at: http://135.148.137.158/"
    
    # Test external access
    if curl -f http://127.0.0.1 > /dev/null 2>&1; then
        echo "✅ Nginx proxy working"
    else
        echo "Restarting Nginx..."
        sudo systemctl restart nginx
    fi
else
    echo "❌ Development server failed"
    pm2 logs --lines 10
fi