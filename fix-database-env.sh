#!/bin/bash

# Fix DATABASE_URL environment variable issue
echo "🔧 Fixing DATABASE_URL environment variable..."

cd /home/ubuntu/voltservers

# Get the database password
DB_PASSWORD=$(cat ~/.voltservers_db_password 2>/dev/null)

if [[ -z "$DB_PASSWORD" ]]; then
    echo "❌ Database password not found. Creating one..."
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    echo "$DB_PASSWORD" > ~/.voltservers_db_password
    
    # Update PostgreSQL user password
    sudo -u postgres psql -c "ALTER USER voltservers PASSWORD '$DB_PASSWORD';"
fi

echo "✅ Database password retrieved: ${DB_PASSWORD:0:8}..."

# Create/update .env file with correct DATABASE_URL
echo "📝 Creating .env file..."
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)

# Optional API keys (uncomment and configure as needed)
# WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
# WHMCS_API_SECRET=your_whmcs_api_secret
# WHMCS_URL=https://your-whmcs-domain.com
# SENDGRID_API_KEY=your_sendgrid_api_key
# WISP_API_URL=https://game.voltservers.com
# WISP_API_KEY=your_wisp_api_key
EOF

echo "✅ Environment file created"

# Test database connection
echo "🔍 Testing database connection..."
if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();" > /dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    exit 1
fi

# Restart PM2 application
echo "🔄 Restarting application..."
pm2 restart voltservers

# Wait a moment and check status
sleep 3
pm2 status

echo ""
echo "🎯 Testing application..."
if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Application is responding on port 5000"
else
    echo "❌ Application not responding. Check logs:"
    pm2 logs voltservers --lines 10
fi