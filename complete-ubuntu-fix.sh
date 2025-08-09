#!/bin/bash

# Complete Ubuntu Server Fix for VoltServers
echo "🔧 Complete Ubuntu Server Fix - VoltServers Deployment"

# Navigate to app directory
cd /home/ubuntu/voltservers || { echo "Error: Please run this from /home/ubuntu/voltservers directory"; exit 1; }

# Stop all PM2 processes
echo "🛑 Stopping existing PM2 processes..."
pm2 delete all 2>/dev/null || echo "No PM2 processes to stop"

# Get database password
echo "📋 Setting up environment configuration..."
echo "Enter your PostgreSQL database password for user 'voltservers':"
read -s DB_PASSWORD

# Create proper .env file
echo "📝 Creating environment file..."
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

# Create ecosystem.config.js for PM2
echo "⚙️ Creating PM2 configuration..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'voltservers',
    script: './dist/index.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'development'
    },
    env_production: {
      NODE_ENV: 'production'
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    max_memory_restart: '1G',
    restart_delay: 4000
  }]
}
EOF

# Create logs directory
mkdir -p logs

# Ensure PostgreSQL is running
echo "🗄️ Checking PostgreSQL status..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Test database connection
echo "🔍 Testing database connection..."
if ! psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" 2>/dev/null; then
    echo "❌ Database connection failed. Recreating database setup..."
    
    # Recreate database and user
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS voltservers;"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "CREATE DATABASE voltservers OWNER voltservers;"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
    sudo -u postgres psql -c "ALTER USER voltservers CREATEDB;"
    
    echo "✅ Database recreated successfully"
else
    echo "✅ Database connection successful"
fi

# Install dependencies and build
echo "📦 Installing dependencies..."
npm install

echo "🔨 Building application..."
npm run build

# Run database migrations
echo "🗄️ Running database migrations..."
npm run db:push

# Start application with PM2
echo "🚀 Starting VoltServers with PM2..."
pm2 start ecosystem.config.js --env production
pm2 save

# Set up PM2 startup
pm2 startup ubuntu -u ubuntu --hp /home/ubuntu | tail -n 1 | bash

# Display status
echo ""
echo "📊 Current Status:"
pm2 status

echo ""
echo "🎉 VoltServers deployment completed successfully!"
echo ""
echo "📍 Your application is now running at:"
echo "   http://$(curl -s http://checkip.amazonaws.com):5000"
echo ""
echo "📋 Useful commands:"
echo "   pm2 status           - Check application status"
echo "   pm2 logs voltservers - View application logs"
echo "   pm2 monit           - Monitor resources"
echo "   pm2 restart voltservers - Restart application"
echo ""
echo "🔧 If you need to update your application:"
echo "   git pull origin main"
echo "   npm install"
echo "   npm run build"
echo "   npm run db:push"
echo "   pm2 restart voltservers"