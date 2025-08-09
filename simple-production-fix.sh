#!/bin/bash

echo "🔧 Simple Production Fix - No Vite Dependencies"
echo "=============================================="

cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete all 2>/dev/null || true

# Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)

# Create environment
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-simple-production
EOF

echo "Environment:"
cat .env

# Install missing dependencies
echo "Installing dependencies..."
npm install vite @vitejs/plugin-react

# Clean build directories
rm -rf dist/
rm -rf client/dist/

# Build frontend only (skip server build that requires Vite)
echo "Building frontend..."
npx vite build

# Create a simple production server that doesn't use Vite
echo "Creating simple production server..."
cat > simple-server.js << 'EOF'
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from './shared/schema.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Database setup
const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: false
});
const db = drizzle(pool, { schema });

// Serve static files
app.use(express.static(join(__dirname, 'client/dist')));

// Basic API routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Fallback to index.html for SPA
app.get('*', (req, res) => {
  res.sendFile(join(__dirname, 'client/dist/index.html'));
});

const port = parseInt(process.env.PORT || '5000', 10);
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
EOF

# Test database connection
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();"

# Test simple server
echo "Testing simple server..."
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="test"

sudo pkill -f "node.*5000" 2>/dev/null || true
timeout 10 node simple-server.js &
SIMPLE_PID=$!
sleep 5

if curl -f http://localhost:5000 > /dev/null 2>&1; then
    echo "✅ Simple server working!"
    kill $SIMPLE_PID 2>/dev/null
    
    # Start with PM2
    pm2 start simple-server.js \
        --name voltservers-simple \
        --env NODE_ENV=production \
        --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
        --env PORT=5000 \
        --env SESSION_SECRET="pm2-simple"
    
    pm2 save
    
    sleep 3
    if curl -f http://localhost:5000 > /dev/null 2>&1; then
        echo "✅ SUCCESS: Simple VoltServers running!"
        echo "✅ Access at: http://135.148.137.158/"
    else
        echo "PM2 issue"
        pm2 logs --lines 10
    fi
else
    echo "❌ Simple server failed"
    kill $SIMPLE_PID 2>/dev/null
fi