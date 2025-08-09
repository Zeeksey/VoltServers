#!/bin/bash

echo "Emergency fix - Direct environment injection..."

cd /home/ubuntu/voltservers

# Stop everything
pm2 delete all 2>/dev/null || true

# Get password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Remove any global DATABASE_URL
sudo sed -i '/DATABASE_URL/d' /etc/environment 2>/dev/null || true
unset DATABASE_URL

# Create a simple Node.js starter that bypasses environment issues
cat > start.js << EOF
const { spawn } = require('child_process');

// Set environment variables directly
const env = {
    ...process.env,
    NODE_ENV: 'production',
    PORT: '5000',
    DATABASE_URL: 'postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers',
    SESSION_SECRET: 'emergency-session-secret'
};

// Remove any conflicting DATABASE_URL
delete env.DATABASE_URL;
env.DATABASE_URL = 'postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers';

console.log('Starting with DATABASE_URL:', env.DATABASE_URL);

// Start the application
const child = spawn('node', ['dist/index.js'], {
    env: env,
    stdio: 'inherit'
});

child.on('error', (err) => {
    console.error('Failed to start application:', err);
    process.exit(1);
});

child.on('exit', (code) => {
    console.log('Application exited with code:', code);
    process.exit(code);
});
EOF

# Replace the placeholder with actual password
sed -i "s/\$DB_PASSWORD/$DB_PASSWORD/g" start.js

# Test database
echo "Testing database..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" 2>/dev/null || {
    echo "Fixing database..."
    sudo systemctl restart postgresql
    sleep 2
    npm run db:push
}

# Start with PM2
echo "Starting emergency configuration..."
pm2 start start.js --name "voltservers"
pm2 save

sleep 8
echo "Testing..."
curl -I http://localhost:5000 && echo "SUCCESS" || echo "FAILED"
pm2 logs voltservers --lines 5