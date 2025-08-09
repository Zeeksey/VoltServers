#!/usr/bin/env node

/**
 * Script to create a static version optimized for NameCheap shared hosting
 * This removes all dynamic functionality and creates a purely static site
 */

const fs = require('fs');
const path = require('path');

console.log('🔄 Creating static version of the website...');

// Static data to replace API calls
const staticData = {
  games: [
    {
      id: "minecraft-java",
      name: "Minecraft Java",
      description: "The original Minecraft experience with unlimited modding possibilities",
      imageUrl: "/images/games/minecraft.svg",
      minPrice: 2.99,
      maxPrice: 49.99,
      category: "sandbox",
      popularity: 95,
      playerCount: "140M+",
      features: ["Unlimited Mods", "Custom Plugins", "Multiple Versions", "Forge Support"]
    },
    {
      id: "rust",
      name: "Rust",
      description: "Survive, build, and dominate in this hardcore multiplayer survival game",
      imageUrl: "/images/games/rust.svg",
      minPrice: 8.99,
      maxPrice: 89.99,
      category: "survival",
      popularity: 88,
      playerCount: "50M+",
      features: ["Custom Maps", "Oxide Plugins", "Wipe Scheduling", "Admin Tools"]
    },
    {
      id: "cs2",
      name: "Counter-Strike 2",
      description: "The legendary tactical shooter rebuilt on Source 2 engine",
      imageUrl: "/images/games/cs2.svg",
      minPrice: 12.99,
      maxPrice: 99.99,
      category: "fps",
      popularity: 92,
      playerCount: "30M+",
      features: ["Custom Maps", "SourceMod", "Match System", "Anti-Cheat"]
    }
  ],
  
  blogPosts: [
    {
      id: "getting-started",
      title: "Getting Started with Game Server Hosting",
      excerpt: "Learn how to set up your first game server with our comprehensive hosting platform.",
      content: `# Getting Started with Game Server Hosting

Welcome to the world of game server hosting! Whether you're looking to create a private server for friends or build a thriving gaming community, this guide will help you get started.

## Choosing Your Game

The first step is selecting which game you want to host. Popular options include:
- **Minecraft** - Perfect for creative communities
- **Rust** - Great for survival enthusiasts  
- **Counter-Strike 2** - Ideal for competitive players

## Server Specifications

Different games have different requirements:
- **RAM**: 2GB minimum, 8GB+ recommended
- **CPU**: High single-core performance preferred
- **Storage**: SSD recommended for faster loading
- **Bandwidth**: Depends on player count

## Getting Started

1. Choose your game and plan
2. Configure your server settings
3. Install mods or plugins
4. Invite your friends
5. Build your community

Ready to get started? Contact our support team for personalized assistance!`,
      authorName: "GameHost Team",
      publishedAt: "2025-01-15",
      readingTime: 5
    }
  ],
  
  pricingPlans: [
    {
      id: "starter",
      name: "Starter",
      price: 2.99,
      description: "Perfect for small groups of friends",
      features: ["2GB RAM", "Unlimited Slots", "DDoS Protection", "24/7 Support"],
      recommended: false
    },
    {
      id: "pro",
      name: "Pro",
      price: 5.99,
      description: "Ideal for growing communities",
      features: ["4GB RAM", "Unlimited Slots", "DDoS Protection", "Priority Support", "Free Subdomain"],
      recommended: true
    },
    {
      id: "enterprise",
      name: "Enterprise",
      price: 12.99,
      description: "For large communities and networks",
      features: ["8GB RAM", "Unlimited Slots", "DDoS Protection", "Dedicated Support", "Custom Domain", "Advanced Monitoring"],
      recommended: false
    }
  ]
};

// Create static data files
const staticDir = path.join(__dirname, 'client', 'src', 'data');
if (!fs.existsSync(staticDir)) {
  fs.mkdirSync(staticDir, { recursive: true });
}

fs.writeFileSync(
  path.join(staticDir, 'games.json'), 
  JSON.stringify(staticData.games, null, 2)
);

fs.writeFileSync(
  path.join(staticDir, 'blog.json'), 
  JSON.stringify(staticData.blogPosts, null, 2)
);

fs.writeFileSync(
  path.join(staticDir, 'pricing.json'), 
  JSON.stringify(staticData.pricingPlans, null, 2)
);

// Create .htaccess for React routing
const htaccess = `RewriteEngine On
RewriteBase /
RewriteRule ^index\\.html$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]

# Enable compression
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/plain
  AddOutputFilterByType DEFLATE text/html
  AddOutputFilterByType DEFLATE text/xml
  AddOutputFilterByType DEFLATE text/css
  AddOutputFilterByType DEFLATE application/xml
  AddOutputFilterByType DEFLATE application/xhtml+xml
  AddOutputFilterByType DEFLATE application/rss+xml
  AddOutputFilterByType DEFLATE application/javascript
  AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>

# Set cache headers
<IfModule mod_expires.c>
  ExpiresActive on
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>`;

fs.writeFileSync(path.join(__dirname, 'client', 'public', '.htaccess'), htaccess);

console.log('✅ Static version created!');
console.log('\nNext steps:');
console.log('1. cd client && npm run build');
console.log('2. Upload contents of client/dist/ to your public_html folder');
console.log('3. Ensure .htaccess file is uploaded for proper routing');
console.log('\n⚠️  Note: Admin panel and dynamic features will not work in static version');