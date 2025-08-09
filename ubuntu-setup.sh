#!/bin/bash

# VoltServers Ubuntu Server Setup Script
# This script automates the deployment process for Ubuntu servers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Function to check Ubuntu version
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu. Your system may not be compatible."
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to update system
update_system() {
    print_status "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    print_success "System updated successfully"
}

# Function to install essential packages
install_essentials() {
    print_status "Installing essential packages..."
    sudo apt install -y curl wget git ufw fail2ban nginx certbot python3-certbot-nginx htop
    print_success "Essential packages installed"
}

# Function to configure firewall
setup_firewall() {
    print_status "Configuring firewall..."
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw --force enable
    print_success "Firewall configured"
}

# Function to install Node.js
install_nodejs() {
    print_status "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verify installation
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_success "Node.js $NODE_VERSION and npm $NPM_VERSION installed"
}

# Function to install PostgreSQL
install_postgresql() {
    print_status "Installing PostgreSQL..."
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    print_success "PostgreSQL installed and started"
}

# Function to configure PostgreSQL
setup_database() {
    print_status "Setting up database..."
    
    echo "Please enter a secure password for the database user:"
    read -s DB_PASSWORD
    echo
    
    # Create database and user
    sudo -u postgres psql -c "CREATE DATABASE voltservers;" || print_warning "Database might already exist"
    sudo -u postgres psql -c "DROP USER IF EXISTS voltservers;"
    sudo -u postgres psql -c "CREATE USER voltservers WITH PASSWORD '$DB_PASSWORD';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE voltservers TO voltservers;"
    sudo -u postgres psql -c "ALTER USER voltservers CREATEDB;"
    
    print_success "Database configured"
    
    # Store database URL for later use
    export DATABASE_URL="postgresql://voltservers:$DB_PASSWORD@localhost:5432/voltservers"
}

# Function to install PM2
install_pm2() {
    print_status "Installing PM2 process manager..."
    sudo npm install -g pm2
    print_success "PM2 installed"
}

# Function to setup application
setup_application() {
    print_status "Setting up application..."
    
    # Get repository URL
    echo "Please enter your GitHub repository URL (e.g., https://github.com/username/voltservers):"
    read REPO_URL
    
    # Clone repository
    if [ -d "voltservers" ]; then
        print_warning "Directory 'voltservers' already exists. Removing..."
        rm -rf voltservers
    fi
    
    git clone "$REPO_URL" voltservers
    cd voltservers
    
    # Install dependencies
    print_status "Installing dependencies..."
    npm install
    
    # Create environment file
    print_status "Creating environment configuration..."
    cat > .env << EOF
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
PORT=5000
SESSION_SECRET=$(openssl rand -base64 32)

# Optional: Add your API keys below
# WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
# WHMCS_API_SECRET=your_whmcs_api_secret
# WHMCS_URL=https://your-whmcs-domain.com
# SENDGRID_API_KEY=your_sendgrid_api_key
# WISP_API_URL=https://game.voltservers.com
# WISP_API_KEY=your_wisp_api_key
EOF
    
    # Run database migrations
    print_status "Running database migrations..."
    npm run db:push
    
    # Build application
    print_status "Building application..."
    npm run build
    
    print_success "Application setup complete"
}

# Function to configure PM2
setup_pm2() {
    print_status "Configuring PM2..."
    
    # Create logs directory
    mkdir -p logs
    
    # Create PM2 ecosystem file
    cat > ecosystem.config.js << 'EOF'
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
EOF
    
    # Start application
    pm2 start ecosystem.config.js --env production
    pm2 save
    pm2 startup | tail -n 1 | bash
    
    print_success "PM2 configured and application started"
}

# Function to configure Nginx
setup_nginx() {
    print_status "Configuring Nginx..."
    
    echo "Enter your domain name (or press Enter to use server IP):"
    read DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        DOMAIN=$(curl -s http://checkip.amazonaws.com)
        print_warning "No domain provided, using server IP: $DOMAIN"
    fi
    
    # Create Nginx configuration
    sudo tee /etc/nginx/sites-available/voltservers > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

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
    }
}
EOF
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/voltservers /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test and restart Nginx
    sudo nginx -t
    sudo systemctl restart nginx
    
    print_success "Nginx configured for domain: $DOMAIN"
    
    # Offer SSL setup
    if [ "$DOMAIN" != "$(curl -s http://checkip.amazonaws.com)" ]; then
        echo "Would you like to set up SSL certificate with Let's Encrypt? (y/N):"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_ssl "$DOMAIN"
        fi
    fi
}

# Function to setup SSL
setup_ssl() {
    local domain=$1
    print_status "Setting up SSL certificate..."
    
    echo "Enter your email address for Let's Encrypt:"
    read EMAIL
    
    sudo certbot --nginx -d "$domain" -d "www.$domain" --email "$EMAIL" --agree-tos --no-eff-email
    
    # Setup auto-renewal
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    
    print_success "SSL certificate configured"
}

# Function to setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring and backups..."
    
    # Create backup script
    cat > ~/backup-db.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/backups"
mkdir -p $BACKUP_DIR

# Database backup
pg_dump -h localhost -U voltservers -d voltservers > $BACKUP_DIR/voltservers_db_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "voltservers_db_*.sql" -mtime +7 -delete

echo "Database backup completed: voltservers_db_$DATE.sql"
EOF
    
    chmod +x ~/backup-db.sh
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "0 2 * * * $HOME/backup-db.sh") | crontab -
    
    # Create deployment script
    cat > ~/deploy.sh << 'EOF'
#!/bin/bash
cd voltservers

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
EOF
    
    chmod +x ~/deploy.sh
    
    print_success "Monitoring and backup scripts created"
}

# Function to show final status
show_status() {
    print_status "Deployment completed! Here's your system status:"
    echo
    echo "🚀 Application Status:"
    pm2 status
    echo
    echo "🌐 Nginx Status:"
    sudo systemctl status nginx --no-pager -l
    echo
    echo "🗄️ PostgreSQL Status:"
    sudo systemctl status postgresql --no-pager -l
    echo
    echo "📊 Server Resources:"
    echo "Memory Usage:"
    free -h
    echo "Disk Usage:"
    df -h
    echo
    echo "🔗 Your application should be available at:"
    echo "   http://$(curl -s http://checkip.amazonaws.com)"
    if [ -n "$DOMAIN" ] && [ "$DOMAIN" != "$(curl -s http://checkip.amazonaws.com)" ]; then
        echo "   http://$DOMAIN"
    fi
    echo
    echo "📋 Useful commands:"
    echo "   View logs: pm2 logs voltservers"
    echo "   Restart app: pm2 restart voltservers"
    echo "   Monitor: pm2 monit"
    echo "   Deploy updates: ~/deploy.sh"
    echo "   Backup database: ~/backup-db.sh"
    echo
    print_success "VoltServers is now running on your Ubuntu server!"
}

# Main execution
main() {
    clear
    echo "=================================================="
    echo "🎮 VoltServers Ubuntu Deployment Script"
    echo "=================================================="
    echo
    
    check_root
    check_ubuntu
    
    print_status "Starting VoltServers deployment..."
    
    update_system
    install_essentials
    setup_firewall
    install_nodejs
    install_postgresql
    setup_database
    install_pm2
    setup_application
    setup_pm2
    setup_nginx
    setup_monitoring
    
    echo
    print_success "🎉 Deployment completed successfully!"
    echo
    show_status
}

# Run main function
main "$@"