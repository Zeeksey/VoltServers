#!/bin/bash

# Quick fix for PM2 configuration on Ubuntu server
# Run this script in your voltservers directory

echo "🔧 Fixing PM2 ecosystem configuration..."

# Stop any existing PM2 processes
pm2 delete all 2>/dev/null || true

# Create correct PM2 configuration
cat > ecosystem.config.js << 'EOF'
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
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
EOF

# Ensure logs directory exists
mkdir -p logs

# Test PM2 configuration
if node -c ecosystem.config.js; then
    echo "✅ PM2 configuration syntax valid"
else
    echo "❌ PM2 configuration has syntax errors"
    exit 1
fi

# Start application
echo "🚀 Starting VoltServers application..."
pm2 start ecosystem.config.js --env production

# Save PM2 process list
pm2 save

# Display status
echo "📊 Application Status:"
pm2 status

echo ""
echo "✅ PM2 configuration fixed and application started!"
echo ""
echo "Management commands:"
echo "  pm2 status           - Check status"
echo "  pm2 logs voltservers - View logs"
echo "  pm2 restart voltservers - Restart app"
echo ""