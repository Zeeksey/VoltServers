# Overview

VoltServers is a full-stack game server hosting platform providing a comprehensive interface for users to browse games, view pricing, check server status, and manage game servers. The platform features a gaming-themed design with dedicated pages for organization and user experience. It includes professional enterprise features, service management dashboards, a Shockbyte-inspired Minecraft hosting page, and robust integration with WHMCS for client portal functionality, support tickets, account management, and dynamic product pricing. Key capabilities include individual game pages with detailed hosting information, individual blog posts, hardware specifications, an about page, support center, and contact information.

## Recent Changes (August 2025)
- Successfully integrated WHMCS API with IP whitelisting (104.196.223.28)
- Fixed games flashing issue with improved React Query caching
- Configured Vercel deployment with optimized build process
- Added comprehensive environment variable configuration
- Implemented VS Code Git integration for GitHub uploads
- **Ubuntu Server Deployment Support (August 2025)**: Created comprehensive Ubuntu deployment guide with automated setup script for dedicated server hosting. Includes complete server configuration with PostgreSQL, Nginx reverse proxy, SSL certificates, PM2 process manager, security hardening, monitoring, and automated backups. Features one-command deployment script that handles system updates, firewall configuration, database setup, application deployment, and SSL certificate installation. Supports both domain-based and IP-based deployments with production-ready configuration.
- **Major Admin Panel Enhancement**: Expanded game customization with 8 comprehensive component types (Hero, Features, Pricing, Gallery, Testimonials, FAQ, CTA, Server Specs), full content and style editing capabilities, tabbed interface for better UX, and enhanced save/update functionality with proper cache invalidation
- **Pricing Management System**: Added dedicated pricing plan management interface in admin dashboard with ability to add/edit pricing plans for each game, improved discount text visibility with proper styling for biannual/annual savings, enhanced admin customization cache invalidation to ensure page updates reflect properly after saving changes
- **VoltServers Layout Integration**: Restructured game pages to match VoltServers.com's exact structure with left-aligned hero sections, professional billing cycle selector with 4 periods (Monthly/Quarterly/Semi-Annually/Annually), VoltServers-style 5-column features grid, enhanced Shockbyte-inspired admin customization options including advanced server management features, performance monitoring, and modpack support
- **Enhanced Game Template System (Latest January 2025)**: Complete game management overhaul with easy-to-use admin interface for editing names, images, features, pricing, and all game properties. Added Quick Start Templates for popular games (Minecraft, Rust, ARK, Valheim, CS2) with pre-configured settings. Enhanced form fields include hero subtitle, game features list, category selection, RAM requirements, setup complexity, and comprehensive game customization. Template system allows creating new games with consistent structure and professional content.
- **100% Customizable Game Pages (August 2025)**: Implemented comprehensive admin template editor allowing complete customization of game pages without code changes. Features include drag-and-drop section management, real-time pricing configuration, hero customization, features management, and full WHMCS integration for automated billing. Fixed "Most Popular" banner z-index visibility issue on game pages for better user experience.
- **Navigation System Fix**: Resolved critical "Illegal constructor" error by creating NavigationNew component with simplified scroll functions, ensuring cross-browser compatibility and stable performance across all game pages.
- **Comprehensive Game Page Editor (August 2025)**: Created intuitive admin game editor replacing complex inline forms with a user-friendly tabbed interface. Features include Basic Info tab for core details, Hero Section customization, complete Pricing Plans management with multiple billing periods, Features & Settings configuration, Quick Start Templates for popular games (Minecraft, Rust, Valheim), real-time preview functionality, and streamlined save process. Eliminates need for technical knowledge while providing full game page customization capabilities.
- **Streamlined Admin Dashboard (August 2025)**: Completely redesigned admin panel with full site integration including navigation bar and footer. Removed unused features (old pricing plans, deprecated create game page) while preserving essential functionality. Added comprehensive management for demo servers, server locations, and theme settings with working color picker and live preview. Clean tabbed interface focuses on core features: Games, Blog Posts, Demo Servers, Locations, and Theme customization.
- **Security & Privacy Improvements (August 2025)**: Removed server IP addresses and player counts from hardware and status pages for enhanced security. Updated Virginia server location to "Vinthill, Virginia" across the platform for consistency.
- **Incidents Management System (August 2025)**: Implemented comprehensive incidents management with database integration, fallback data for reliability, and dynamic loading on status page. Added recent events display with proper status badges, impact indicators, and duration tracking.
- **Newsletter Subscription System (August 2025)**: Created functional newsletter subscription system for status updates with email validation, duplicate prevention, and database storage. Integrated into status page with clean UI.
- **Enhanced Hero & CTA Customization (August 2025)**: Fixed "Watch Demo" button customization through admin panel. Added complete Hero Section settings (primary button text/URL, demo button text/URL) and Call-to-Action settings (title, description, button text/URL) to theme configuration. Expanded admin dashboard with dedicated sections for hero and CTA customization.
- **Professional Blog Content System (August 2025)**: Created comprehensive, structured blog posts tailored to gaming server hosting industry. Fixed "View all articles" button navigation to properly redirect to /knowledgebase page. Optimized knowledge base tabs for mobile with responsive grid layout (stacked on mobile, 3-column on desktop). Enhanced mobile button styling with proper spacing, improved tab text readability, and comprehensive CSS optimizations. Added professional blog posts including Ultimate Minecraft Server Setup Guide 2025, Rust Server Optimization Performance Guide, ARK Server Administration Complete Guide, and DDoS Protection Security Guide with detailed technical content, code examples, and actionable advice.
- **Comprehensive SEO Optimization (August 2025)**: Implemented advanced SEO system with dynamic meta tag management, structured data markup, and comprehensive search engine optimization. Created custom SEOHead component for dynamic meta tag updates across all pages. Enhanced HTML meta tags with proper Open Graph, Twitter Card, and structured data integration. Added robots.txt and sitemap.xml for improved crawling. Optimized page titles, descriptions, and keywords for gaming server hosting industry. Added JSON-LD structured data for Organization, Product, and Article schemas. Improved social media sharing with proper image meta tags and enhanced search engine visibility with comprehensive keyword optimization.

# User Preferences

Preferred communication style: Simple, everyday language.
Server Management Style: Simple server overview with direct link to Wisp.gg game panel - no complex controls or tabs interface.
Deployment Platform: Vercel (switched from Render for better build support)
Development Environment: Windows with VS Code and GitHub integration

# System Architecture

## Frontend Architecture
The client-side is built with React and TypeScript, using Vite for development and build. UI components are from shadcn/ui (built on Radix UI primitives) and styled with Tailwind CSS, following a custom gaming theme. Wouter is used for client-side routing, and TanStack Query for data fetching and caching. The design follows a component-based architecture. Content is organized into dedicated pages like `/enterprise`, `/dashboard`, `/client-portal`, `/minecraft`, `/knowledgebase`, and `/contact` to improve navigation.

## Backend Architecture
The server is implemented using Express.js with TypeScript, following a RESTful API design pattern. It uses an in-memory storage implementation with interfaces designed for easy migration to persistent storage. Routes are organized by resource type with consistent error handling.

## Database Layer
The application uses Drizzle ORM with PostgreSQL as the target database, currently implementing an in-memory storage pattern. The schema is well-defined with proper typing, including tables for users, games, pricing plans, server status, server locations, Minecraft tools, game page sections, features, and plans.

## Data Management
State management uses TanStack Query for server state and React's built-in state for UI state. Data flows from backend REST endpoints to frontend components, with proper loading states and error boundaries.

## UI/UX Design System
A comprehensive design system uses shadcn/ui components with a custom gaming theme. Color schemes include gaming-specific variables and support light/dark modes. The design emphasizes visual hierarchy, responsive layouts, and accessible interactions.

## Development Tooling
The project uses TypeScript for type safety, ESLint for code quality, and Vite for fast development builds.

# External Dependencies

## Core Framework Dependencies
- **React**: Frontend framework
- **Express.js**: Backend web framework
- **Vite**: Development build tool
- **Wouter**: Client-side routing

## Database and ORM
- **Drizzle ORM**: Type-safe SQL toolkit
- **@neondatabase/serverless**: PostgreSQL driver
- **Drizzle-kit**: Database migration tools

## UI and Styling
- **Tailwind CSS**: Utility-first CSS framework
- **Radix UI**: Headless component library
- **shadcn/ui**: Component library based on Radix UI
- **Lucide React**: Icon library
- **class-variance-authority**: Utility for variant-based components

## Data Fetching and State Management
- **TanStack Query**: Server state management
- **React Hook Form**: Form handling with validation

## Development and Build Tools
- **TypeScript**: Static type checking
- **esbuild**: JavaScript bundler
- **PostCSS**: CSS processing

## Additional Utilities
- **date-fns**: Date manipulation
- **clsx**: Conditional className utility
- **nanoid**: Unique ID generation
- **zod**: Runtime type validation