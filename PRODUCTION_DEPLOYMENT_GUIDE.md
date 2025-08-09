# VoltServers - Production Deployment Guide

This comprehensive guide covers deploying your VoltServers game hosting platform to production environments.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Variables](#environment-variables)
3. [Database Setup](#database-setup)
4. [Deployment Options](#deployment-options)
5. [Post-Deployment Configuration](#post-deployment-configuration)
6. [Monitoring & Maintenance](#monitoring--maintenance)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Services
- **PostgreSQL Database** (Neon, Supabase, Railway, or self-hosted)
- **WHMCS Installation** (for billing and client management)
- **Node.js Hosting** (Railway, Render, Vercel, or VPS)
- **Domain Name** (recommended for production)

### System Requirements
- Node.js 18+ 
- PostgreSQL 14+
- 1GB+ RAM (recommended)
- SSL Certificate (handled by most platforms)

## Environment Variables

Create a `.env` file with these required variables:

```env
# Database Configuration
DATABASE_URL=postgresql://username:password@host:port/database_name

# WHMCS Integration (Required for client portal functionality)
WHMCS_API_URL=https://yourdomain.com/billing
WHMCS_API_IDENTIFIER=your_api_identifier
WHMCS_API_SECRET=your_api_secret

# Wisp.gg Integration (Optional - for server management)
WISP_API_URL=https://game.yourdomain.com
WISP_API_KEY=your_wisp_api_key

# Application Configuration
NODE_ENV=production
PORT=5000

# Session Configuration (Generate secure random strings)
SESSION_SECRET=your_very_long_random_secret_string_here

# Email Configuration (Optional - for contact forms)
SENDGRID_API_KEY=your_sendgrid_key
SUPPORT_EMAIL=support@yourdomain.com

# Security
CORS_ORIGIN=https://yourdomain.com
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

### How to Get Required Keys

#### WHMCS API Credentials
1. Login to your WHMCS admin panel
2. Go to **System Settings** → **API Credentials**
3. Create new API credentials with these permissions:
   - GetClients, GetClientsDetails, UpdateClient
   - GetTickets, GetTicket, AddTicketReply, OpenTicket
   - GetInvoices, GetProducts, GetSupportDepartments
4. Use the generated identifier and secret

#### Wisp.gg API Key (Optional)
1. Login to your Wisp.gg panel
2. Go to **Account** → **API Keys**
3. Create new API key with appropriate permissions
4. Copy the generated key

## Database Setup

### Option 1: Neon (Recommended)
```bash
# 1. Sign up at neon.tech
# 2. Create new project
# 3. Copy connection string
# 4. Run migrations
npm run db:push
```

### Option 2: Railway PostgreSQL
```bash
# 1. Create Railway account
# 2. Add PostgreSQL service
# 3. Copy DATABASE_URL from variables
# 4. Run migrations
npm run db:push
```

### Option 3: Self-Hosted PostgreSQL
```sql
-- Create database and user
CREATE DATABASE voltservers;
CREATE USER voltservers_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers_user;

-- Connection string format:
-- postgresql://voltservers_user:secure_password@localhost:5432/voltservers
```

## Deployment Options

### Option 1: Railway (Recommended)

**Why Railway?**
- Built-in PostgreSQL
- Automatic deployments from Git
- Environment variable management
- Free tier available
- SSL certificates included

**Steps:**
1. Fork this repository to your GitHub
2. Sign up at [railway.app](https://railway.app)
3. Create new project from GitHub repo
4. Add PostgreSQL service
5. Set environment variables in Railway dashboard
6. Deploy automatically triggers

**Railway Configuration:**
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm run build && npm start",
    "healthcheckPath": "/api/health"
  }
}
```

### Option 2: Render

**Steps:**
1. Sign up at [render.com](https://render.com)
2. Create new Web Service from Git
3. Configure build settings:
   - **Build Command:** `npm install && npm run build`
   - **Start Command:** `npm start`
4. Add PostgreSQL service
5. Set environment variables
6. Deploy

**Render Configuration:**
```yaml
# render.yaml
services:
  - type: web
    name: voltservers
    env: node
    buildCommand: npm install && npm run build
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        fromDatabase:
          name: voltservers-db
          property: connectionString

databases:
  - name: voltservers-db
    databaseName: voltservers
    user: voltservers
```

### Option 3: Vercel (Static + Serverless)

**Note:** Requires modifications for serverless functions

```json
{
  "version": 2,
  "builds": [
    {
      "src": "client/dist/**",
      "use": "@vercel/static"
    },
    {
      "src": "server/index.ts",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/server/index.ts"
    },
    {
      "src": "/(.*)",
      "dest": "/client/dist/$1"
    }
  ]
}
```

### Option 4: VPS Deployment

**Requirements:**
- Ubuntu 20.04+ or CentOS 8+
- 2GB+ RAM
- Node.js 18+
- Nginx (reverse proxy)
- PostgreSQL
- PM2 (process management)

**Setup Script:**
```bash
#!/bin/bash
# VPS Setup Script

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Clone and setup application
git clone https://github.com/yourusername/voltservers.git
cd voltservers
npm install
npm run build

# Setup database
sudo -u postgres createdb voltservers
sudo -u postgres createuser --interactive voltservers_user
npm run db:push

# Setup PM2
pm2 start npm --name "voltservers" -- start
pm2 startup
pm2 save

# Configure Nginx
sudo tee /etc/nginx/sites-available/voltservers << EOF
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Setup SSL with Certbot
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## Post-Deployment Configuration

### 1. Database Initialization
```bash
# Run database migrations
npm run db:push

# Verify database connection
curl https://yourdomain.com/api/health
```

### 2. WHMCS Integration Test
```javascript
// Test WHMCS connection
fetch('https://yourdomain.com/api/whmcs/test')
  .then(res => res.json())
  .then(data => console.log('WHMCS Status:', data));
```

### 3. Admin Panel Setup
1. Visit `https://yourdomain.com/admin/login`
2. Default credentials: `admin` / `admin123`
3. **IMPORTANT:** Change default password immediately
4. Configure site branding, games, and pricing

### 4. DNS Configuration
```
# Add these DNS records:
A     @           your.server.ip
A     www         your.server.ip
CNAME api         yourdomain.com
```

### 5. SSL Certificate
Most platforms handle SSL automatically. For VPS:
```bash
# Let's Encrypt with Certbot
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## Monitoring & Maintenance

### Health Checks
```bash
# Application health
curl https://yourdomain.com/api/health

# Database health
curl https://yourdomain.com/api/status

# WHMCS integration
curl https://yourdomain.com/api/whmcs/test
```

### Log Monitoring
```bash
# PM2 logs (VPS)
pm2 logs voltservers

# Railway logs
railway logs

# Render logs
# Available in Render dashboard
```

### Backup Strategy
```bash
# Database backup (daily recommended)
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# Application backup
git push origin main  # Code is backed up in repository
```

### Updates
```bash
# Pull latest changes
git pull origin main

# Install dependencies
npm install

# Rebuild application
npm run build

# Restart application
pm2 restart voltservers  # VPS
# or redeploy on platform
```

## Troubleshooting

### Common Issues

#### 1. "WHMCS integration not configured"
- Verify WHMCS API credentials in environment variables
- Check WHMCS API permissions
- Test connection: `curl https://yourdomain.com/api/whmcs/test`

#### 2. Database Connection Failed
- Verify DATABASE_URL format
- Check database credentials
- Ensure database exists and is accessible
- Run: `npm run db:push`

#### 3. Build Failures
```bash
# Clear node modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear build cache
rm -rf client/dist server/dist
npm run build
```

#### 4. 502 Bad Gateway (Nginx)
```bash
# Check application status
pm2 status
pm2 logs voltservers

# Check Nginx configuration
sudo nginx -t
sudo systemctl status nginx
```

#### 5. Memory Issues
```bash
# Check memory usage
free -h
pm2 monit

# Restart application
pm2 restart voltservers
```

### Environment-Specific Issues

#### Railway
- Check build logs in dashboard
- Verify environment variables
- Ensure PostgreSQL service is connected

#### Render
- Check deployment logs
- Verify build/start commands
- Check resource limits

#### Vercel
- Function timeout (10s limit on hobby plan)
- Cold starts may cause delays
- Large bundle sizes may cause issues

### Performance Optimization

#### 1. Enable Gzip Compression
```nginx
# Nginx configuration
gzip on;
gzip_vary on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

#### 2. Database Optimization
```sql
-- Add database indexes for frequently queried fields
CREATE INDEX idx_games_slug ON games(slug);
CREATE INDEX idx_blog_slug ON blog(slug);
CREATE INDEX idx_demo_servers_game_type ON demo_servers(game_type);
```

#### 3. Static Asset Optimization
```bash
# Enable static file caching
# Already configured in Vite build process
```

## Security Checklist

### Production Security
- [ ] Change default admin credentials
- [ ] Use strong SESSION_SECRET
- [ ] Enable HTTPS everywhere
- [ ] Set secure CORS_ORIGIN
- [ ] Use environment variables for all secrets
- [ ] Enable rate limiting
- [ ] Regular security updates
- [ ] Database access restrictions
- [ ] Monitor application logs

### WHMCS Security
- [ ] API credentials have minimal required permissions
- [ ] API access restricted to your domain
- [ ] Regular credential rotation
- [ ] Monitor API usage logs

## Support

For deployment issues:
1. Check this guide first
2. Review application logs
3. Test individual components (database, WHMCS, etc.)
4. Check platform-specific documentation

The application includes comprehensive error handling and logging to help diagnose issues quickly.

---

**Last Updated:** August 2025
**Version:** 2.0.0