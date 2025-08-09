#!/bin/bash

# Complete deployment fix for VoltServers
echo "Fixing VoltServers deployment..."

cd /home/ubuntu/voltservers

# Stop PM2 processes
pm2 delete all 2>/dev/null || true

# Get or create database password
if [[ ! -f ~/.voltservers_db_password ]]; then
    echo "Creating database password..."
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
    sudo -u postgres psql -c "ALTER USER voltservers PASSWORD '$DB_PASSWORD';"
else
    DB_PASSWORD=$(cat ~/.voltservers_db_password)
fi

# Create proper .env file
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)
EOF

# Update PM2 config to load .env file
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'voltservers',
    script: './dist/index.js',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    restart_delay: 4000,
    env_file: '.env',
    env: {
      NODE_ENV: 'development'
    },
    env_production: {
      NODE_ENV: 'production'
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# Ensure logs directory exists
mkdir -p logs

# Test database connection
echo "Testing database connection..."
if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" > /dev/null 2>&1; then
    echo "Database connection successful"
else
    echo "Database connection failed - fixing..."
    sudo systemctl restart postgresql
    sleep 2
fi

# Start application
echo "Starting VoltServers application..."
pm2 start ecosystem.config.cjs --env production
pm2 save

# Wait and check status
sleep 5
echo "Application status:"
pm2 status

echo ""
echo "Testing application response..."
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "SUCCESS: Application is responding on port 5000"
    echo "Your VoltServers platform is now accessible!"
else
    echo "Application not responding. Recent logs:"
    pm2 logs voltservers --lines 10
fi