#!/bin/bash

echo "🔄 Restarting with Direct Node Command"
echo "====================================="

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create proper environment
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-direct-start
EOF

# Test database connection first
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" || {
    echo "Database connection failed"
    exit 1
}

# Install any missing dependencies
npm install tsx

# Start with PM2 using tsx directly (bypasses npm script issues)
pm2 start tsx \
    --name voltservers \
    -- server/index.ts \
    --env NODE_ENV=production \
    --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
    --env PORT=5000 \
    --env SESSION_SECRET="pm2-tsx-direct"

pm2 save

sleep 5
echo "Testing direct tsx startup..."
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ SUCCESS: Direct tsx startup working!"
    echo "✅ Access at: http://135.148.137.158/"
else
    echo "❌ Direct tsx startup failed"
    echo "PM2 logs:"
    pm2 logs --lines 15
fi