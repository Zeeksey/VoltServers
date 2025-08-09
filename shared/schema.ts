import { sql } from "drizzle-orm";
import { pgTable, text, varchar, integer, decimal, boolean, timestamp, jsonb, index, bigint } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
  isAdmin: boolean("is_admin").notNull().default(false),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const adminSessions = pgTable("admin_sessions", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  userId: varchar("user_id").notNull(),
  token: text("token").notNull().unique(),
  expiresAt: timestamp("expires_at").notNull(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const siteSettings = pgTable("site_settings", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  key: text("key").notNull().unique(),
  value: text("value").notNull(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const promoSettings = pgTable("promo_settings", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  isEnabled: boolean("is_enabled").notNull().default(true),
  message: text("message").notNull(),
  linkText: text("link_text"),
  linkUrl: text("link_url"),
  backgroundColor: text("background_color").notNull().default("#22c55e"),
  textColor: text("text_color").notNull().default("#ffffff"),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const faqCategories = pgTable("faq_categories", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title").notNull(),
  slug: text("slug").notNull().unique(),
  description: text("description"),
  sortOrder: integer("sort_order").notNull().default(0),
  isVisible: boolean("is_visible").notNull().default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const faqItems = pgTable("faq_items", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  categoryId: varchar("category_id").notNull(),
  question: text("question").notNull(),
  answer: text("answer").notNull(),
  sortOrder: integer("sort_order").notNull().default(0),
  isVisible: boolean("is_visible").notNull().default(true),
  tags: text("tags").array().default(sql`'{}'::text[]`),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const games = pgTable("games", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  name: text("name").notNull(),
  slug: text("slug").notNull().unique(),
  description: text("description").notNull(),
  imageUrl: text("image_url").notNull(),
  basePrice: decimal("base_price", { precision: 10, scale: 2 }).notNull(),
  playerCount: integer("player_count").notNull().default(0),
  isPopular: boolean("is_popular").notNull().default(false),
  isNew: boolean("is_new").notNull().default(false),
  isTrending: boolean("is_trending").notNull().default(false),
  // Game page content
  heroTitle: text("hero_title"),
  heroSubtitle: text("hero_subtitle"),
  heroImageUrl: text("hero_image_url"),
  features: text("features").array().default(sql`'{}'::text[]`),
  // Enhanced game properties
  category: text("category").notNull().default("survival"),
  minRam: text("min_ram").notNull().default("2GB"),
  recommendedRam: text("recommended_ram").notNull().default("4GB"), 
  setupComplexity: text("setup_complexity").notNull().default("Easy"),
  pricingPlans: jsonb("pricing_plans").default(sql`'[]'::jsonb`),

  detailedDescription: text("detailed_description"),
  systemRequirements: text("system_requirements"),
  supportInfo: text("support_info"),
  pageStructure: text("page_structure"), // JSON string for page builder structure
});

// Game page sections for customization
export const gamePageSections = pgTable("game_page_sections", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  gameId: varchar("game_id").notNull(),
  sectionType: text("section_type").notNull(), // "hero", "features", "pricing", "faq", "cta", "testimonials", "versions", "custom"
  title: text("title"),
  subtitle: text("subtitle"),
  content: jsonb("content").default(sql`'{}'::jsonb`), // Flexible content structure
  isEnabled: boolean("is_enabled").notNull().default(true),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

// Game pricing tiers for customization
export const gamePricingTiers = pgTable("game_pricing_tiers", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  gameId: varchar("game_id").notNull(),
  name: text("name").notNull(),
  description: text("description"),
  players: integer("players"),
  ram: text("ram"),
  storage: text("storage"),
  monthlyPrice: decimal("monthly_price", { precision: 10, scale: 2 }).notNull(),
  biannualPrice: decimal("biannual_price", { precision: 10, scale: 2 }),
  annualPrice: decimal("annual_price", { precision: 10, scale: 2 }),
  features: text("features").array().default(sql`'{}'::text[]`),
  isPopular: boolean("is_popular").notNull().default(false),
  isEnabled: boolean("is_enabled").notNull().default(true),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const incidents = pgTable("incidents", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title").notNull(),
  description: text("description").notNull(),
  status: text("status").notNull().default("resolved"), // "resolved", "completed", "ongoing"
  impact: text("impact").notNull().default("minor"), // "none", "minor", "major"
  duration: text("duration").notNull(),
  affectedServices: text("affected_services").array().default(sql`'{}'::text[]`),
  incidentDate: timestamp("incident_date").notNull().defaultNow(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

// Types for incidents
export type Incident = typeof incidents.$inferSelect;
export type InsertIncident = typeof incidents.$inferInsert;
export const insertIncidentSchema = createInsertSchema(incidents);

// Newsletter subscriptions
export const newsletterSubscriptions = pgTable("newsletter_subscriptions", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  email: text("email").notNull().unique(),
  isActive: boolean("is_active").notNull().default(true),
  subscribedAt: timestamp("subscribed_at").notNull().defaultNow(),
  unsubscribedAt: timestamp("unsubscribed_at"),
});

export type NewsletterSubscription = typeof newsletterSubscriptions.$inferSelect;
export type InsertNewsletterSubscription = typeof newsletterSubscriptions.$inferInsert;
export const insertNewsletterSubscriptionSchema = createInsertSchema(newsletterSubscriptions);

// Game features for customization
export const gameFeatures = pgTable("game_features", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  gameId: varchar("game_id").notNull(),
  icon: text("icon"), // Lucide icon name
  title: text("title").notNull(),
  description: text("description").notNull(),
  isEnabled: boolean("is_enabled").notNull().default(true),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const pricingPlans = pgTable("pricing_plans", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  name: text("name").notNull(),
  price: decimal("price", { precision: 10, scale: 2 }).notNull(),
  maxPlayers: integer("max_players"),
  ram: text("ram").notNull(),
  storage: text("storage").notNull(),
  features: text("features").array().notNull(),
  isPopular: boolean("is_popular").notNull().default(false),
});

export const serverStatus = pgTable("server_status", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  service: text("service").notNull(),
  status: text("status").notNull(), // "operational", "degraded", "down"
  responseTime: integer("response_time"), // in milliseconds
  uptime: decimal("uptime", { precision: 5, scale: 2 }), // percentage
  lastChecked: timestamp("last_checked").notNull().defaultNow(),
});

// Demo servers for the demo section
export const demoServers = pgTable("demo_servers", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  serverName: text("server_name").notNull(),
  gameType: text("game_type").notNull(), // "minecraft", "cs2", "rust", etc.
  serverIp: text("server_ip").notNull(),
  serverPort: integer("server_port").notNull(),
  maxPlayers: integer("max_players").notNull().default(100),
  description: text("description").notNull(),
  version: text("version"),
  gameMode: text("game_mode"),
  platform: text("platform").default("PC"), // "PC", "Console", "Crossplay"
  isEnabled: boolean("is_enabled").notNull().default(true),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const serverLocations = pgTable("server_locations", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  city: text("city").notNull(),
  country: text("country").notNull(),
  region: text("region").notNull(),
  provider: text("provider").notNull(),
  ipAddress: text("ip_address").notNull(),
  status: text("status").notNull().default("online"),
  ping: integer("ping").default(0),
});

export const minecraftTools = pgTable("minecraft_tools", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  toolType: text("tool_type").notNull(), // "server_query", "skin_viewer", "uuid_converter", "color_generator"
  name: text("name").notNull(),
  description: text("description").notNull(),
  icon: text("icon").notNull(),
});

// Advanced Minecraft server management tables
export const minecraftServers = pgTable("minecraft_servers", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  userId: varchar("user_id").notNull(),
  serverName: text("server_name").notNull(),
  serverType: text("server_type").notNull(), // vanilla, spigot, paper, forge, fabric
  version: text("version").notNull(),
  ipAddress: text("ip_address"),
  port: integer("port").default(25565),
  maxPlayers: integer("max_players").default(20),
  currentPlayers: integer("current_players").default(0),
  status: text("status").notNull().default("offline"), // online, offline, starting, stopping
  motd: text("motd"),
  difficulty: text("difficulty").default("normal"), // peaceful, easy, normal, hard
  gamemode: text("gamemode").default("survival"), // survival, creative, adventure, spectator
  pvpEnabled: boolean("pvp_enabled").default(true),
  allowFlight: boolean("allow_flight").default(false),
  enableWhitelist: boolean("enable_whitelist").default(false),
  lastOnline: timestamp("last_online"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const minecraftPlugins = pgTable("minecraft_plugins", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  serverId: varchar("server_id").notNull(),
  pluginName: text("plugin_name").notNull(),
  version: text("version").notNull(),
  description: text("description"),
  author: text("author"),
  isEnabled: boolean("is_enabled").default(true),
  downloadUrl: text("download_url"),
  configData: jsonb("config_data"),
  installedAt: timestamp("installed_at").defaultNow(),
});

export const minecraftWorlds = pgTable("minecraft_worlds", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  serverId: varchar("server_id").notNull(),
  worldName: text("world_name").notNull(),
  worldType: text("world_type").default("default"), // default, flat, amplified, buffet
  seed: text("seed"),
  difficulty: text("difficulty").default("normal"),
  gamemode: text("gamemode").default("survival"),
  generateStructures: boolean("generate_structures").default(true),
  allowNether: boolean("allow_nether").default(true),
  allowEnd: boolean("allow_end").default(true),
  spawnProtection: integer("spawn_protection").default(16),
  viewDistance: integer("view_distance").default(10),
  sizeBytes: bigint("size_bytes", { mode: "number" }),
  lastBackup: timestamp("last_backup"),
  createdAt: timestamp("created_at").defaultNow(),
});

export const minecraftPlayers = pgTable("minecraft_players", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  serverId: varchar("server_id").notNull(),
  playerName: text("player_name").notNull(),
  uuid: text("uuid").notNull(),
  isWhitelisted: boolean("is_whitelisted").default(false),
  isBanned: boolean("is_banned").default(false),
  isOp: boolean("is_op").default(false),
  lastSeen: timestamp("last_seen"),
  playtime: integer("playtime").default(0), // in minutes
  joinCount: integer("join_count").default(0),
  firstJoin: timestamp("first_join").defaultNow(),
});

export const minecraftBackups = pgTable("minecraft_backups", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  serverId: varchar("server_id").notNull(),
  worldId: varchar("world_id"),
  backupName: text("backup_name").notNull(),
  backupType: text("backup_type").notNull(), // full, world, config
  sizeBytes: bigint("size_bytes", { mode: "number" }),
  filePath: text("file_path"),
  status: text("status").default("completed"), // pending, in_progress, completed, failed
  createdAt: timestamp("created_at").defaultNow(),
});

export const minecraftLogs = pgTable("minecraft_logs", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  serverId: varchar("server_id").notNull(),
  logLevel: text("log_level").notNull(), // INFO, WARN, ERROR, DEBUG
  message: text("message").notNull(),
  source: text("source"), // plugin name or system component
  timestamp: timestamp("timestamp").defaultNow(),
});

export const blogPosts = pgTable("blog_posts", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title").notNull(),
  slug: text("slug").notNull().unique(),
  excerpt: text("excerpt").notNull(),
  content: text("content").notNull(),
  imageUrl: text("image_url").notNull(),
  author: text("author").notNull(),
  publishedAt: timestamp("published_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
  tags: text("tags").array().notNull(),
  isPublished: boolean("is_published").notNull().default(true),
});

export const gamePages = pgTable("game_pages", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  gameId: varchar("game_id").notNull(),
  features: text("features").array().notNull(),
  requirements: text("requirements").array().notNull(),
  mods: text("mods").array().notNull(),
  screenshots: text("screenshots").array().notNull(),
  setupGuide: text("setup_guide").notNull(),
  faq: text("faq").array().notNull(),
  relatedArticles: text("related_articles").array().default(sql`'{}'::text[]`), // Array of blog post slugs
  customSections: jsonb("custom_sections").default(sql`'[]'::jsonb`), // Custom admin-defined sections
  lastUpdated: timestamp("last_updated").defaultNow(),
});





export const pricingDetails = pgTable("pricing_details", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  planId: varchar("plan_id").notNull(),
  gameId: varchar("game_id").notNull(),
  customPrice: decimal("custom_price", { precision: 10, scale: 2 }),
  gameSpecificFeatures: text("game_specific_features").array().notNull(),
  limitations: text("limitations").array().notNull(),
});

// Insert schemas
export const insertUserSchema = createInsertSchema(users).omit({
  id: true,
  createdAt: true,
});

export const insertAdminSessionSchema = createInsertSchema(adminSessions).omit({
  id: true,
  createdAt: true,
});

export const insertSiteSettingSchema = createInsertSchema(siteSettings).omit({
  id: true,
  updatedAt: true,
});

export const insertPromoSettingSchema = createInsertSchema(promoSettings).omit({
  id: true,
  updatedAt: true,
});



export const insertFaqCategorySchema = createInsertSchema(faqCategories).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertFaqItemSchema = createInsertSchema(faqItems).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertGameSchema = createInsertSchema(games).omit({
  id: true,
});

export const insertPricingPlanSchema = createInsertSchema(pricingPlans).omit({
  id: true,
});

export const insertServerStatusSchema = createInsertSchema(serverStatus).omit({
  id: true,
});

export const insertServerLocationSchema = createInsertSchema(serverLocations).omit({
  id: true,
});

export const insertMinecraftToolSchema = createInsertSchema(minecraftTools).omit({
  id: true,
});

export const insertBlogPostSchema = createInsertSchema(blogPosts).omit({
  id: true,
  publishedAt: true,
});

export const insertGamePageSchema = createInsertSchema(gamePages).omit({
  id: true,
});



export const insertPricingDetailSchema = createInsertSchema(pricingDetails).omit({
  id: true,
});

// Minecraft management schemas
export const insertMinecraftServerSchema = createInsertSchema(minecraftServers).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertMinecraftPluginSchema = createInsertSchema(minecraftPlugins).omit({
  id: true,
  installedAt: true,
});

export const insertMinecraftWorldSchema = createInsertSchema(minecraftWorlds).omit({
  id: true,
  createdAt: true,
});

export const insertMinecraftPlayerSchema = createInsertSchema(minecraftPlayers).omit({
  id: true,
  firstJoin: true,
});

export const insertMinecraftBackupSchema = createInsertSchema(minecraftBackups).omit({
  id: true,
  createdAt: true,
});

export const insertMinecraftLogSchema = createInsertSchema(minecraftLogs).omit({
  id: true,
  timestamp: true,
});

// Types
export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;

export type InsertAdminSession = z.infer<typeof insertAdminSessionSchema>;
export type AdminSession = typeof adminSessions.$inferSelect;

export type InsertSiteSetting = z.infer<typeof insertSiteSettingSchema>;
export type SiteSetting = typeof siteSettings.$inferSelect;

export type InsertPromoSetting = z.infer<typeof insertPromoSettingSchema>;
export type PromoSetting = typeof promoSettings.$inferSelect;

export type InsertFaqCategory = z.infer<typeof insertFaqCategorySchema>;
export type FaqCategory = typeof faqCategories.$inferSelect;

export type InsertFaqItem = z.infer<typeof insertFaqItemSchema>;
export type FaqItem = typeof faqItems.$inferSelect;

export type InsertGame = z.infer<typeof insertGameSchema>;
export type Game = typeof games.$inferSelect;

export type InsertPricingPlan = z.infer<typeof insertPricingPlanSchema>;
export type PricingPlan = typeof pricingPlans.$inferSelect;

export type InsertServerStatus = z.infer<typeof insertServerStatusSchema>;
export type ServerStatus = typeof serverStatus.$inferSelect;

export type InsertServerLocation = z.infer<typeof insertServerLocationSchema>;
export type ServerLocation = typeof serverLocations.$inferSelect;

export type InsertMinecraftTool = z.infer<typeof insertMinecraftToolSchema>;
export type MinecraftTool = typeof minecraftTools.$inferSelect;

export type InsertBlogPost = z.infer<typeof insertBlogPostSchema>;
export type BlogPost = typeof blogPosts.$inferSelect;

// Demo servers
export const insertDemoServerSchema = createInsertSchema(demoServers).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});
export type InsertDemoServer = z.infer<typeof insertDemoServerSchema>;
export type DemoServer = typeof demoServers.$inferSelect;

export type InsertGamePage = z.infer<typeof insertGamePageSchema>;
export type GamePage = typeof gamePages.$inferSelect;

// WHMCS Integration Settings
export const whmcsSettings = pgTable("whmcs_settings", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  isEnabled: boolean("is_enabled").notNull().default(false),
  whmcsUrl: varchar("whmcs_url").notNull(),
  identifier: varchar("identifier").notNull(),
  secret: varchar("secret").notNull(),
  accessKey: varchar("access_key"),
  ssoEnabled: boolean("sso_enabled").notNull().default(false),
  autoSync: boolean("auto_sync").notNull().default(false),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

// Theme Customization Settings
export const themeSettings = pgTable("theme_settings", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  siteName: varchar("site_name").notNull().default("VoltServers"),
  siteTagline: varchar("site_tagline").notNull().default("Premium Game Server Hosting"),  
  siteDescription: text("site_description").default("Professional game server hosting with 24/7 support and premium hardware"),
  heroTitle: text("hero_title").default("Deploy Your Game Server in Minutes"),
  heroSubtitle: text("hero_subtitle").default("Experience lightning-fast deployment with our premium game server hosting platform"),
  heroDescription: text("hero_description").default("Experience lightning-fast game servers with 99.9% uptime guarantee. Get your server online in minutes with our one-click deployment system."),
  heroButtonText: varchar("hero_button_text").default("Get Started"),
  heroButtonUrl: varchar("hero_button_url").default("/pricing"),
  primaryColor: varchar("primary_color").notNull().default("#00ff88"),
  secondaryColor: varchar("secondary_color").notNull().default("#1a1a1a"),
  accentColor: varchar("accent_color").notNull().default("#00cc6a"),
  backgroundColor: varchar("background_color").notNull().default("#0a0a0a"),
  textColor: varchar("text_color").notNull().default("#ffffff"),
  logoUrl: varchar("logo_url"),
  faviconUrl: varchar("favicon_url"),
  footerText: text("footer_text"),
  fontFamily: varchar("font_family").notNull().default("Inter"),
  borderRadius: varchar("border_radius").notNull().default("0.5rem"),
  holidayTheme: varchar("holiday_theme").default("none"), // none, snow, halloween, easter, christmas
  customCss: text("custom_css"),
  // SEO & Meta Tags
  metaTitle: varchar("meta_title"),
  metaDescription: text("meta_description"),
  metaKeywords: text("meta_keywords"),
  ogTitle: varchar("og_title"),
  ogDescription: text("og_description"),
  ogImage: varchar("og_image"),
  twitterCard: varchar("twitter_card").default("summary_large_image"),
  twitterSite: varchar("twitter_site"),
  // Analytics & Tracking
  googleAnalyticsId: varchar("google_analytics_id"),
  googleTagManagerId: varchar("google_tag_manager_id"),
  facebookPixelId: varchar("facebook_pixel_id"),
  customHeadCode: text("custom_head_code"),
  customBodyCode: text("custom_body_code"),
  // Site Management
  maintenanceMode: boolean("maintenance_mode").default(false),
  maintenanceMessage: text("maintenance_message").default("We're currently performing maintenance. Please check back soon!"),
  announcementBanner: text("announcement_banner"),
  announcementType: varchar("announcement_type").default("info"),
  showAnnouncementBanner: boolean("show_announcement_banner").default(false),
  // Cookie Policy Settings
  showCookieBanner: boolean("show_cookie_banner").default(true),
  cookieConsentRequired: boolean("cookie_consent_required").default(true),
  cookiePolicyText: text("cookie_policy_text").default("We use cookies to enhance your experience and analyze site traffic."),
  cookiePolicyUrl: text("cookie_policy_url").default("/privacy-policy"),
  cookieCategories: text("cookie_categories").default(JSON.stringify([
    { id: "necessary", name: "Necessary", description: "Essential for website functionality", required: true },
    { id: "analytics", name: "Analytics", description: "Help us understand how visitors use our site", required: false },
    { id: "marketing", name: "Marketing", description: "Used to deliver relevant advertisements", required: false }
  ])),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

// Custom Pages
export const customPages = pgTable("custom_pages", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: varchar("title").notNull(),
  slug: varchar("slug").notNull().unique(),
  content: text("content").notNull(),
  metaDescription: varchar("meta_description"),
  isPublished: boolean("is_published").notNull().default(false),
  showInNav: boolean("show_in_nav").notNull().default(false),
  sortOrder: integer("sort_order").notNull().default(0),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

// Navigation Menu Items
export const navigationItems = pgTable("navigation_items", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  label: varchar("label").notNull(),
  url: varchar("url").notNull(),
  icon: varchar("icon"),
  parentId: varchar("parent_id"),
  sortOrder: integer("sort_order").notNull().default(0),
  isExternal: boolean("is_external").notNull().default(false),
  isVisible: boolean("is_visible").notNull().default(true),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export type WHMCSSettings = typeof whmcsSettings.$inferSelect;
export type InsertWHMCSSettings = typeof whmcsSettings.$inferInsert;
export type ThemeSettings = typeof themeSettings.$inferSelect;
export type InsertThemeSettings = typeof themeSettings.$inferInsert;
export type CustomPage = typeof customPages.$inferSelect;
export type InsertCustomPage = typeof customPages.$inferInsert;
export type NavigationItem = typeof navigationItems.$inferSelect;
export type InsertNavigationItem = typeof navigationItems.$inferInsert;

export type InsertPricingDetail = z.infer<typeof insertPricingDetailSchema>;
export type PricingDetail = typeof pricingDetails.$inferSelect;

// Minecraft management types
export type InsertMinecraftServer = z.infer<typeof insertMinecraftServerSchema>;
export type MinecraftServer = typeof minecraftServers.$inferSelect;

export type InsertMinecraftPlugin = z.infer<typeof insertMinecraftPluginSchema>;
export type MinecraftPlugin = typeof minecraftPlugins.$inferSelect;

export type InsertMinecraftWorld = z.infer<typeof insertMinecraftWorldSchema>;
export type MinecraftWorld = typeof minecraftWorlds.$inferSelect;

export type InsertMinecraftPlayer = z.infer<typeof insertMinecraftPlayerSchema>;
export type MinecraftPlayer = typeof minecraftPlayers.$inferSelect;

export type InsertMinecraftBackup = z.infer<typeof insertMinecraftBackupSchema>;
export type MinecraftBackup = typeof minecraftBackups.$inferSelect;

export type InsertMinecraftLog = z.infer<typeof insertMinecraftLogSchema>;
export type MinecraftLog = typeof minecraftLogs.$inferSelect;

// Game customization schemas
export const insertGamePageSectionSchema = createInsertSchema(gamePageSections).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertGamePricingTierSchema = createInsertSchema(gamePricingTiers).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const insertGameFeatureSchema = createInsertSchema(gameFeatures).omit({
  id: true,
  createdAt: true,
});

// Game customization types
export type InsertGamePageSection = z.infer<typeof insertGamePageSectionSchema>;
export type GamePageSection = typeof gamePageSections.$inferSelect;

export type InsertGamePricingTier = z.infer<typeof insertGamePricingTierSchema>;
export type GamePricingTier = typeof gamePricingTiers.$inferSelect;

export type InsertGameFeature = z.infer<typeof insertGameFeatureSchema>;
export type GameFeature = typeof gameFeatures.$inferSelect;

// Types for newsletter subscriptions
export type InsertNewsletterSubscription = z.infer<typeof insertNewsletterSubscriptionSchema>;
export type NewsletterSubscription = typeof newsletterSubscriptions.$inferSelect;
