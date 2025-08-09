#!/bin/bash

echo "Force fixing DATABASE_URL in application..."

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)
CORRECT_DB_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

# Check if the built application exists
if [[ ! -f dist/index.js ]]; then
    echo "Building application..."
    npm run build
fi

# Create a wrapper script that forces the correct environment
cat > run-voltservers.js << EOF
// Force set environment variables before importing anything
process.env.NODE_ENV = 'production';
process.env.PORT = '5000';
process.env.DATABASE_URL = '$CORRECT_DB_URL';
process.env.SESSION_SECRET = 'voltservers-forced-secret';

// Clear any conflicting DATABASE_URL
delete process.env.DATABASE_URL;
process.env.DATABASE_URL = '$CORRECT_DB_URL';

console.log('Forced environment variables:');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('PORT:', process.env.PORT);
console.log('DATABASE_URL:', process.env.DATABASE_URL ? 'SET' : 'NOT SET');

// Import and run the application
import('./dist/index.js').catch(err => {
    console.error('Application failed to start:', err);
    process.exit(1);
});
EOF

# Test database connection
echo "Testing database connection..."
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" 2>/dev/null && echo "Database OK" || {
    echo "Database connection failed, fixing..."
    sudo systemctl restart postgresql
    sleep 2
    npm run db:push
}

# Start with the wrapper script
echo "Starting application with forced environment..."
pm2 start run-voltservers.js --name "voltservers" --interpreter node
pm2 save

# Wait and test
sleep 10
echo "PM2 Status:"
pm2 status

echo "Testing application..."
if curl -f http://localhost:5000 >/dev/null 2>&1; then
    echo "SUCCESS: Application responding"
    curl -I http://127.0.0.1 >/dev/null 2>&1 && echo "External access OK" || {
        echo "Fixing Nginx..."
        sudo systemctl restart nginx
    }
else
    echo "Still not responding. Logs:"
    pm2 logs voltservers --lines 15
fi