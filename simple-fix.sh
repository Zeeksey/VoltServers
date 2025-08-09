#!/bin/bash

echo "Simple VoltServers Fix"
echo "===================="

cd /home/ubuntu/voltservers

# Stop everything
pm2 delete all 2>/dev/null || true

# Get password
DB_PASSWORD=$(cat ~/.voltservers_db_password 2>/dev/null)
if [[ -z "$DB_PASSWORD" ]]; then
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
fi

# Simple environment
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=simple-secret-key-for-testing
EOF

# Fix database
sudo systemctl start postgresql
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 2>/dev/null || true
sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;" 2>/dev/null
sudo -u postgres psql -c "CREATE DATABASE voltservers;"
sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"

# Test DB connection
echo "Testing database..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" || exit 1

# Build app
echo "Building application..."
npm run build || exit 1

# Check if dist exists
if [[ ! -f dist/index.js ]]; then
    echo "Build failed - dist/index.js not found"
    exit 1
fi

# Simple PM2 config
cat > ecosystem.simple.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'voltservers',
    script: './dist/index.js',
    env: {
      NODE_ENV: 'production',
      PORT: '5000'
    },
    env_file: '.env'
  }]
};
EOF

# Start with simple config
pm2 start ecosystem.simple.cjs
pm2 save

# Wait and test
sleep 10
echo "Testing application..."
curl -I http://localhost:5000 2>/dev/null && echo "SUCCESS" || echo "FAILED"

echo "PM2 Status:"
pm2 status

echo "Recent logs:"
pm2 logs voltservers --lines 10