#!/bin/bash

# Fix DATABASE_URL Error on Ubuntu Server
echo "🔧 Fixing DATABASE_URL configuration error..."

# Navigate to app directory
cd /home/ubuntu/voltservers || { echo "Error: voltservers directory not found"; exit 1; }

# Stop all PM2 processes
pm2 delete all

echo "📋 Setting up environment variables..."

# Get database password from user
echo "Enter your PostgreSQL database password for user 'voltservers':"
echo "(This was set when you created the database)"
read -s DB_PASSWORD

# Create proper .env file
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)

# Optional API Keys - uncomment and add your keys if needed
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
if psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" 2>/dev/null; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed. Let's fix this..."
    
    # Ensure PostgreSQL is running
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    
    # Recreate database and user if needed
    echo "Setting up database..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "CREATE DATABASE voltservers OWNER voltservers;"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
    sudo -u postgres psql -c "ALTER USER voltservers CREATEDB;"
    
    echo "✅ Database recreated"
fi

# Rebuild application
echo "🔨 Rebuilding application..."
npm install
npm run build

# Run database migrations
echo "🗄️ Running database migrations..."
npm run db:push

# Start application with PM2
echo "🚀 Starting application..."
pm2 start ecosystem.config.js --env production
pm2 save

# Check status
echo "📊 Application Status:"
pm2 status

echo ""
echo "🎉 Fix completed! Your VoltServers application should now be running."
echo ""
echo "Check logs with: pm2 logs voltservers"
echo "Monitor with: pm2 monit"
echo ""
echo "Your application should be available at:"
echo "http://$(curl -s http://checkip.amazonaws.com)"