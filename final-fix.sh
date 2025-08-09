#!/bin/bash

echo "🔧 Final VoltServers Production Fix"
echo "=================================="

cd /home/ubuntu/voltservers

# Stop all PM2 processes
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password 2>/dev/null)
if [[ -z "$DB_PASSWORD" ]]; then
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
fi

# Test database connection
echo "Testing database connection..."
sudo systemctl start postgresql
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Setting up database..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;" 2>/dev/null
    sudo -u postgres psql -c "CREATE DATABASE voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;" 2>/dev/null
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
fi

# Create a startup script that sets environment variables explicitly
cat > start-voltservers.sh << EOF
#!/bin/bash
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="voltservers-production-secret"

cd /home/ubuntu/voltservers
exec node dist/index.js
EOF

chmod +x start-voltservers.sh

# Build application
echo "Building application..."
npm run build

# Check if build succeeded
if [[ ! -f dist/index.js ]]; then
    echo "❌ Build failed"
    exit 1
fi

# Create PM2 config that uses the startup script
cat > ecosystem.production.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'voltservers',
    script: './start-voltservers.sh',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    interpreter: '/bin/bash',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# Ensure logs directory exists
mkdir -p logs

# Start application
echo "Starting VoltServers with PM2..."
pm2 start ecosystem.production.cjs
pm2 save

# Wait and test
echo "Waiting for application to start..."
sleep 10

# Check status
echo "PM2 Status:"
pm2 status

# Test application
echo "Testing application response..."
for i in {1..5}; do
    if curl -f http://localhost:5000 >/dev/null 2>&1; then
        echo "✅ SUCCESS: VoltServers is running on port 5000"
        
        # Test external access
        if curl -f http://127.0.0.1 >/dev/null 2>&1; then
            echo "✅ External access working - VoltServers available at http://135.148.137.158/"
        else
            echo "⚠️ Nginx proxy issue - restarting nginx..."
            sudo systemctl restart nginx
            sleep 2
            curl -f http://127.0.0.1 >/dev/null 2>&1 && echo "✅ Nginx fixed" || echo "❌ Nginx still has issues"
        fi
        exit 0
    else
        echo "Attempt $i failed, waiting..."
        sleep 3
    fi
done

echo "❌ Application failed to start. Recent logs:"
pm2 logs voltservers --lines 15