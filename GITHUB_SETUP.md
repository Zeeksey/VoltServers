# GitHub Setup Guide for VoltServers

This guide walks you through setting up your VoltServers project on GitHub and deploying it to Render.

## Step 1: Prepare Your Project

Your project is already configured with:
- ✅ `.gitignore` file to exclude sensitive files
- ✅ `render.yaml` for automatic deployment
- ✅ Health check endpoint at `/api/health`

## Step 2: Create a GitHub Repository

### Option A: Using GitHub Website
1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon → "New repository"
3. Repository name: `voltservers` (or your preferred name)
4. Make it **Public** (required for free Render deployments)
5. **Don't** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

### Option B: Using GitHub CLI (if installed)
```bash
gh repo create voltservers --public --source=. --remote=origin --push
```

## Step 3: Initialize Git and Push Your Code

Run these commands in your project directory:

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: VoltServers game hosting platform"

# Add GitHub as remote origin (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/voltservers.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 4: Deploy to Render from GitHub

### Automatic Deployment (Recommended)
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New +" → "Blueprint"
3. Connect your GitHub account if not already connected
4. Select your `voltservers` repository
5. Click "Connect"
6. Render will automatically:
   - Create a PostgreSQL database
   - Create a web service
   - Set up environment variables
   - Deploy your application

### Manual Service Creation
If you prefer manual setup:

1. **Create Database**:
   - New → PostgreSQL
   - Name: `voltservers-db`
   - Region: Choose closest to your users
   - Plan: Free tier available

2. **Create Web Service**:
   - New → Web Service
   - Connect GitHub repository
   - Settings:
     - Name: `voltservers`
     - Environment: `Node`
     - Build Command: `npm install && npm run build`
     - Start Command: `npm start`

3. **Environment Variables**:
   ```
   NODE_ENV=production
   DATABASE_URL=[auto-generated from database]
   SESSION_SECRET=[generate random string]
   ```

## Step 5: Post-Deployment Setup

After successful deployment:

1. **Initialize Database**:
   - Go to your web service dashboard
   - Click "Shell" tab
   - Run: `npm run db:push`

2. **Test Your Application**:
   - Visit your `.onrender.com` URL
   - Check health endpoint: `your-app.onrender.com/api/health`

## Step 6: Set Up Continuous Deployment

GitHub → Render integration is automatic:
- Every push to `main` branch triggers a new deployment
- Check deployment status in Render dashboard
- View build logs for troubleshooting

## Environment Variables You'll Need

For production deployment, ensure these are set in Render:

```bash
# Required
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@host:port/db

# Security
SESSION_SECRET=your-super-secret-key

# Optional (if using external services)
WHMCS_API_URL=your-whmcs-url
WHMCS_API_KEY=your-whmcs-key
WISP_API_URL=your-wisp-url
WISP_API_KEY=your-wisp-key
```

## GitHub Actions (Optional Advanced Setup)

For additional CI/CD, create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Render

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    - run: npm ci
    - run: npm run check
```

## Project Structure for GitHub

```
voltservers/
├── .github/                 # GitHub workflows (optional)
├── .vscode/                 # VS Code settings (excluded from git)
├── client/                  # Frontend React app
├── server/                  # Backend Express server
├── shared/                  # Shared TypeScript types
├── .gitignore              # Git ignore rules
├── render.yaml             # Render deployment config
├── package.json            # Dependencies and scripts
├── README.md               # Project documentation
└── GITHUB_SETUP.md         # This guide
```

## Troubleshooting Common Issues

### 1. Build Fails on Render
- Check build logs in Render dashboard
- Ensure all dependencies are in `package.json`
- Verify build command: `npm install && npm run build`

### 2. Database Connection Issues
- Confirm `DATABASE_URL` environment variable is set
- Check database is in same region as web service
- Run `npm run db:push` after first deployment

### 3. Git Push Issues
```bash
# If you get authentication errors
git remote set-url origin https://YOUR_USERNAME@github.com/YOUR_USERNAME/voltservers.git

# If branch already exists
git pull origin main --rebase
git push origin main
```

### 4. Environment Variables
- Never commit `.env` files to GitHub
- Set all production variables in Render dashboard
- Use Render's built-in database connection string

## Security Best Practices

1. **Never commit secrets** to GitHub
2. **Use environment variables** for all configuration
3. **Keep repository public** only if comfortable (private repos require paid Render plan)
4. **Review commits** before pushing sensitive changes
5. **Use strong session secrets** in production

## Next Steps After Setup

1. **Custom Domain**: Add your domain in Render settings
2. **SSL Certificate**: Automatically provided by Render
3. **Monitoring**: Set up Render alerts for downtime
4. **Backups**: Configure database backups
5. **Scaling**: Monitor usage and upgrade plans as needed

## Support Resources

- [GitHub Documentation](https://docs.github.com)
- [Render Documentation](https://render.com/docs)
- [Git Basics](https://git-scm.com/doc)

Your VoltServers application will be live at `https://your-service-name.onrender.com` after successful deployment!