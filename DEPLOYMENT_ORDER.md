# Railway Deployment Order (Important!)

## ⚠️ Critical: Follow This Exact Order

To avoid "DATABASE_URL must be set" errors, follow these steps in order:

### 1. Push to GitHub First
- Commit all changes in VS Code
- Push to GitHub repository

### 2. Create Railway Project
- Visit railway.app
- Sign in with GitHub
- New Project → Deploy from GitHub
- Select your repository
- **DO NOT CLICK DEPLOY YET**

### 3. Add Database BEFORE First Deploy
- In Railway dashboard: **"+ New" → "Database" → "Add PostgreSQL"**
- Wait for database to be created
- Verify `DATABASE_URL` appears in Variables tab

### 4. Add Other Environment Variables
```
SESSION_SECRET=your_session_secret
WHMCS_API_URL=https://voltservers.com/billing/
WHMCS_API_IDENTIFIER=your_whmcs_identifier
WHMCS_API_SECRET=your_whmcs_secret
```

### 5. Now Deploy
- Click "Deploy" button
- Railway will build and start your application
- Database connection will work on first try

## Why This Order Matters:
- Railway apps crash on startup if DATABASE_URL is missing
- Adding database after deployment requires a redeploy
- Following this order prevents connection errors

## If You Already Have the Error:
1. Add PostgreSQL database in Railway dashboard
2. Go to Deployments → Click "Redeploy"
3. Application will restart with database connection