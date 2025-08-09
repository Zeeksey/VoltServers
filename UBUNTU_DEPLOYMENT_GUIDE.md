# Ubuntu Server Deployment Guide for VoltServers

This guide will help you deploy your VoltServers game hosting platform on a dedicated Ubuntu server.

## Prerequisites

- Ubuntu Server 20.04 LTS or later
- Root or sudo access to the server
- Domain name (optional, but recommended)
- At least 2GB RAM and 20GB storage

## Step 1: Initial Server Setup

### 1.1 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 Install Essential Packages
```bash
sudo apt install -y curl wget git ufw fail2ban nginx certbot python3-certbot-nginx
```

### 1.3 Create Application User
```bash
sudo adduser voltservers
sudo usermod -aG sudo voltservers
```

### 1.4 Configure Firewall
```bash
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

## Step 2: Install Node.js and npm

### 2.1 Install Node.js (v20.x)
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 2.2 Verify Installation
```bash
node --version
npm --version
```

## Step 3: Install and Configure PostgreSQL

### 3.1 Install PostgreSQL
```bash
sudo apt install postgresql postgresql-contrib -y
```

### 3.2 Configure PostgreSQL
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 3.3 Create Database and User
```bash
sudo -u postgres psql
```

In PostgreSQL shell:
```sql
CREATE DATABASE voltservers;
CREATE USER voltservers WITH PASSWORD 'your_secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;
ALTER USER voltservers CREATEDB;
\q
```

### 3.4 Configure PostgreSQL for Remote Connections (if needed)
Edit PostgreSQL configuration:
```bash
sudo nano /etc/postgresql/14/main/postgresql.conf
```

Find and modify:
```
listen_addresses = 'localhost'  # or '*' for all interfaces
```

Edit pg_hba.conf:
```bash
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

Add at the end:
```
local   voltservers     voltservers                     md5
host    voltservers     voltservers     127.0.0.1/32    md5
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## Step 4: Deploy Your Application

### 4.1 Clone Your Repository
```bash
su - voltservers
git clone https://github.com/yourusername/voltservers.git
cd voltservers
```

### 4.2 Install Dependencies
```bash
npm install
```

### 4.3 Create Environment File
```bash
nano .env
```

Add the following environment variables:
```env
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:your_secure_password_here@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=your_very_long_random_session_secret_here

# Optional: WHMCS Integration
WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
WHMCS_API_SECRET=your_whmcs_api_secret
WHMCS_URL=https://your-whmcs-domain.com

# Optional: SendGrid for Email
SENDGRID_API_KEY=your_sendgrid_api_key

# Optional: Wisp Integration
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key
```

### 4.4 Run Database Migrations
```bash
npm run db:push
```

### 4.5 Build the Application
```bash
npm run build
```

### 4.6 Test the Application
```bash
npm start
```

If everything works, stop the application with Ctrl+C.

## Step 5: Configure Process Manager (PM2)

### 5.1 Install PM2 Globally
```bash
sudo npm install -g pm2
```

### 5.2 Create PM2 Ecosystem File
```bash
nano ecosystem.config.js
```

Add the following:
```javascript
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
    time: true
  }]
}
```

### 5.3 Create Logs Directory
```bash
mkdir logs
```

### 5.4 Start Application with PM2
```bash
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

Copy and run the command that PM2 outputs.

## Step 6: Configure Nginx Reverse Proxy

### 6.1 Create Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/voltservers
```

Add the following configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;  # Replace with your domain

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
```

### 6.2 Enable the Site
```bash
sudo ln -s /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Step 7: SSL Certificate Setup (Optional but Recommended)

### 7.1 Install SSL Certificate with Let's Encrypt
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 7.2 Auto-renewal Setup
```bash
sudo crontab -e
```

Add this line:
```
0 12 * * * /usr/bin/certbot renew --quiet
```

## Step 8: Configure Monitoring and Logs

### 8.1 Install Log Rotation
```bash
sudo nano /etc/logrotate.d/voltservers
```

Add:
```
/home/voltservers/voltservers/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 0640 voltservers voltservers
    postrotate
        pm2 reloadLogs
    endscript
}
```

### 8.2 Monitor Application Status
```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs voltservers

# Monitor real-time
pm2 monit
```

## Step 9: Security Hardening

### 9.1 Configure Fail2Ban for Nginx
```bash
sudo nano /etc/fail2ban/jail.local
```

Add:
```ini
[nginx-http-auth]
enabled = true

[nginx-limit-req]
enabled = true
```

### 9.2 Update System Regularly
Create auto-update script:
```bash
sudo nano /etc/cron.weekly/system-update
```

Add:
```bash
#!/bin/bash
apt update && apt upgrade -y
apt autoremove -y
```

Make executable:
```bash
sudo chmod +x /etc/cron.weekly/system-update
```

## Step 10: Backup Strategy

### 10.1 Database Backup Script
```bash
nano ~/backup-db.sh
```

Add:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/voltservers/backups"
mkdir -p $BACKUP_DIR

# Database backup
pg_dump -h localhost -U voltservers -d voltservers > $BACKUP_DIR/voltservers_db_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "voltservers_db_*.sql" -mtime +7 -delete

echo "Database backup completed: voltservers_db_$DATE.sql"
```

Make executable and add to cron:
```bash
chmod +x ~/backup-db.sh
crontab -e
```

Add daily backup at 2 AM:
```
0 2 * * * /home/voltservers/backup-db.sh
```

## Step 11: Deployment Automation

### 11.1 Create Deployment Script
```bash
nano ~/deploy.sh
```

Add:
```bash
#!/bin/bash
cd /home/voltservers/voltservers

echo "Pulling latest changes..."
git pull origin main

echo "Installing dependencies..."
npm install

echo "Building application..."
npm run build

echo "Running database migrations..."
npm run db:push

echo "Restarting application..."
pm2 restart voltservers

echo "Deployment completed successfully!"
```

Make executable:
```bash
chmod +x ~/deploy.sh
```

## Troubleshooting

### Common Issues and Solutions

1. **Port 5000 already in use**
   ```bash
   sudo lsof -i :5000
   sudo kill -9 <PID>
   ```

2. **PostgreSQL connection issues**
   ```bash
   sudo systemctl status postgresql
   sudo -u postgres psql -c "SELECT version();"
   ```

3. **PM2 not starting**
   ```bash
   pm2 logs voltservers --lines 50
   pm2 delete voltservers
   pm2 start ecosystem.config.js --env production
   ```

4. **Nginx configuration errors**
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   ```

5. **SSL certificate issues**
   ```bash
   sudo certbot certificates
   sudo certbot renew --dry-run
   ```

## Monitoring Your Application

### Performance Monitoring
```bash
# System resources
htop

# Disk usage
df -h

# Memory usage
free -h

# PM2 monitoring
pm2 monit

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Application logs
pm2 logs voltservers --lines 100
```

## Updates and Maintenance

To update your application:
```bash
cd /home/voltservers/voltservers
./deploy.sh
```

To update Node.js dependencies:
```bash
npm audit
npm update
npm run build
pm2 restart voltservers
```

## Domain Configuration

Once your server is running, point your domain's A record to your server's IP address:
- `A` record: `@` → `your_server_ip`
- `A` record: `www` → `your_server_ip`

## Final Security Checklist

- [ ] Firewall configured (UFW)
- [ ] SSH keys configured (disable password auth)
- [ ] Fail2Ban configured
- [ ] SSL certificate installed
- [ ] Database secured with strong passwords
- [ ] Environment variables secured
- [ ] Regular backups configured
- [ ] Log rotation configured
- [ ] Monitoring in place

Your VoltServers platform should now be fully deployed and running on your Ubuntu server!

## Getting Help

If you encounter issues during deployment:
1. Check the application logs: `pm2 logs voltservers`
2. Check system logs: `sudo journalctl -u nginx -f`
3. Verify all services are running: `pm2 status` and `sudo systemctl status nginx postgresql`
4. Test database connection: `npm run db:push`

For additional support, refer to the other deployment guides in your project directory.