# Ubuntu Deployment Troubleshooting Guide

## Fix: DATABASE_URL Missing Error

If you're getting the error: "DATABASE_URL must be set. Did you forget to provision a database?", here's how to fix it:

### Step 1: Check Current Environment Variables
```bash
cd /home/ubuntu/voltservers
cat .env
```

### Step 2: Fix Environment File
If the `.env` file is missing or incorrect, create it:

```bash
cd /home/ubuntu/voltservers
nano .env
```

Add this content (replace with your actual database password):
```env
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:your_database_password@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=your_session_secret_here

# Optional: Add your API keys
# WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
# WHMCS_API_SECRET=your_whmcs_api_secret
# WHMCS_URL=https://your-whmcs-domain.com
# SENDGRID_API_KEY=your_sendgrid_api_key
# WISP_API_URL=https://game.voltservers.com
# WISP_API_KEY=your_wisp_api_key
```

### Step 3: Verify Database Connection
Test if PostgreSQL is running and accessible:
```bash
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"
```

### Step 4: Test Database Connection
```bash
# Test connection with the voltservers user
psql -h localhost -U voltservers -d voltservers -c "SELECT 1;"
```

### Step 5: Rebuild and Restart Application
```bash
cd /home/ubuntu/voltservers
npm run build
pm2 restart voltservers
```

### Step 6: Check Application Status
```bash
pm2 status
pm2 logs voltservers --lines 20
```

## Alternative: Quick Reset Script

If you want to completely reset the environment, run this:

```bash
#!/bin/bash
cd /home/ubuntu/voltservers

# Stop PM2
pm2 delete voltservers

# Recreate environment file
echo "Enter your database password:"
read -s DB_PASSWORD

cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)
EOF

# Rebuild and restart
npm run build
pm2 start ecosystem.config.js --env production
pm2 save

echo "Application restarted with proper environment variables"
```

Save this as `reset-env.sh` and run it:
```bash
chmod +x reset-env.sh
./reset-env.sh
```

## Common Issues and Solutions

### Issue 1: PostgreSQL Not Running
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Issue 2: Database User Doesn't Exist
```bash
sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD 'your_password';"
sudo -u postgres psql -c "CREATE DATABASE voltservers OWNER voltservers;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
```

### Issue 3: Permission Issues
```bash
sudo chown -R ubuntu:ubuntu /home/ubuntu/voltservers
```

### Issue 4: PM2 Not Starting
```bash
pm2 delete all
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

Your application should now start successfully!