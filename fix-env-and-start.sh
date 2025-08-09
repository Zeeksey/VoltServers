#!/bin/bash

echo "🔧 Fixing .env file and DATABASE_URL"
echo "=================================="

cd /home/ubuntu/voltservers

# Stop PM2
echo "Stopping PM2..."
pm2 delete all 2>/dev/null || true

# Get or create database password
if [[ ! -f ~/.voltservers_db_password ]]; then
    echo "Creating new database password..."
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
    chmod 600 ~/.voltservers_db_password
else
    DB_PASSWORD=$(cat ~/.voltservers_db_password)
fi

echo "Database password: $DB_PASSWORD"

# Create correct .env file
echo "Creating .env file..."
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-production-secret-$(date +%s)
EOF

echo "Contents of .env file:"
cat .env

# Test database connection
echo ""
echo "Testing database connection..."
sudo systemctl start postgresql
sleep 2

# Create database and user if needed
sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname='voltservers';" | grep -q 1 || {
    echo "Creating database..."
    sudo -u postgres psql -c "CREATE DATABASE voltservers;"
}

sudo -u postgres psql -c "SELECT 1 FROM pg_user WHERE usename='voltservers';" | grep -q 1 || {
    echo "Creating user..."
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
}

# Set permissions
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
sudo -u postgres psql -d voltservers -c "GRANT ALL ON SCHEMA public TO voltservers;"

# Test connection
if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" > /dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    exit 1
fi

# Build application
echo ""
echo "Building application..."
npm run build

if [[ ! -f dist/index.js ]]; then
    echo "❌ Build failed"
    exit 1
fi

# Run database migrations
echo "Setting up database schema..."
npm run db:push

# Test manual startup first
echo ""
echo "Testing manual startup..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="manual-test-secret"

echo "Starting application manually for 10 seconds..."
timeout 10 node dist/index.js &
MANUAL_PID=$!
sleep 5

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Manual startup successful"
    kill $MANUAL_PID 2>/dev/null
    
    # Now start with PM2
    echo ""
    echo "Starting with PM2..."
    pm2 start dist/index.js \
        --name voltservers \
        --env NODE_ENV=production \
        --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
        --env PORT=5000 \
        --env SESSION_SECRET="pm2-production-secret"
    
    pm2 save
    
    sleep 5
    echo "PM2 Status:"
    pm2 status
    
    echo "Testing PM2 startup..."
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "✅ SUCCESS: VoltServers running on port 5000"
        echo "✅ Your site should be accessible at http://135.148.137.158/"
    else
        echo "❌ PM2 startup failed"
        pm2 logs voltservers --lines 10
    fi
else
    echo "❌ Manual startup failed"
    kill $MANUAL_PID 2>/dev/null
    echo "Application output:"
    node dist/index.js
fi