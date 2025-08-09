#!/bin/bash

# VoltServers - Complete Ubuntu Deployment Script
# Compatible with Ubuntu 20.04, 22.04, 24.04 LTS
# Handles all common deployment issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# System information
UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "Unknown")
NODE_VERSION="20.x"
APP_USER="ubuntu"
APP_DIR="/home/$APP_USER/voltservers"

print_status "VoltServers Deployment Script - Ubuntu $UBUNTU_VERSION"

# Check if running as correct user
if [[ $EUID -eq 0 ]]; then
    print_error "Do not run as root. Run as ubuntu user with sudo privileges."
    exit 1
fi

# Update system packages
update_system() {
    print_status "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    print_success "System updated"
}

# Install essential packages
install_essentials() {
    print_status "Installing essential packages..."
    sudo apt install -y \
        curl \
        wget \
        git \
        ufw \
        fail2ban \
        nginx \
        certbot \
        python3-certbot-nginx \
        htop \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        build-essential
    print_success "Essential packages installed"
}

# Configure firewall
setup_firewall() {
    print_status "Configuring UFW firewall..."
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 5000/tcp
    sudo ufw --force enable
    print_success "Firewall configured"
}

# Install Node.js
install_nodejs() {
    print_status "Installing Node.js $NODE_VERSION..."
    
    # Remove any existing Node.js installations
    sudo apt remove -y nodejs npm 2>/dev/null || true
    
    # Install Node.js from NodeSource
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verify installation
    NODE_VER=$(node --version)
    NPM_VER=$(npm --version)
    print_success "Node.js $NODE_VER and npm $NPM_VER installed"
    
    # Update npm to latest
    sudo npm install -g npm@latest
}

# Install PostgreSQL
install_postgresql() {
    print_status "Installing PostgreSQL..."
    
    # Install PostgreSQL
    sudo apt install -y postgresql postgresql-contrib
    
    # Start and enable PostgreSQL
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    
    # Configure PostgreSQL
    PG_VERSION=$(sudo -u postgres psql -t -c "SELECT version();" | grep -oP '\d+\.\d+' | head -1)
    print_success "PostgreSQL $PG_VERSION installed and running"
}

# Setup database
setup_database() {
    print_status "Configuring database..."
    
    # Get database password
    while true; do
        echo -n "Enter a secure password for the 'voltservers' database user: "
        read -s DB_PASSWORD
        echo
        echo -n "Confirm password: "
        read -s DB_PASSWORD_CONFIRM
        echo
        
        if [[ "$DB_PASSWORD" == "$DB_PASSWORD_CONFIRM" ]]; then
            if [[ ${#DB_PASSWORD} -lt 8 ]]; then
                print_warning "Password should be at least 8 characters long"
                continue
            fi
            break
        else
            print_warning "Passwords don't match. Please try again."
        fi
    done
    
    # Setup database and user
    sudo -u postgres psql << EOF
DROP DATABASE IF EXISTS voltservers;
DROP USER IF EXISTS voltservers;
CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';
CREATE DATABASE voltservers OWNER voltservers;
GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;
ALTER USER voltservers CREATEDB;
\q
EOF
    
    # Test connection
    if PGPASSWORD="$DB_PASSWORD" psql -h localhost -U voltservers -d voltservers -c "SELECT 1;" > /dev/null 2>&1; then
        print_success "Database configured successfully"
        echo "$DB_PASSWORD" > ~/.voltservers_db_password
        chmod 600 ~/.voltservers_db_password
    else
        print_error "Database connection test failed"
        exit 1
    fi
}

# Install PM2
install_pm2() {
    print_status "Installing PM2 process manager..."
    sudo npm install -g pm2@latest
    print_success "PM2 installed"
}

# Clone and setup application
setup_application() {
    print_status "Setting up VoltServers application..."
    
    # Get repository URL
    echo "Enter your VoltServers GitHub repository URL:"
    echo "(Example: https://github.com/username/voltservers)"
    read REPO_URL
    
    # Validate URL
    if [[ ! $REPO_URL =~ ^https://github\.com/.+/.+$ ]]; then
        print_error "Invalid GitHub URL format"
        exit 1
    fi
    
    # Remove existing directory
    if [[ -d "$APP_DIR" ]]; then
        print_warning "Removing existing voltservers directory..."
        rm -rf "$APP_DIR"
    fi
    
    # Clone repository
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
    
    # Get database password
    DB_PASSWORD=$(cat ~/.voltservers_db_password)
    
    # Create environment file
    print_status "Creating production environment configuration..."
    cat > .env << EOF
NODE_ENV=production
DATABASE_URL=postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)

# Optional: Uncomment and add your API keys
# WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
# WHMCS_API_SECRET=your_whmcs_api_secret
# WHMCS_URL=https://your-whmcs-domain.com
# SENDGRID_API_KEY=your_sendgrid_api_key
# WISP_API_URL=https://game.voltservers.com
# WISP_API_KEY=your_wisp_api_key
EOF
    
    # Create PM2 ecosystem file
    print_status "Creating PM2 configuration..."
    cat > ecosystem.config.cjs << 'EOF'
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
    time: true
  }]
};
EOF
    
    # Create logs directory
    mkdir -p logs
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install --production=false
    
    # Build application
    print_status "Building application..."
    npm run build
    
    # Run database migrations
    print_status "Setting up database schema..."
    npm run db:push
    
    print_success "Application setup completed"
}

# Start application with PM2
start_application() {
    print_status "Starting VoltServers application..."
    
    cd "$APP_DIR"
    
    # Stop any existing PM2 processes
    pm2 delete all 2>/dev/null || true
    
    # Start application
    pm2 start ecosystem.config.cjs --env production
    pm2 save
    
    # Setup PM2 startup
    pm2 startup systemd -u $APP_USER --hp /home/$APP_USER | tail -1 | bash
    
    print_success "Application started with PM2"
}

# Configure Nginx
setup_nginx() {
    print_status "Configuring Nginx reverse proxy..."
    
    # Get domain or use IP
    SERVER_IP=$(curl -s http://checkip.amazonaws.com || echo "localhost")
    echo "Enter your domain name (or press Enter to use server IP: $SERVER_IP):"
    read DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        DOMAIN="$SERVER_IP"
        print_warning "Using server IP: $DOMAIN"
    fi
    
    # Create Nginx configuration
    sudo tee /etc/nginx/sites-available/voltservers > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

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
        proxy_read_timeout 86400;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        client_max_body_size 50M;
    }
    
    # Static file caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
    
    # Enable site and test configuration
    sudo ln -sf /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    if sudo nginx -t; then
        sudo systemctl restart nginx
        sudo systemctl enable nginx
        print_success "Nginx configured for domain: $DOMAIN"
        
        # Offer SSL setup
        if [[ "$DOMAIN" != "$SERVER_IP" ]] && [[ "$DOMAIN" != "localhost" ]]; then
            echo "Would you like to set up SSL certificate with Let's Encrypt? (y/N):"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                setup_ssl "$DOMAIN"
            fi
        fi
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
}

# Setup SSL certificate
setup_ssl() {
    local domain=$1
    print_status "Setting up SSL certificate for $domain..."
    
    echo "Enter your email address for Let's Encrypt notifications:"
    read EMAIL
    
    if sudo certbot --nginx -d "$domain" --email "$EMAIL" --agree-tos --no-eff-email --non-interactive; then
        # Setup auto-renewal
        (crontab -l 2>/dev/null || echo "") | grep -v certbot | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | crontab -
        print_success "SSL certificate configured and auto-renewal setup"
    else
        print_warning "SSL certificate setup failed, but application will work with HTTP"
    fi
}

# Setup monitoring and backups
setup_monitoring() {
    print_status "Setting up monitoring and backup scripts..."
    
    # Database backup script
    cat > ~/backup-voltservers.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/backups/voltservers"
mkdir -p "$BACKUP_DIR"

# Database backup
DB_PASSWORD=$(cat ~/.voltservers_db_password)
PGPASSWORD="$DB_PASSWORD" pg_dump -h localhost -U voltservers -d voltservers > "$BACKUP_DIR/voltservers_db_$DATE.sql"

# Application backup
tar -czf "$BACKUP_DIR/voltservers_app_$DATE.tar.gz" -C /home/ubuntu voltservers --exclude=node_modules --exclude=logs --exclude=.git

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "voltservers_*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "voltservers_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF
    
    chmod +x ~/backup-voltservers.sh
    
    # Deployment script
    cat > ~/deploy-voltservers.sh << 'EOF'
#!/bin/bash
cd /home/ubuntu/voltservers

echo "Creating backup before deployment..."
~/backup-voltservers.sh

echo "Pulling latest changes..."
git pull origin main

echo "Installing/updating dependencies..."
npm install

echo "Building application..."
npm run build

echo "Running database migrations..."
npm run db:push

echo "Restarting application..."
pm2 restart voltservers

echo "Deployment completed successfully!"
pm2 status
EOF
    
    chmod +x ~/deploy-voltservers.sh
    
    # Add backup to crontab
    (crontab -l 2>/dev/null || echo "") | grep -v backup-voltservers | { cat; echo "0 2 * * * $HOME/backup-voltservers.sh"; } | crontab -
    
    # Log rotation
    sudo tee /etc/logrotate.d/voltservers > /dev/null << EOF
$APP_DIR/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0640 $APP_USER $APP_USER
    postrotate
        sudo -u $APP_USER pm2 reloadLogs
    endscript
}
EOF
    
    print_success "Monitoring and backup setup completed"
}

# Security hardening
setup_security() {
    print_status "Applying security hardening..."
    
    # Configure fail2ban
    sudo tee /etc/fail2ban/jail.local > /dev/null << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true

[nginx-http-auth]
enabled = true

[nginx-limit-req]
enabled = true
EOF
    
    sudo systemctl restart fail2ban
    sudo systemctl enable fail2ban
    
    # Setup automatic security updates
    sudo apt install -y unattended-upgrades
    sudo dpkg-reconfigure -plow unattended-upgrades
    
    print_success "Security hardening completed"
}

# Display final status and information
show_final_status() {
    print_success "VoltServers deployment completed successfully!"
    
    echo ""
    echo "========================================="
    echo "           DEPLOYMENT SUMMARY"
    echo "========================================="
    echo ""
    
    # System information
    echo "System Information:"
    echo "  Ubuntu Version: $UBUNTU_VERSION"
    echo "  Node.js Version: $(node --version)"
    echo "  PostgreSQL Version: $(sudo -u postgres psql -t -c "SELECT version();" | grep -oP '\d+\.\d+')"
    echo ""
    
    # Application status
    echo "Application Status:"
    pm2 status
    echo ""
    
    # Access information
    SERVER_IP=$(curl -s http://checkip.amazonaws.com || echo "localhost")
    echo "Access URLs:"
    echo "  HTTP:  http://$SERVER_IP"
    if [[ -f /etc/letsencrypt/live/*/cert.pem ]]; then
        DOMAIN=$(ls /etc/letsencrypt/live/ | head -1)
        echo "  HTTPS: https://$DOMAIN"
    fi
    echo ""
    
    # Management commands
    echo "Management Commands:"
    echo "  View logs:        pm2 logs voltservers"
    echo "  Restart app:      pm2 restart voltservers"
    echo "  Monitor app:      pm2 monit"
    echo "  Deploy updates:   ~/deploy-voltservers.sh"
    echo "  Backup data:      ~/backup-voltservers.sh"
    echo "  System status:    sudo systemctl status nginx postgresql"
    echo ""
    
    # Files and directories
    echo "Important Files:"
    echo "  App directory:    $APP_DIR"
    echo "  Environment:      $APP_DIR/.env"
    echo "  PM2 config:       $APP_DIR/ecosystem.config.cjs"
    echo "  Nginx config:     /etc/nginx/sites-available/voltservers"
    echo "  Backup scripts:   ~/backup-voltservers.sh"
    echo ""
    
    echo "Your VoltServers platform is now live and ready for users!"
    echo ""
}

# Main execution flow
main() {
    clear
    echo "========================================="
    echo "   VoltServers Ubuntu Deployment"
    echo "   Compatible with Ubuntu 20.04+"
    echo "========================================="
    echo ""
    
    update_system
    install_essentials
    setup_firewall
    install_nodejs
    install_postgresql
    setup_database
    install_pm2
    setup_application
    start_application
    setup_nginx
    setup_monitoring
    setup_security
    show_final_status
}

# Run deployment
main "$@"