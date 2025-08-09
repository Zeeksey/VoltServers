# Render Deployment Guide

This guide walks you through deploying your VoltServers project to Render.com.

## Prerequisites

1. A [Render account](https://render.com)
2. Your project code in a Git repository (GitHub, GitLab, or Bitbucket)
3. Basic understanding of environment variables

## Deployment Methods

### Method 1: Using render.yaml (Recommended)

This method uses the `render.yaml` file to automatically configure your services.

1. **Push your code** to a Git repository if you haven't already
2. **Go to Render Dashboard** and click "New +"
3. **Select "Blueprint"** 
4. **Connect your repository**
5. **Render will automatically detect** the `render.yaml` file and configure:
   - Web service for your application
   - PostgreSQL database
   - Environment variables

### Method 2: Manual Setup

If you prefer manual configuration:

#### Step 1: Create PostgreSQL Database
1. In Render Dashboard, click "New +" → "PostgreSQL"
2. Name: `voltservers-db`
3. Choose your plan (free tier available)
4. Click "Create Database"
5. **Save the connection details** - you'll need them

#### Step 2: Create Web Service
1. Click "New +" → "Web Service"
2. Connect your Git repository
3. Configure the service:
   - **Name**: `voltservers`
   - **Environment**: `Node`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Plan**: Choose your preferred plan

#### Step 3: Set Environment Variables
Add these in the "Environment" section:
```
NODE_ENV=production
DATABASE_URL=[your-postgresql-connection-string]
SESSION_SECRET=[generate-a-random-string]
```

## Important Configuration Notes

### Build and Start Commands
- **Build**: `npm install && npm run build`
- **Start**: `npm start`

These work with your existing `package.json` scripts.

### Environment Variables Required
- `DATABASE_URL` - PostgreSQL connection string from Render
- `NODE_ENV` - Set to "production"
- `SESSION_SECRET` - Random string for session security

### Database Setup
After deployment, you'll need to initialize your database:
1. Go to your web service dashboard
2. Open the "Shell" tab
3. Run: `npm run db:push`

This will create your database tables based on your schema.

## Health Check

The application includes a health check endpoint at `/api/health` that Render will use to monitor your service.

## Custom Domain (Optional)

After deployment:
1. Go to your web service settings
2. Add your custom domain
3. Render will automatically provision SSL certificates

## Troubleshooting

### Common Issues

1. **Build fails**: Check that all dependencies are in `package.json`
2. **Database connection errors**: Verify your `DATABASE_URL` is correctly set
3. **Application won't start**: Check the logs in Render dashboard

### Viewing Logs
- Go to your service dashboard
- Click "Logs" tab to see real-time application logs

### Database Connection Issues
- Ensure your database is in the same region as your web service
- Check that the `DATABASE_URL` format is correct
- Verify the database is running and accessible

## Scaling and Performance

### Auto-scaling
Render automatically scales your application based on traffic.

### Performance Tips
1. Use Render's CDN for static assets
2. Consider upgrading to a paid plan for better performance
3. Monitor your service metrics in the dashboard

## Deployment Workflow

### Automatic Deployments
Render automatically deploys when you push to your main branch.

### Manual Deployments
You can trigger manual deployments from the service dashboard.

## Security Best Practices

1. **Never commit secrets** to your repository
2. **Use environment variables** for all configuration
3. **Keep dependencies updated** with `npm audit`
4. **Use HTTPS only** (Render provides this automatically)

## Cost Optimization

### Free Tier Limitations
- Web services spin down after 15 minutes of inactivity
- PostgreSQL databases have storage limits
- Limited build minutes per month

### Paid Plans
- Always-on services
- More resources and faster builds
- Priority support

## Support and Resources

- [Render Documentation](https://render.com/docs)
- [Render Community Forum](https://render.com/community)
- Check your service logs for debugging

## Next Steps After Deployment

1. **Test your application** thoroughly
2. **Set up monitoring** and alerts
3. **Configure custom domain** if needed
4. **Set up backup strategy** for your database
5. **Monitor performance** and scale as needed

Your VoltServers application should now be live on Render! The URL will be provided in your service dashboard.