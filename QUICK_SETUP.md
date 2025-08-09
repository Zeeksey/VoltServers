# VoltServers - Quick Setup Guide

Get your VoltServers platform running in under 10 minutes!

## 🚀 Development Setup (5 minutes)

### 1. Clone & Install
```bash
git clone https://github.com/yourusername/voltservers.git
cd voltservers
npm install
```

### 2. Environment Setup
```bash
cp .env.example .env
# Edit .env with your database URL (minimum required)
```

### 3. Database Setup
```bash
# Quick setup with Neon (free)
# 1. Go to neon.tech and create free account
# 2. Create new project
# 3. Copy connection string to .env DATABASE_URL
npm run db:push
```

### 4. Start Development
```bash
npm run dev
# Open http://localhost:5000
```

### 5. Admin Access
- URL: http://localhost:5000/admin/login
- Username: `admin`
- Password: `admin123`
- **Change password immediately**

## 🌐 Production Setup (Railway - 3 minutes)

### Option 1: One-Click Deploy
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template)

### Option 2: Manual Railway Deploy
1. Push code to GitHub
2. Go to railway.app
3. Create new project from GitHub repo
4. Add PostgreSQL service
5. Set these environment variables:
   ```
   DATABASE_URL=(auto-filled by PostgreSQL service)
   WHMCS_API_URL=https://yourdomain.com/billing
   WHMCS_API_IDENTIFIER=your_api_id
   WHMCS_API_SECRET=your_api_secret
   SESSION_SECRET=random_string_here
   ```
6. Deploy automatically

## 🔧 WHMCS Integration (2 minutes)

### Quick Setup
1. Login to WHMCS Admin
2. Go to **System Settings** → **API Credentials**
3. Create new API credential with permissions:
   - `GetClients`, `GetClientsDetails`, `UpdateClient`
   - `GetTickets`, `AddTicketReply`, `OpenTicket`
   - `GetInvoices`, `GetProducts`
4. Add credentials to `.env`
5. Test: Visit `/api/whmcs/test`

## ✅ Quick Verification

After setup, verify everything works:

```bash
# Check application health
curl http://localhost:5000/api/health

# Check WHMCS connection (if configured)
curl http://localhost:5000/api/whmcs/test

# Check database
curl http://localhost:5000/api/games
```

## 🎮 Default Content

The platform includes sample data:
- **Games**: Minecraft, CS2, Rust, ARK, Palworld
- **Blog Posts**: Setup guides and tutorials
- **Demo Servers**: Live server examples
- **Pricing Plans**: Starter, Pro, Enterprise tiers

## 🔐 Security Checklist

Before going live:
- [ ] Change admin password
- [ ] Set strong SESSION_SECRET
- [ ] Configure WHMCS API permissions
- [ ] Enable HTTPS
- [ ] Set CORS_ORIGIN for production
- [ ] Review environment variables

## 📱 Features Ready Out-of-Box

### Client Portal
- WHMCS login integration
- Account management
- Support tickets
- Billing history

### Admin Dashboard
- Game management
- Content editing
- User analytics
- System monitoring

### Public Site
- Game hosting pages
- Pricing calculator
- Knowledge base
- Contact forms

## 🆘 Common Issues

### Database Connection Error
```bash
# Verify DATABASE_URL format
echo $DATABASE_URL
# Should be: postgresql://user:pass@host:port/db

# Push schema if needed
npm run db:push
```

### WHMCS Integration Failed
```bash
# Test WHMCS API
curl "https://yourdomain.com/billing/includes/api.php" \
  -d "action=GetProducts&identifier=YOUR_ID&secret=YOUR_SECRET&responsetype=json"
```

### Build Failures
```bash
# Clear and reinstall
rm -rf node_modules package-lock.json
npm install
npm run build
```

## 📚 Next Steps

1. **Customize branding** in admin panel
2. **Add your games** and pricing
3. **Create content** (blog posts, FAQs)
4. **Configure domain** and SSL
5. **Set up monitoring** and backups

## 🔗 Useful Links

- [Full Deployment Guide](./PRODUCTION_DEPLOYMENT_GUIDE.md)
- [API Documentation](./docs/API.md)
- [Admin Guide](./docs/ADMIN_GUIDE.md)
- [WHMCS Integration](./docs/WHMCS_INTEGRATION.md)

---

**Need help?** Check logs for detailed error messages and refer to the troubleshooting section in the main documentation.