#!/bin/bash

echo "🔧 Complete VoltServers Fix - Building and Deploying"
echo "=================================================="

cd /home/ubuntu/voltservers

# 1. Stop everything
echo "1. Stopping PM2 processes..."
pm2 delete all 2>/dev/null || true

# 2. Setup database
echo "2. Setting up database..."
if [[ ! -f ~/.voltservers_db_password ]]; then
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
else
    DB_PASSWORD=$(cat ~/.voltservers_db_password)
fi

# Restart PostgreSQL
sudo systemctl restart postgresql
sleep 2

# Create database if it doesn't exist
sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE voltservers;"
sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null || true
sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
sudo -u postgres psql -d voltservers -c "GRANT ALL ON SCHEMA public TO voltservers;"

# 3. Create proper environment file
echo "3. Creating environment configuration..."
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)
EOF

# 4. Build the application
echo "4. Building application..."
npm run build

# 5. Test database connection
echo "5. Testing database connection..."
if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" > /dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    exit 1
fi

# 6. Run database migrations
echo "6. Setting up database schema..."
npm run db:push

# 7. Ensure logs directory exists
mkdir -p logs

# 8. Start application with PM2
echo "7. Starting application..."
pm2 start ecosystem.config.cjs --env production
pm2 save

# 9. Wait and test
echo "8. Testing application startup..."
sleep 10

# Check PM2 status
echo "PM2 Status:"
pm2 status

# Test application response
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Application responding on port 5000"
    
    # Test Nginx proxy
    if curl -f http://127.0.0.1 > /dev/null 2>&1; then
        echo "✅ Nginx proxy working"
        echo ""
        echo "🎉 SUCCESS: VoltServers is now accessible at http://135.148.137.158/"
    else
        echo "⚠️ Application running but Nginx proxy needs fixing"
        sudo systemctl restart nginx
    fi
else
    echo "❌ Application not responding. Recent logs:"
    pm2 logs voltservers --lines 15
fi