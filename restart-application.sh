#!/bin/bash

echo "Restarting VoltServers application..."

cd /home/ubuntu/voltservers

# Stop all PM2 processes
pm2 delete all 2>/dev/null || true

# Check if database password exists
if [[ ! -f ~/.voltservers_db_password ]]; then
    echo "Creating database password..."
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
    sudo -u postgres psql -c "ALTER USER voltservers PASSWORD '$DB_PASSWORD';"
else
    DB_PASSWORD=$(cat ~/.voltservers_db_password)
fi

# Recreate environment file with local database
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)
EOF

# Test local database connection
echo "Testing database connection..."
sudo systemctl restart postgresql
sleep 2

if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" > /dev/null 2>&1; then
    echo "Local database connection successful"
else
    echo "Database connection failed - recreating database..."
    sudo -u postgres dropdb voltservers 2>/dev/null || true
    sudo -u postgres createdb voltservers
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
    sudo -u postgres psql -d voltservers -c "GRANT ALL ON SCHEMA public TO voltservers;"
fi

# Run database migrations
echo "Setting up database schema..."
npm run db:push

# Start application
echo "Starting application..."
pm2 start ecosystem.config.cjs --env production
pm2 save

# Wait and check status
sleep 5
echo "Application status:"
pm2 status

# Test application
echo "Testing application..."
sleep 3
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "SUCCESS: Application is responding"
else
    echo "Application not responding. Logs:"
    pm2 logs voltservers --lines 10
fi