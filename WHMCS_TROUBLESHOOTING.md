# WHMCS Integration Troubleshooting Guide

## Current Issue: Invalid IP Error

The WHMCS API is returning "Invalid IP 35.231.143.88" which means Replit's server IP is not whitelisted.

## Steps to Fix:

### 1. WHMCS Admin Panel - API Credentials
1. Login to your WHMCS admin area
2. Navigate to **System Settings** → **API Credentials**
3. Find your API credentials or create new ones
4. In the **Allowed IP Addresses** field, add: `35.231.143.88`
5. Make sure the API credentials have these permissions:
   - GetProducts (for connection testing)
   - GetClients
   - GetClientsDetails
   - GetClientsProducts
   - GetInvoices
   - GetTickets
   - GetActivityLog (optional)

### 2. WHMCS Admin Panel - Security Settings
1. Go to **System Settings** → **General Settings** → **Security**
2. Check if there are global IP restrictions
3. Add `35.231.143.88` to any IP whitelist you find

### 3. Server-Level Firewall
If your WHMCS is behind a firewall:
- Add `35.231.143.88` to your server's firewall rules
- Check Apache/Nginx configurations for IP restrictions

### 4. Alternative: Use Wildcard (Testing Only)
For testing purposes, you can set the allowed IP to `*` (allows any IP)
**WARNING: This is less secure and should only be used for testing**

### 5. Verify API URL Format
Make sure your WHMCS_API_URL is formatted correctly:
- ✅ Correct: `https://yourdomain.com/billing`
- ❌ Wrong: `yourdomain.com/billing` (missing https://)
- ❌ Wrong: `https://yourdomain.com/billing/` (trailing slash)

## Testing the Connection
Once you've made changes:
1. Visit `/api/whmcs/test` to test the connection
2. Check the browser console for detailed error messages
3. Visit `/client-portal` to see if real WHMCS data appears

## Current Environment Variables
- WHMCS_API_IDENTIFIER: Set ✓
- WHMCS_API_SECRET: Set ✓  
- WHMCS_API_URL: Set ✓

## Common Solutions
1. **Double-check IP whitelist**: Sometimes there are multiple IP restriction fields
2. **Wait 5-10 minutes**: Some WHMCS installations cache IP restrictions
3. **Check WHMCS logs**: Look in WHMCS admin → Utilities → Logs → API Log
4. **Test API directly**: Use Postman or curl to test your WHMCS API outside of this application

## If Still Not Working
1. Contact your hosting provider about IP restrictions
2. Consider hosting both the website and WHMCS on the same server
3. Set up a proxy server on your WHMCS hosting to forward API requests