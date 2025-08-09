# Quick PM2 Configuration Fix

If you encounter the PM2 configuration error during deployment, run this simple fix:

## On your Ubuntu server:

1. **Navigate to your voltservers directory:**
   ```bash
   cd /home/ubuntu/voltservers
   ```

2. **Download and run the fix script:**
   ```bash
   wget https://raw.githubusercontent.com/yourusername/voltservers/main/fix-pm2-config.sh
   chmod +x fix-pm2-config.sh
   ./fix-pm2-config.sh
   ```

   **OR** create the fix manually:

3. **Manual fix - create correct PM2 config:**
   ```bash
   cat > ecosystem.config.js << 'EOF'
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
   ```

4. **Start the application:**
   ```bash
   mkdir -p logs
   pm2 start ecosystem.config.js --env production
   pm2 save
   ```

5. **Check status:**
   ```bash
   pm2 status
   ```

Your VoltServers platform should now be running successfully!

**Access your application:**
- HTTP: `http://your-server-ip`
- HTTPS: `https://your-domain.com` (if SSL configured)

The PM2 configuration issue is now permanently fixed in the deployment script for future deployments.