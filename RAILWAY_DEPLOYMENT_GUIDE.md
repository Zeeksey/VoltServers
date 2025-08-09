# Railway Deployment Guide for VoltServers

Railway is the easiest way to deploy your VoltServers platform with full-stack support and PostgreSQL integration.

## Why Railway?

✅ **Zero Configuration**: No config files needed - Railway detects your setup automatically  
✅ **Express.js Native**: Built specifically for Node.js backends  
✅ **One-Click PostgreSQL**: Instant database setup with connection strings  
✅ **GitHub Integration**: Automatic deployments on every push  
✅ **Free Tier**: $5/month credit included (enough for development)  
✅ **Simple Environment Variables**: Easy secret management  

## Step 1: Push Your Code to GitHub

Using VS Code (if not done already):
1. Open Source Control panel (`Ctrl+Shift+G`)
2. Stage all changes (click the "+" button)
3. Commit: `"Prepare Railway deployment"`
4. Click "Publish to GitHub" → Choose **public repository**

## Step 2: Deploy to Railway

### A. Create Railway Account
1. Visit **[railway.app](https://railway.app)**
2. Click **"Start a New Project"**
3. Sign in with your **GitHub account**

### B. Deploy Your Project
1. **New Project** → **Deploy from GitHub repo**
2. Select your **`voltservers`** repository
3. Railway automatically detects it's a Node.js project
4. Click **"Deploy Now"**

Railway will automatically:
- Run `npm install`
- Execute `npm run build` 
- Start with `npm start`
- Assign a public URL

## Step 3: Add PostgreSQL Database (CRITICAL - Do This First!)

⚠️ **IMPORTANT**: Add the database BEFORE the first deployment to avoid "DATABASE_URL must be set" errors.

1. **In your Railway project dashboard**:
   - Click **"+ New"** → **"Database"** → **"Add PostgreSQL"**
   - Railway creates the database instantly
   - Connection string is automatically added to your environment as `DATABASE_URL`

2. **Verify Database Connection**:
   - Go to **Variables** tab
   - Confirm `DATABASE_URL` is listed (starts with `postgresql://`)
   - If missing, redeploy your service after adding the database

## Step 4: Configure Environment Variables

In Railway dashboard → **Variables** tab, add:

```bash
# Session Security
SESSION_SECRET=your_random_session_secret_here

# WHMCS Integration  
WHMCS_API_URL=https://voltservers.com/billing/
WHMCS_API_IDENTIFIER=your_whmcs_api_identifier
WHMCS_API_SECRET=your_whmcs_api_secret

# Optional: Wisp.gg Integration
WISP_API_URL=https://game.voltservers.com
WISP_API_KEY=your_wisp_api_key
```

**Note**: `DATABASE_URL` is automatically provided by Railway's PostgreSQL service.

### Generate SESSION_SECRET:
```bash
# Run this in any terminal to generate a secure session secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Step 5: Database Migration

After deployment, run your database schema:

1. **In Railway dashboard**: Go to your service → **"Deploy Logs"**
2. **Optional**: Run migration manually:
   ```bash
   # Install Railway CLI (optional)
   npm install -g @railway/cli
   
   # Connect to your project
   railway login
   railway link
   
   # Run database migration
   railway run npm run db:push
   ```

## Step 6: Custom Domain (Optional)

1. **In Railway dashboard**: Settings → **Domains**
2. **Add custom domain**: `yourdomain.com`
3. **Configure DNS**: Add CNAME record pointing to Railway URL
4. **SSL Certificate**: Automatically provisioned

## Step 7: Test Your Deployment

Your VoltServers platform will be live at:
- **Railway URL**: `https://voltservers-production.up.railway.app`
- **Custom domain** (if configured): `https://yourdomain.com`

### Test These Features:
- ✅ **Homepage**: Game server listings and pricing
- ✅ **Client Portal**: WHMCS login and account management  
- ✅ **Server Status**: Real-time server monitoring
- ✅ **Database**: User data and server information
- ✅ **API Endpoints**: All backend functionality

## Automatic Deployments

Once set up, Railway automatically deploys when you:
1. Push changes to your GitHub repository
2. Railway detects the push and rebuilds
3. New version goes live in ~2-3 minutes

## Environment Management

Railway provides different environments:
- **Production**: Your live site
- **Staging**: Test deployments (Pro plan)

## Monitoring and Logs

Railway dashboard provides:
- **Real-time logs**: See your application output
- **Metrics**: CPU, memory, and network usage  
- **Deploy history**: Track all deployments
- **Database metrics**: Query performance and usage

## Cost Breakdown

**Free Tier** ($5 credit monthly):
- Web service: ~$3-4/month
- PostgreSQL: ~$1/month  
- Total: Well within free limits for development

**Pro Plan** ($20/month):
- Unlimited projects
- Staging environments
- Priority support
- Advanced metrics

## Troubleshooting

### Build Failures:
- Check **Deploy Logs** in Railway dashboard
- Verify all dependencies are in `package.json`
- Ensure `npm run build` works locally

### "DATABASE_URL must be set" Error:
- **Add PostgreSQL database** in Railway dashboard first
- Go to **Variables** tab and verify `DATABASE_URL` exists
- **Redeploy** your service after adding the database
- The database must be added BEFORE deployment, not after

### Database Connection Issues:
- Railway automatically provides `DATABASE_URL`
- Check **Variables** tab to verify it's set
- Test connection in **Railway console**

### WHMCS Integration Issues:
- Verify API credentials in **Variables**
- Check if Railway IPs need whitelisting in WHMCS
- Test API endpoints in Railway logs

## Support Resources

- **Railway Docs**: [docs.railway.app](https://docs.railway.app)
- **Railway Discord**: Community support
- **GitHub Issues**: For your project-specific issues

Your VoltServers platform will be production-ready with full WHMCS integration, PostgreSQL database, and automatic deployments from GitHub!