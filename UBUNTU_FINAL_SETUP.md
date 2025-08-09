# VoltServers Ubuntu Final Setup Guide

## Quick Fix Commands

Run these commands on your Ubuntu server to fix the .env and DATABASE_URL issues:

```bash
cd /home/ubuntu/voltservers

# Download and run the complete fix
wget https://raw.githubusercontent.com/yourusername/voltservers/main/fix-env-and-start.sh
chmod +x fix-env-and-start.sh
./fix-env-and-start.sh
```

## Manual Setup (if script fails)

```bash
cd /home/ubuntu/voltservers

# 1. Stop PM2
pm2 delete all

# 2. Get database password
DB_PASSWORD=$(cat ~/.voltservers_db_password)
echo "Database password: $DB_PASSWORD"

# 3. Create correct .env file
cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=voltservers-production-secret
EOF

# 4. Verify .env contents
cat .env

# 5. Test database connection
PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT version();"

# 6. Build application
npm run build

# 7. Test manual startup
export NODE_ENV=production
export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
export PORT=5000
export SESSION_SECRET="test-secret"

# Test for 10 seconds
timeout 10 node dist/index.js

# 8. Start with PM2
pm2 start dist/index.js \
    --name voltservers \
    --env NODE_ENV=production \
    --env DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers" \
    --env PORT=5000 \
    --env SESSION_SECRET="pm2-secret"

pm2 save

# 9. Test
curl -I http://localhost:5000
```

## Troubleshooting

### Check logs
```bash
pm2 logs voltservers --lines 20
```

### Check what's using port 5000
```bash
sudo netstat -tlnp | grep :5000
```

### Restart everything
```bash
pm2 delete all
sudo systemctl restart postgresql
sudo systemctl restart nginx
# Then run setup again
```

## Expected Results

After successful setup:
- PM2 shows "online" status
- `curl http://localhost:5000` returns HTTP 200
- Your site works at http://135.148.137.158/