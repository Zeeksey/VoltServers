# WHMCS Integration on Railway

## Environment Variables Setup

In your Railway dashboard → **Variables** tab, add these exact variables:

```bash
# WHMCS API Configuration
WHMCS_API_URL=https://voltservers.com/billing/
WHMCS_API_IDENTIFIER=your_whmcs_api_identifier_here
WHMCS_API_SECRET=your_whmcs_api_secret_here

# Session Security
SESSION_SECRET=your_generated_session_secret

# Database (automatically provided by Railway PostgreSQL)
DATABASE_URL=postgresql://... (automatically set)
```

## Getting WHMCS API Credentials

### 1. Create API Credentials in WHMCS:
1. **Login to WHMCS Admin**: `https://voltservers.com/billing/admin/`
2. **Setup → Staff Management → API Credentials**
3. **Create New API Credential**:
   - **Description**: Railway Production API
   - **Username**: Select your admin user
   - **Password**: Generate strong password
   - **Access Control**: 
     - ✅ GetClients
     - ✅ GetClientsDetails  
     - ✅ GetTickets
     - ✅ GetProducts
     - ✅ ValidateLogin
     - ✅ GetInvoices
     - ✅ AcceptOrder
4. **Save** and copy the credentials

### 2. Get Railway's IP Address for Whitelisting:
After deployment, Railway will assign IP addresses. You can find them by:

1. **Check Railway Logs** for outgoing IP
2. **Test API endpoint** `/api/whmcs/test` and check error logs
3. **Common Railway IP ranges**:
   - `52.70.0.0/16` (US East)
   - `54.80.0.0/16` (US East) 
   - `3.208.0.0/16` (US East)

### 3. Whitelist Railway IPs in WHMCS:
1. **WHMCS Admin → Setup → General Settings → Security**
2. **API IP Access Restriction**:
   - Add specific Railway IP when you get it
   - Or temporarily use `0.0.0.0/0` for testing (remove after)
3. **Save Changes**

## Testing WHMCS Integration

### 1. Test API Connection:
Visit your Railway app URL: `https://yourapp.up.railway.app/api/whmcs/test`

**Success Response:**
```json
{
  "connected": true,
  "message": "WHMCS connection successful",
  "products": [...],
  "totalresults": 10
}
```

**Failure Response:**
```json
{
  "connected": false,
  "message": "WHMCS connection failed: HTTP 403: Forbidden"
}
```

### 2. Test Client Portal:
1. Visit: `https://yourapp.up.railway.app/client-portal`
2. Try logging in with WHMCS credentials
3. Should redirect to dashboard with client data

## Troubleshooting

### "HTTP 403: Forbidden" Error:
- **Cause**: Railway IP not whitelisted in WHMCS
- **Fix**: Add Railway's IP to WHMCS API access restrictions

### "Invalid API Credentials" Error:
- **Cause**: Wrong identifier/secret or missing permissions
- **Fix**: Verify credentials in WHMCS admin and ensure proper permissions

### "Connection Timeout" Error:
- **Cause**: Network connectivity issues
- **Fix**: Check WHMCS server is accessible and API endpoint is correct

### Empty Response or 404:
- **Cause**: Wrong API URL or WHMCS API disabled
- **Fix**: Verify `https://voltservers.com/billing/includes/api.php` is accessible

## Security Best Practices

1. **Use Specific IP Whitelisting**: Don't use `0.0.0.0/0` in production
2. **Rotate API Credentials**: Change them periodically
3. **Monitor API Usage**: Check WHMCS logs for unusual activity
4. **Secure Environment Variables**: Railway automatically encrypts them

## Railway-Specific Notes

- **Environment Variables**: Added through Railway dashboard, not code
- **IP Address**: Railway assigns dynamic IPs, check logs for actual IP
- **SSL**: Railway automatically provides HTTPS
- **Database**: `DATABASE_URL` automatically provided by PostgreSQL plugin
- **Logs**: Check Railway dashboard for WHMCS API call logs

Your WHMCS integration will work on Railway just like it does in Replit once the IP is whitelisted and credentials are properly configured.