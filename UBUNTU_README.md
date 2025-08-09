# VoltServers - Ubuntu Server Deployment

Complete deployment solution for Ubuntu servers (20.04, 22.04, 24.04 LTS).

## Quick Start

**One-command deployment:**
```bash
wget https://raw.githubusercontent.com/yourusername/voltservers/main/ubuntu-deploy-latest.sh
chmod +x ubuntu-deploy-latest.sh
./ubuntu-deploy-latest.sh
```

## What Gets Installed

- **System**: Ubuntu updates, essential packages, firewall configuration
- **Runtime**: Node.js 20.x, PostgreSQL database, PM2 process manager
- **Web Server**: Nginx reverse proxy with SSL support
- **Security**: Firewall (UFW), Fail2ban, automatic security updates
- **Monitoring**: Application logs, database backups, system monitoring
- **Management**: Deployment scripts, backup automation, log rotation

## Server Requirements

- **OS**: Ubuntu 20.04+ LTS
- **RAM**: Minimum 2GB (4GB recommended)
- **Storage**: Minimum 20GB (50GB recommended)
- **Access**: SSH with sudo privileges

## Post-Deployment

Your VoltServers platform will be available at:
- `http://your-server-ip` (HTTP)
- `https://your-domain.com` (HTTPS if SSL configured)

## Management Commands

```bash
# Application management
pm2 status                    # Check app status
pm2 logs voltservers         # View logs
pm2 restart voltservers      # Restart app
pm2 monit                    # Monitor resources

# Deployment and maintenance
~/deploy-voltservers.sh      # Deploy updates
~/backup-voltservers.sh      # Backup database
sudo systemctl status nginx postgresql  # Check services
```

## Included Files

- `ubuntu-deploy-latest.sh` - Complete deployment script
- `UBUNTU_DEPLOYMENT_GUIDE.md` - Detailed manual setup guide
- `UBUNTU_TROUBLESHOOTING.md` - Common issues and solutions
- `ecosystem.config.js` - PM2 configuration template

## Support

For deployment issues, check the troubleshooting guide or review the detailed deployment guide for manual setup steps.