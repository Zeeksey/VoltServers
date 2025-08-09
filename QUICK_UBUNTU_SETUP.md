# Quick Ubuntu Server Setup for VoltServers

## Step 1: Connect to Your Ubuntu Server

SSH into your Ubuntu server:
```bash
ssh root@your-server-ip
# or if using a user account:
ssh username@your-server-ip
```

## Step 2: Download and Run the Setup Script

Run this single command to deploy your entire VoltServers platform:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/voltservers/main/ubuntu-setup.sh -o ubuntu-setup.sh && chmod +x ubuntu-setup.sh && ./ubuntu-setup.sh
```

**OR** if you prefer to download first and review:

```bash
wget https://raw.githubusercontent.com/yourusername/voltservers/main/ubuntu-setup.sh
chmod +x ubuntu-setup.sh
./ubuntu-setup.sh
```

## What the Script Will Do:

1. **Update your Ubuntu system** - Latest packages and security updates
2. **Install all required software** - Node.js, PostgreSQL, Nginx, SSL certificates
3. **Configure your database** - Secure PostgreSQL setup with your custom password
4. **Clone and build your app** - Download your VoltServers code and build it
5. **Set up process management** - PM2 for keeping your app running 24/7
6. **Configure web server** - Nginx reverse proxy for professional hosting
7. **Add SSL certificate** - Free Let's Encrypt SSL for HTTPS
8. **Set up monitoring** - Logs, backups, and system monitoring

## During Setup, You'll Be Asked:

- Database password (choose something secure)
- Your GitHub repository URL
- Your domain name (optional - can use server IP)
- Email for SSL certificate
- Whether to set up SSL (recommended if you have a domain)

## After Setup Completes:

Your VoltServers platform will be live at:
- `http://your-server-ip` 
- `https://your-domain.com` (if you configured a domain)

## Managing Your Server:

```bash
# View app status
pm2 status

# View app logs  
pm2 logs voltservers

# Restart app
pm2 restart voltservers

# Monitor system resources
pm2 monit

# Deploy updates
~/deploy.sh

# Backup database
~/backup-db.sh
```

## Required Server Specs:

- **Minimum**: 2GB RAM, 20GB storage, Ubuntu 20.04+
- **Recommended**: 4GB RAM, 50GB storage for production use

That's it! Your VoltServers gaming platform will be fully deployed and ready for users.