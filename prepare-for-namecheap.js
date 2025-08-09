#!/usr/bin/env node

/**
 * Prepare the website for NameCheap shared hosting deployment
 */

const fs = require('fs');
const path = require('path');

console.log('🔄 Preparing website for NameCheap shared hosting...');

// 1. First, create a static data provider component to replace API calls
const staticDataProvider = `import React, { createContext, useContext, ReactNode } from 'react';

// Static data that replaces API calls
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
      features: ["Unlimited Mods", "Custom Plugins", "Multiple Versions", "Forge Support"],
      plans: [
        { name: "Starter", price: 2.99, ram: "2GB", features: ["2GB RAM", "Unlimited Slots", "DDoS Protection"] },
        { name: "Pro", price: 5.99, ram: "4GB", features: ["4GB RAM", "Priority Support", "Free Subdomain"] },
        { name: "Enterprise", price: 12.99, ram: "8GB", features: ["8GB RAM", "Dedicated Support", "Custom Domain"] }
      ]
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
      features: ["Custom Maps", "Oxide Plugins", "Wipe Scheduling", "Admin Tools"],
      plans: [
        { name: "Starter", price: 8.99, ram: "4GB", features: ["4GB RAM", "Oxide Support", "DDoS Protection"] },
        { name: "Pro", price: 15.99, ram: "8GB", features: ["8GB RAM", "Custom Maps", "Priority Support"] },
        { name: "Enterprise", price: 29.99, ram: "16GB", features: ["16GB RAM", "Dedicated IP", "24/7 Support"] }
      ]
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
      features: ["Custom Maps", "SourceMod", "Match System", "Anti-Cheat"],
      plans: [
        { name: "Starter", price: 12.99, ram: "4GB", features: ["4GB RAM", "SourceMod", "Custom Maps"] },
        { name: "Pro", price: 19.99, ram: "8GB", features: ["8GB RAM", "Match System", "Stats Tracking"] },
        { name: "Tournament", price: 39.99, ram: "16GB", features: ["16GB RAM", "Tournament Mode", "Anti-Cheat Plus"] }
      ]
    }
  ],
  
  blogPosts: [
    {
      id: "getting-started-gamehost-pro",
      title: "Getting Started with GameHost Pro",
      slug: "getting-started-gamehost-pro",
      excerpt: "Learn how to set up your first game server with our comprehensive hosting platform.",
      content: \`# Getting Started with GameHost Pro

Welcome to GameHost Pro! This comprehensive guide will help you get started with your first game server.

## Choosing Your Game

Select from our popular game offerings:
- **Minecraft Java** - Perfect for creative communities and modded experiences
- **Rust** - Ideal for survival enthusiasts who love PvP action  
- **Counter-Strike 2** - Great for competitive FPS tournaments

## Server Requirements

Different games need different specifications:

### Minecraft Java
- **Minimum RAM**: 2GB for vanilla, 4GB+ for modded
- **CPU**: High single-core performance
- **Storage**: SSD recommended for faster chunk loading
- **Players**: 10-50 depending on RAM

### Rust
- **Minimum RAM**: 4GB for small maps, 8GB+ for large
- **CPU**: Multi-core performance important
- **Storage**: 50GB+ SSD space required
- **Players**: 50-200 depending on map size

### Counter-Strike 2
- **Minimum RAM**: 2GB for casual, 4GB+ for competitive
- **CPU**: High frequency preferred
- **Storage**: 30GB+ for maps and mods
- **Players**: 10-64 depending on game mode

## Getting Started Steps

1. **Choose Your Plan**: Select the right server specifications for your game
2. **Configure Settings**: Set up game-specific options and rules
3. **Install Mods/Plugins**: Add functionality to enhance gameplay
4. **Invite Players**: Share your server details with friends
5. **Monitor Performance**: Use our dashboard to track server health

## Support Resources

- 24/7 Live Chat Support
- Comprehensive Knowledge Base
- Video Tutorials  
- Community Discord Server

Ready to start your gaming community? Contact our support team for personalized assistance!\`,
      authorName: "GameHost Team",
      publishedAt: "2025-01-15T10:00:00Z",
      isPublished: true,
      tags: ["tutorial", "getting-started"],
      readingTime: 5
    },
    {
      id: "minecraft-server-optimization",
      title: "Minecraft Server Optimization Guide", 
      slug: "minecraft-server-optimization",
      excerpt: "Maximize your Minecraft server performance with these proven optimization techniques.",
      content: \`# Minecraft Server Optimization Guide

Running a smooth Minecraft server requires careful optimization. Here's our complete guide to getting the best performance.

## Hardware Optimization

### CPU Requirements
- **Single-core performance** is most important for Minecraft
- Intel i5/i7 or AMD Ryzen 5/7 recommended
- Clock speed matters more than core count

### Memory (RAM) Guidelines
- **Vanilla Minecraft**: 2-4GB minimum
- **Modded (Light)**: 4-6GB recommended  
- **Modded (Heavy)**: 8-12GB or more
- **Never allocate all available RAM** - leave 2GB for the OS

### Storage Considerations
- **SSD is essential** for world loading performance
- NVMe drives provide best results for large worlds
- Regular world backups to separate storage

## Server Software Optimization

### Choose the Right Server Software
- **Paper**: Best performance for vanilla and plugin servers
- **Fabric**: Excellent for modded servers with performance mods
- **Forge**: Traditional choice for modded servers

### Key Configuration Settings

#### server.properties
\\\`\\\`\\\`
view-distance=8
simulation-distance=6
max-players=20
spawn-protection=0
\\\`\\\`\\\`

#### JVM Arguments
\\\`\\\`\\\`
java -Xms4G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -jar server.jar nogui
\\\`\\\`\\\`

## Plugin Optimization

### Essential Performance Plugins
- **ClearLag**: Removes lag-causing entities
- **WorldBorder**: Limits world size to reduce chunk loading
- **LimitPillagers**: Controls mob spawning for better performance

### Avoid Performance-Heavy Plugins
- Complex economy plugins with frequent database writes
- Plugins that scan large areas frequently
- Poorly coded custom plugins

## World Management

### Pre-generate Chunks
Use plugins like WorldBorder to pre-generate your world:
\\\`/wb world set 1000\\\` (sets 1000 block radius)
\\\`/wb fill\\\` (generates all chunks within border)

### Regular Maintenance
- Remove unused chunks with tools like MCASelector
- Clear dropped items and entities periodically
- Monitor world file size growth

## Monitoring and Troubleshooting

### Performance Monitoring Tools
- **Spark Profiler**: Identifies performance bottlenecks
- **Plan Analytics**: Tracks server and player statistics  
- Built-in \\\`/tps\\\` command to check server performance

### Common Issues and Solutions
- **Low TPS**: Reduce view distance, limit entities, optimize plugins
- **High RAM Usage**: Adjust garbage collection, reduce loaded chunks
- **Connection Issues**: Check network settings and firewall rules

Ready to optimize your server? Our support team can help with custom configurations!\`,
      authorName: "GameHost Team",
      publishedAt: "2025-01-10T14:30:00Z",
      isPublished: true,
      tags: ["minecraft", "optimization", "performance"],
      readingTime: 8
    }
  ],
  
  pricingPlans: [
    {
      id: "starter",
      name: "Starter",
      price: 2.99,
      originalPrice: 2.99,
      description: "Perfect for small groups of friends",
      features: ["2GB RAM", "Unlimited Slots", "DDoS Protection", "24/7 Support", "Free Subdomain"],
      recommended: false,
      popular: false
    },
    {
      id: "pro", 
      name: "Pro",
      price: 5.99,
      originalPrice: 5.99,
      description: "Ideal for growing communities",
      features: ["4GB RAM", "Unlimited Slots", "DDoS Protection", "Priority Support", "Free Subdomain", "Plugin Support"],
      recommended: true,
      popular: true
    },
    {
      id: "enterprise",
      name: "Enterprise", 
      price: 12.99,
      originalPrice: 12.99,
      description: "For large communities and networks",
      features: ["8GB RAM", "Unlimited Slots", "DDoS Protection", "Dedicated Support", "Custom Domain", "Advanced Monitoring", "API Access"],
      recommended: false,
      popular: false
    }
  ],

  demoServers: [
    {
      id: "demo-minecraft-1",
      serverName: "SkyBlock Paradise",
      gameId: "minecraft-java",
      serverIp: "play.cubecraft.net",
      serverPort: 25565,
      playerCount: 42,
      maxPlayers: 100,
      isOnline: true,
      version: "1.20.4",
      description: "Experience the ultimate SkyBlock adventure with custom challenges and rewards",
      location: "US East",
      gameType: "SkyBlock"
    },
    {
      id: "demo-minecraft-2",
      serverName: "Survival Nations",
      gameId: "minecraft-java", 
      serverIp: "mc.hypixel.net",
      serverPort: 25565,
      playerCount: 87,
      maxPlayers: 200,
      isOnline: true,
      version: "1.20.4",
      description: "Build your nation and compete with others in this survival multiplayer experience",
      location: "EU West",
      gameType: "Survival"
    }
  ]
};

const StaticDataContext = createContext(staticData);

export const StaticDataProvider = ({ children }: { children: ReactNode }) => {
  return (
    <StaticDataContext.Provider value={staticData}>
      {children}
    </StaticDataContext.Provider>
  );
};

export const useStaticData = () => {
  const context = useContext(StaticDataContext);
  if (!context) {
    throw new Error('useStaticData must be used within a StaticDataProvider');
  }
  return context;
};

// Hooks that replace API calls
export const useGames = () => {
  const { games } = useStaticData();
  return { data: games, isLoading: false, error: null };
};

export const useBlogPosts = () => {
  const { blogPosts } = useStaticData();
  return { data: blogPosts, isLoading: false, error: null };
};

export const usePricingPlans = () => {
  const { pricingPlans } = useStaticData();
  return { data: pricingPlans, isLoading: false, error: null };
};

export const useDemoServers = () => {
  const { demoServers } = useStaticData();
  return { data: demoServers, isLoading: false, error: null };
};

export const useBlogPost = (slug: string) => {
  const { blogPosts } = useStaticData();
  const post = blogPosts.find(p => p.slug === slug);
  return { data: post, isLoading: false, error: post ? null : 'Post not found' };
};`;

// 2. Create the static data provider file
const clientSrcDir = path.join(__dirname, 'client', 'src');
const dataDir = path.join(clientSrcDir, 'lib');

if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

fs.writeFileSync(path.join(dataDir, 'staticData.tsx'), staticDataProvider);

// 3. Create a modified App.tsx that uses static data instead of API calls
const appContent = fs.readFileSync(path.join(clientSrcDir, 'App.tsx'), 'utf8');
const modifiedApp = appContent.replace(
  `import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "@/lib/queryClient";`,
  `import { StaticDataProvider } from "@/lib/staticData";`
).replace(
  `<QueryClientProvider client={queryClient}>`,
  `<StaticDataProvider>`
).replace(
  `</QueryClientProvider>`,
  `</StaticDataProvider>`
);

fs.writeFileSync(path.join(clientSrcDir, 'App.tsx'), modifiedApp);

// 4. Create .htaccess for proper routing on shared hosting
const htaccess = `# Enable mod_rewrite
RewriteEngine On

# Handle React Router routes
RewriteBase /
RewriteRule ^index\\.html$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]

# Compress files for better performance
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

# Set cache headers for static assets
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year" 
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType application/font-woff "access plus 1 year"
    ExpiresByType application/font-woff2 "access plus 1 year"
</IfModule>

# Security headers
<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>`;

fs.writeFileSync(path.join(__dirname, 'client', 'public', '.htaccess'), htaccess);

// 5. Create a contact form that works with shared hosting (using Formspree)
const contactFormHTML = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Form Fallback</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        button { background: #22c55e; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background: #16a34a; }
    </style>
</head>
<body>
    <h2>Contact Us</h2>
    <!-- Replace YOUR_FORM_ID with your actual Formspree form ID -->
    <form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
        <div class="form-group">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name" required>
        </div>
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="subject">Subject:</label>
            <input type="text" id="subject" name="subject" required>
        </div>
        <div class="form-group">
            <label for="message">Message:</label>
            <textarea id="message" name="message" rows="5" required></textarea>
        </div>
        <button type="submit">Send Message</button>
    </form>
</body>
</html>`;

fs.writeFileSync(path.join(__dirname, 'client', 'public', 'contact-form.html'), contactFormHTML);

console.log('✅ Website prepared for NameCheap shared hosting!');
console.log('\\n📋 Next steps:');
console.log('1. Run: cd client && npm run build');
console.log('2. Upload contents of client/dist/ to your NameCheap public_html folder');
console.log('3. Make sure .htaccess file is uploaded for proper routing');
console.log('4. For contact forms, sign up at formspree.io and update contact-form.html');
console.log('\\n⚠️  What will work:');
console.log('   ✅ Complete website with all pages');
console.log('   ✅ Game pages with pricing');
console.log('   ✅ Blog posts (static content)');
console.log('   ✅ Responsive design');
console.log('   ✅ Fast loading times');
console.log('\\n⚠️  What won\\'t work:');
console.log('   ❌ Admin panel (no backend)');
console.log('   ❌ Dynamic content updates');
console.log('   ❌ Contact form (unless you set up Formspree)');
console.log('   ❌ Real-time server monitoring');