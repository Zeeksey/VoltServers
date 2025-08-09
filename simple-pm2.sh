#!/bin/bash

echo "Simple PM2 restart with environment variables..."

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Start with PM2 using direct environment variables
pm2 start dist/index.js \
  --name "voltservers" \
  --env NODE_ENV=production \
  --env PORT=5000 \
  --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
  --env SESSION_SECRET="pm2-session-secret"

# Save PM2 configuration
pm2 save

# Wait and test
sleep 5
echo "PM2 Status:"
pm2 status

echo "Testing application:"
curl -I http://localhost:5000

echo "Recent logs:"
pm2 logs --lines 10