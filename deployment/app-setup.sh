#!/bin/bash

# VoltServers Application Setup Script
# Run this as the ubuntu user after uploading files

set -e

APP_DIR="/home/ubuntu/voltservers"
DB_PASSWORD="VoltPass2025!!"
SESSION_SECRET="VoltServers2025SecretKey!!"
DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"

echo "🚀 Setting up VoltServers application..."

cd $APP_DIR

# Create production environment file
echo "⚙️  Creating environment configuration..."
cat > .env << EOL
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
SESSION_SECRET=$SESSION_SECRET
PORT=5000
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key_here
EOL

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Build application
echo "🔧 Building application..."
npm run build

# Setup database schema
echo "🗄️  Setting up database schema..."
npm run db:push

# Start with PM2
echo "🚀 Starting application with PM2..."
pm2 delete voltservers 2>/dev/null || true
pm2 start npm --name "voltservers" -- start
pm2 save
pm2 startup | tail -1 | sudo bash

echo "✅ Application setup completed!"
echo "🌐 Application running on port 5000"
