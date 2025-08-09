# Game Hosting Platform Deployment & Customization Guide

This guide will help you deploy and customize your game hosting platform for your own business.

## Table of Contents
1. [Shared Hosting Deployment](#shared-hosting-deployment) ⭐ **NEW**
2. [Quick Start](#quick-start)
3. [Games Management](#games-management)
4. [Demo Servers Configuration](#demo-servers-configuration)
5. [Branding & Visual Identity](#branding--visual-identity)
6. [Pricing Plans](#pricing-plans)
7. [Blog & Content](#blog--content)
8. [Server Locations](#server-locations)
9. [Admin Panel](#admin-panel)
10. [Environment Variables](#environment-variables)
11. [Database Setup](#database-setup)
12. [VPS/Dedicated Server Deployment](#vpsdedicated-server-deployment)

## Shared Hosting Deployment

### ⚠️ Important: Shared Hosting Limitations

Most shared hosting providers (like cPanel, GoDaddy, Bluehost) **DO NOT support Node.js applications**. This application requires:
- Node.js runtime
- PostgreSQL database
- Server-side processing capabilities

### Recommended Hosting Providers for Node.js:

**Budget-Friendly Options:**
- **Render.com** - Free tier available, automatic deployments
- **Railway.app** - Simple Node.js deployment
- **Cyclic.sh** - Serverless Node.js hosting
- **Vercel** - Free tier with serverless functions

**Production-Ready Options:**
- **DigitalOcean App Platform** - $5/month
- **Heroku** - Starts at $7/month
- **AWS Elastic Beanstalk** - Pay-as-you-use
- **Google Cloud Run** - Serverless containers

### Deployment to Render.com (Recommended for Beginners)

1. **Create accounts:**
   - Sign up at [render.com](https://render.com)
   - Sign up at [neon.tech](https://neon.tech) for free PostgreSQL

2. **Database Setup:**
   ```bash
   # Get your database URL from Neon.tech dashboard
   # It looks like: postgresql://username:password@host/database
   ```

3. **Deploy to Render:**
   - Connect your GitHub repository to Render
   - Create a new "Web Service"
   - Build Command: `npm install && npm run build`
   - Start Command: `npm start`
   - **Important:** Ensure your `package.json` has these scripts:
     ```json
     {
       "scripts": {
         "build": "cd client && npm run build && cd .. && tsc server/**/*.ts --outDir dist/server",
         "start": "node dist/server/index.js",
         "dev": "npm run dev"
       }
     }
     ```

4. **Environment Variables in Render:**
   ```
   NODE_ENV=production
   DATABASE_URL=your_neon_database_url
   PORT=5000
   ```

5. **Custom Domain (Optional):**
   - In Render dashboard: Settings → Custom Domains
   - Add your domain and configure DNS

### Deployment to Vercel (Static + Serverless)

**⚠️ Note:** Requires significant code changes to work with Vercel's serverless architecture.

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Create `vercel.json`:**
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "client/dist/**",
         "use": "@vercel/static"
       },
       {
         "src": "server/index.ts",
         "use": "@vercel/node"
       }
     ],
     "routes": [
       {
         "src": "/api/(.*)",
         "dest": "/server/index.ts"
       },
       {
         "src": "/(.*)",
         "dest": "/client/dist/$1"
       }
     ]
   }
   ```

3. **Build and Deploy:**
   ```bash
   npm run build
   vercel --prod
   ```

### Traditional Shared Hosting (cPanel) - Not Recommended

If you must use traditional shared hosting, you'll need to:

1. **Check Node.js Support:**
   - Contact your hosting provider
   - Ask if they support Node.js applications
   - Most shared hosts only support PHP/static files

2. **Alternative: Static Site + External API:**
   - Build frontend only: `npm run build:client`
   - Host static files on shared hosting
   - Use external services for backend (Firebase, Supabase)

### What to Change for Shared Hosting:

1. **Remove Server Dependencies:**
   - Database queries become API calls to external services
   - Authentication via third-party providers (Auth0, Firebase Auth)
   - File uploads to cloud storage (Cloudinary, AWS S3)

2. **Convert to Static Site:**
   ```bash
   # Build only the frontend
   cd client
   npm run build
   # Upload 'dist' folder to your hosting provider
   ```

3. **Use External Services:**
   - **Database:** Neon.tech, PlanetScale, or Supabase
   - **Authentication:** Auth0, Firebase Auth
   - **File Storage:** Cloudinary, AWS S3  
   - **Email:** SendGrid, Mailgun

### Critical Files to Modify for Production:

1. **Update `package.json` scripts:**
   ```json
   {
     "scripts": {
       "build": "vite build --mode production",
       "start": "NODE_ENV=production tsx server/index.ts",
       "build:client": "cd client && vite build",
       "build:server": "tsc server/**/*.ts --outDir dist",
       "postinstall": "npm run build:client"
     }
   }
   ```

2. **Create `.env.production` file:**
   ```env
   NODE_ENV=production
   DATABASE_URL=your_production_database_url
   PORT=5000
   ```

3. **Update database configuration in `server/db.ts`:**
   ```typescript
   // Add SSL configuration for production databases
   const client = neon(process.env.DATABASE_URL!, {
     ssl: process.env.NODE_ENV === 'production'
   });
   ```

4. **Configure CORS for production in `server/index.ts`:**
   ```typescript
   // Add your production domain
   const corsOptions = {
     origin: process.env.NODE_ENV === 'production' 
       ? ['https://yourdomain.com', 'https://www.yourdomain.com']
       : ['http://localhost:3000', 'http://localhost:5000']
   };
   ```

## Quick Start

### Prerequisites for VPS/Cloud Hosting
- Node.js 18+ installed
- PostgreSQL database (or external service like Neon.tech)
- Domain name and hosting environment with Node.js support

### Initial Setup
1. Clone the repository to your server
2. Run `npm install` to install dependencies
3. Set up your PostgreSQL database (local or cloud)
4. Configure environment variables (see [Environment Variables](#environment-variables))
5. Run `npm run dev` for development or build for production

## Games Management

### Adding New Games

**Location**: `server/storage.ts` - `games` array

```javascript
{
  id: 'unique-game-id',
  name: 'Game Name',
  slug: 'game-slug', // Used in URLs like /games/game-slug
  description: 'Brief description of the game',
  imageUrl: 'https://your-cdn.com/game-image.jpg',
  basePrice: '9.99', // Starting price per month
  playerCount: 50000, // Approximate player base for sorting
  isPopular: true, // Shows "Popular" badge
  isNew: false, // Shows "New" badge  
  isTrending: false // Shows "Trending" badge
}
```

**Game Images**: 
- Recommended size: 400x300px
- Format: JPG or PNG
- Host on a CDN for best performance

### Game Categories & Platforms

**Location**: `client/src/pages/games.tsx`

Update the `enhancedGames` mapping to assign categories and platforms:

```javascript
category: game.name === 'Your Game' ? 'category-name' : 'default-category',
platform: game.name === 'Your Game' ? 'PC' : 'Crossplay',
```

**Available Categories**: `survival`, `action`, `simulation`, `strategy`, `sandbox`
**Available Platforms**: `PC`, `Console`, `Crossplay`

### Game Pricing Tiers

**Location**: `server/storage.ts` - Update the `getGamePricingTiers` method

```javascript
{
  id: 'tier-id',
  gameId: 'game-id',
  name: 'Plan Name',
  price: '14.99',
  billingCycle: 'monthly', // or 'quarterly', 'yearly'
  specs: {
    ram: '4GB',
    cpu: '2 vCores',
    storage: '50GB SSD',
    players: '50'
  },
  features: ['DDoS Protection', 'Auto Backups', '24/7 Support']
}
```

## Demo Servers Configuration

**Location**: `client/src/components/demo-games-section.tsx`

Update the `demoServers` array:

```javascript
{
  id: '1',
  name: 'Your Server Name',
  game: 'Minecraft',
  ip: 'demo.yourcompany.com', // Your actual demo server IP
  port: '25565',
  version: '1.21.4',
  players: { online: 47, max: 100 }, // Current/max players
  status: 'online', // 'online', 'offline', 'maintenance'
  platform: 'Crossplay', // 'PC', 'Console', 'Crossplay'
  gameMode: 'Creative',
  description: 'Description of your demo server'
}
```

**Important**: 
- Replace demo IPs with your actual server addresses
- Update player counts regularly for authenticity
- Ensure demo servers are actually running and accessible

## Branding & Visual Identity

### Company Name & Logo

**Locations to Update**:
1. `client/src/components/navigation.tsx` - Logo and company name
2. `client/src/components/footer.tsx` - Footer branding
3. `client/src/pages/home.tsx` - Page title and meta tags

**Logo**: Currently uses a lightning bolt (Zap icon). To change:
```javascript
// In navigation.tsx and footer.tsx
import { YourIcon } from "lucide-react";
<YourIcon className="text-gaming-black text-xl" />
```

### Color Scheme

**Location**: `client/src/index.css`

Update CSS variables:
```css
:root {
  --gaming-green: 108 145 47; /* Your primary color */
  --gaming-green-dark: 88 125 27; /* Darker variant */
  --gaming-black: 12 12 12; /* Background color */
  --gaming-black-light: 20 20 20; /* Light background */
  --gaming-black-lighter: 32 32 32; /* Lighter background */
}
```

### Social Media Links

**Location**: `client/src/components/footer.tsx`

Update social media URLs:
```javascript
onClick={() => window.open('https://twitter.com/yourcompany', '_blank')}
onClick={() => window.open('https://discord.gg/yourcompany', '_blank')}
onClick={() => window.open('https://youtube.com/@yourcompany', '_blank')}
onClick={() => window.open('https://github.com/yourcompany', '_blank')}
```

## Pricing Plans

**Location**: `server/storage.ts` - `pricingPlans` array

```javascript
{
  id: 'plan-id',
  name: 'Plan Name',
  price: '29.99',
  billingCycle: 'monthly',
  description: 'Perfect for small communities',
  features: [
    'Feature 1',
    'Feature 2', 
    'Feature 3'
  ],
  specs: {
    ram: '8GB',
    cpu: '4 vCores', 
    storage: '100GB NVMe',
    bandwidth: 'Unlimited',
    players: '100'
  },
  isPopular: false, // Highlights the plan
  gameSupport: ['minecraft', 'rust', 'cs2'] // Supported games
}
```

## Blog & Content

### Adding Blog Posts

**Location**: `server/storage.ts` - `blogPosts` array

```javascript
{
  id: 'unique-post-id',
  title: 'Blog Post Title',
  slug: 'blog-post-slug',
  excerpt: 'Brief summary of the post...',
  content: 'Full HTML content of the blog post',
  author: 'Author Name',
  publishedAt: '2025-01-15',
  readTime: '5 min read',
  tags: ['tag1', 'tag2'],
  imageUrl: 'https://your-cdn.com/blog-image.jpg',
  featured: true // Appears in featured section
}
```

### Knowledge Base Articles

**Location**: `server/storage.ts` - Blog posts with specific categories

Use tags like `['tutorial', 'minecraft', 'setup']` for knowledge base categorization.

## Server Locations

**Location**: `server/storage.ts` - `serverLocations` array

```javascript
{
  id: 'location-id',
  name: 'Location Name',
  city: 'City',
  country: 'Country',
  region: 'North America', // or 'Europe', 'Asia', etc.
  flag: '🇺🇸', // Country flag emoji
  ping: 25, // Average ping in ms
  status: 'operational', // 'operational', 'maintenance', 'issues'
  specs: {
    cpu: 'Intel Xeon E5-2680',
    ram: '128GB DDR4',
    storage: 'NVMe SSD',
    network: '10Gbps'
  }
}
```

## Admin Panel

### Admin Credentials

**Default Login**: 
- URL: `/admin/login`
- Username: `admin`
- Password: `admin123`

**To Change**: Update in `server/storage.ts` - `adminUsers` array

### Admin Features

The admin panel allows you to:
- Manage games and pricing
- Edit server locations
- Monitor server status
- Update blog content
- Manage promotional banners

## Environment Variables

Create a `.env` file with:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/voltservers
PGHOST=localhost
PGPORT=5432
PGDATABASE=voltservers
PGUSER=your_username
PGPASSWORD=your_password

# App Configuration
NODE_ENV=production
PORT=5000

# Optional: External APIs
STRIPE_SECRET_KEY=sk_live_... # For payments
DISCORD_WEBHOOK_URL=https://... # For notifications
```

## Database Setup

### PostgreSQL Installation

1. Install PostgreSQL on your server
2. Create a database: `CREATE DATABASE voltservers;`
3. Create a user with permissions
4. Update connection string in environment variables

### Schema Migration

The app automatically creates tables on startup. For production, consider using migrations:

```bash
npm run db:push  # Push schema changes
npm run db:generate  # Generate migration files
```

## VPS/Dedicated Server Deployment

### Production Build

```bash
# Install dependencies
npm install

# Build the application
npm run build

# Start production server
npm start
```

### Process Management (PM2)

```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start npm --name "voltservers" -- start

# Save PM2 configuration
pm2 save
pm2 startup
```

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Content Customization Checklist

### Before Going Live:

- [ ] **Choose hosting provider** (Render, Railway, or VPS)
- [ ] **Set up database** (Neon.tech recommended for beginners)
- [ ] Update company name and branding
- [ ] Replace demo server IPs with real servers  
- [ ] Configure your games and pricing
- [ ] Add your server locations
- [ ] Update social media links
- [ ] Write initial blog posts
- [ ] Set up admin credentials
- [ ] Configure environment variables
- [ ] Test all functionality in production environment
- [ ] Set up monitoring and backups
- [ ] Configure custom domain and SSL

### Ongoing Maintenance:

- [ ] Update demo server player counts
- [ ] Add new games as needed
- [ ] Publish regular blog content
- [ ] Monitor server status
- [ ] Update pricing as needed
- [ ] Respond to customer feedback

## Support & Customization

For additional customization beyond this guide:

1. **Code Structure**: The app follows a standard React + Express structure
2. **Database**: Uses Drizzle ORM with PostgreSQL
3. **Styling**: Tailwind CSS with custom gaming theme
4. **Components**: Modular component architecture in `client/src/components/`
5. **API Routes**: RESTful API in `server/routes.ts`

The codebase is well-documented and follows modern best practices for easy customization and maintenance.