# VoltServers Ubuntu Deployment Guide

This guide provides multiple options to deploy VoltServers to your Ubuntu server at **135.148.137.158**.

## 🚀 Option 1: One-Command GitHub Deployment (Recommended)

The simplest way to deploy VoltServers directly from your GitHub repository:

```bash
./one-command-deploy.sh
```

This script will:
- Connect to your server
- Install all dependencies (Node.js, PostgreSQL, Nginx)
- Clone your latest code from GitHub
- Build and configure the application
- Set up database and start the service

**Requirements:** SSH access to your server (password authentication)

---

## 🛠️ Option 2: Manual GitHub Deployment

If you prefer step-by-step control:

### Step 1: Create and upload the deployment script
```bash
./github-deploy.sh
scp github-server-deploy.sh root@135.148.137.158:/tmp/
```

### Step 2: Run deployment on server
```bash
ssh root@135.148.137.158 'bash /tmp/github-server-deploy.sh'
```

---

## 📦 Option 3: Manual File Upload Deployment

If you prefer to upload the application files directly:

### Step 1: Create deployment package
```bash
./simple-deploy.sh
```

### Step 2: Upload files to server
```bash
scp -r deployment/ root@135.148.137.158:/tmp/
```

### Step 3: Run deployment scripts
```bash
# Setup server environment
ssh root@135.148.137.158 'bash /tmp/deployment/server-setup.sh'

# Extract and setup application
ssh root@135.148.137.158 'cd /home/ubuntu/voltservers && tar -xzf /tmp/deployment/voltservers-app.tar.gz'
ssh root@135.148.137.158 'sudo -u ubuntu bash /tmp/deployment/app-setup.sh'

# Configure Nginx
ssh root@135.148.137.158 'bash /tmp/deployment/nginx-setup.sh'
```

---

## 🌐 After Deployment

Once deployment completes, VoltServers will be available at:
- **Website:** http://135.148.137.158
- **Admin Panel:** http://135.148.137.158/admin

## 🔧 Server Management Commands

After deployment, you can manage VoltServers using these commands:

```bash
# Check application status
ssh root@135.148.137.158 'sudo -u ubuntu pm2 status'

# View application logs
ssh root@135.148.137.158 'sudo -u ubuntu pm2 logs voltservers'

# Restart application
ssh root@135.148.137.158 'sudo -u ubuntu pm2 restart voltservers'

# Stop application
ssh root@135.148.137.158 'sudo -u ubuntu pm2 stop voltservers'

# Start application
ssh root@135.148.137.158 'sudo -u ubuntu pm2 start voltservers'
```

## 🗄️ Database Information

- **Database:** PostgreSQL
- **Database Name:** voltservers
- **Username:** voltservers
- **Password:** VoltPass2025!!
- **Connection:** localhost:5432

## 🔒 Security Features

The deployment includes:
- UFW firewall configuration (ports 22, 80, 443, 8080)
- Nginx security headers
- Apache moved to port 8080 (if present)
- PM2 process management with auto-restart
- Secure database user with limited privileges

## 🏗️ Architecture

- **Frontend:** React + Vite (built to static files)
- **Backend:** Node.js + Express (port 5000)
- **Reverse Proxy:** Nginx (port 80 → 5000)
- **Database:** PostgreSQL (port 5432)
- **Process Manager:** PM2

## 📝 Troubleshooting

### Application not starting
```bash
ssh root@135.148.137.158 'sudo -u ubuntu pm2 logs voltservers'
```

### Database connection issues
```bash
ssh root@135.148.137.158 'sudo -u postgres psql -c "SELECT version();"'
```

### Nginx issues
```bash
ssh root@135.148.137.158 'nginx -t && systemctl status nginx'
```

### Check all services
```bash
ssh root@135.148.137.158 'systemctl status postgresql nginx'
```

---

## 🎯 Quick Start

For the fastest deployment, simply run:

```bash
chmod +x one-command-deploy.sh
./one-command-deploy.sh
```

The script will handle everything automatically and your VoltServers platform will be live at **http://135.148.137.158** in just a few minutes!