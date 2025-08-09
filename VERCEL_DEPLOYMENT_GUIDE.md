# Vercel Deployment Guide for VoltServers

This guide walks you through deploying your VoltServers platform to Vercel with PostgreSQL database.

## Why Vercel?

✅ **Better Build Support**: Native support for modern build tools
✅ **Automatic Deployments**: Git-based deployments from GitHub
✅ **Environment Variables**: Easy secret management
✅ **PostgreSQL Integration**: Built-in database support
✅ **Global CDN**: Fast worldwide performance
✅ **Free Tier**: Generous limits for personal projects

## Step 1: Prepare Your Project

Your project is now configured with:
- ✅ `vercel.json` configuration file
- ✅ Optimized build setup for Vercel
- ✅ Environment variable configuration

## Step 2: Push to GitHub

If you haven't already, push your code to GitHub using VS Code:

1. **Open VS Code** with your project
2. **Source Control Panel**: Click Git icon (`Ctrl+Shift+G`)
3. **Stage Changes**: Click "+" to stage all files
4. **Commit**: Enter message "Add Vercel deployment configuration"
5. **Publish to GitHub**: Click "Publish to GitHub" button
6. **Choose Public Repository** (required for free deployments)

## Step 3: Deploy to Vercel

### Option A: Vercel Dashboard (Recommended)

1. **Visit [Vercel Dashboard](https://vercel.com/dashboard)**
2. **Sign in** with GitHub account
3. **Import Project**:
   - Click "Add New..." → "Project"
   - Select your `voltservers` repository
   - Click "Import"

4. **Configure Build Settings**:
   - **Framework Preset**: Other
   - **Root Directory**: `./` (leave default)
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist/public`
   - **Install Command**: `npm install`

### Option B: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy from project directory
vercel

# Follow the prompts:
# - Link to existing project? N
# - Project name: voltservers
# - Directory: ./
# - Want to override settings? N
```

## Step 4: Add Database

### PostgreSQL on Vercel

1. **In Vercel Dashboard**:
   - Go to your project
   - Click "Storage" tab
   - Click "Create Database"
   - Select "Postgres"
   - Database name: `voltservers-db`
   - Click "Create"

2. **Environment Variables** (automatically added):
   - `POSTGRES_URL`
   - `POSTGRES_PRISMA_URL` 
   - `POSTGRES_URL_NON_POOLING`

### Alternative: Neon PostgreSQL (Free Tier)

1. **Visit [Neon Console](https://console.neon.tech)**
2. **Create Project**: 
   - Project name: `voltservers`
   - Database name: `voltservers`
   - Region: Choose closest to your users
3. **Copy Connection String**
4. **Add to Vercel**:
   - Go to Project Settings → Environment Variables
   - Add `DATABASE_URL` with your Neon connection string

## Step 5: Configure Environment Variables

In Vercel Dashboard → Project Settings → Environment Variables, add:

### Required Variables:
```
DATABASE_URL=your_postgresql_connection_string
SESSION_SECRET=your_random_secret_key
WHMCS_API_URL=https://voltservers.com/billing/
WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
WHMCS_API_SECRET=your_whmcs_api_secret
```

### Generate SESSION_SECRET:
```bash
# Generate a random session secret
openssl rand -base64 32
```

## Step 6: Deploy and Test

1. **Automatic Deployment**: Vercel deploys automatically when you push to GitHub
2. **Custom Domain** (Optional): 
   - Go to Project Settings → Domains
   - Add your custom domain
   - Configure DNS records as shown

3. **Test Your Deployment**:
   - Visit your Vercel URL (e.g., `voltservers.vercel.app`)
   - Test WHMCS client portal functionality
   - Verify database connectivity

## Step 7: Database Migration

After deployment, run database migrations:

```bash
# Install Vercel CLI if not already installed
npm i -g vercel

# Link to your project
vercel link

# Run database migration
vercel env pull .env.local
npm run db:push
```

## Features Included:

✅ **Full-Stack Application**: React frontend + Express backend
✅ **WHMCS Integration**: Client portal, billing, support tickets
✅ **Database**: PostgreSQL with Drizzle ORM
✅ **Authentication**: Session-based auth with WHMCS
✅ **Server Management**: Wisp.gg integration
✅ **Real-time Updates**: Live server status monitoring
✅ **Responsive Design**: Gaming-themed UI with dark/light modes

## Troubleshooting:

### Build Failures:
- Check build logs in Vercel dashboard
- Ensure all dependencies are in `package.json`
- Verify environment variables are set

### Database Connection Issues:
- Verify `DATABASE_URL` is correct
- Check database allows connections from Vercel IPs
- Test connection string locally

### WHMCS Integration Issues:
- Verify WHMCS API credentials
- Check if Vercel IPs are whitelisted in WHMCS
- Test API endpoints manually

## Support:

- **Vercel Docs**: https://vercel.com/docs
- **Neon Docs**: https://neon.tech/docs
- **Project Repository**: Your GitHub repository

Your VoltServers platform will be live at `https://your-project.vercel.app` with full WHMCS integration and PostgreSQL database!