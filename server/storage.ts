import { 
  type Game, 
  type InsertGame,
  type PricingPlan,
  type InsertPricingPlan,
  type ServerStatus,
  type InsertServerStatus,
  type ServerLocation,
  type InsertServerLocation,
  type MinecraftTool,
  type InsertMinecraftTool,
  type User, 
  type InsertUser,
  type BlogPost,
  type InsertBlogPost,
  type GamePage,
  type InsertGamePage,
  type DemoServer,
  type InsertDemoServer,
  type PricingDetail,
  type InsertPricingDetail,
  type AdminSession,
  type InsertAdminSession,
  type SiteSetting,
  type InsertSiteSetting,
  type PromoSetting,
  type InsertPromoSetting,
  type MinecraftServer,
  type InsertMinecraftServer,
  type MinecraftPlugin,
  type InsertMinecraftPlugin,
  type MinecraftWorld,
  type InsertMinecraftWorld,
  type MinecraftPlayer,
  type InsertMinecraftPlayer,
  type MinecraftBackup,
  type InsertMinecraftBackup,
  type MinecraftLog,
  type InsertMinecraftLog,
  type GamePageSection,
  type InsertGamePageSection,
  type GamePricingTier,
  type InsertGamePricingTier,
  type GameFeature,
  type InsertGameFeature,
  incidents,
  type InsertIncidentSchema,
} from "@shared/schema";
import { randomUUID } from "crypto";
import { DatabaseStorage } from "./database-storage";
import bcrypt from "bcrypt";

export interface IStorage {
  // User methods
  getUser(id: string): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  updateUser(id: string, updates: Partial<User>): Promise<User>;
  
  // Demo server methods
  getAllDemoServers(): Promise<DemoServer[]>;
  getDemoServer(id: string): Promise<DemoServer | undefined>;
  createDemoServer(server: InsertDemoServer): Promise<DemoServer>;
  updateDemoServer(id: string, updates: Partial<DemoServer>): Promise<DemoServer>;
  deleteDemoServer(id: string): Promise<void>;
  
  // Admin session methods
  createAdminSession(session: InsertAdminSession): Promise<AdminSession>;
  getAdminSession(token: string): Promise<AdminSession | undefined>;
  deleteAdminSession(token: string): Promise<void>;
  cleanExpiredSessions(): Promise<void>;
  
  // Site settings methods
  getAllSiteSettings(): Promise<SiteSetting[]>;
  getSiteSetting(key: string): Promise<SiteSetting | undefined>;
  setSiteSetting(setting: InsertSiteSetting): Promise<SiteSetting>;
  updateSiteSetting(key: string, value: string): Promise<SiteSetting>;
  
  // Promo settings methods
  getPromoSettings(): Promise<PromoSetting | undefined>;
  updatePromoSettings(settings: InsertPromoSetting): Promise<PromoSetting>;

  // Theme settings methods
  getThemeSettings(): Promise<any>;
  updateThemeSettings(settings: any): Promise<any>;

  // Game page customization methods
  getGamePageSections(gameId: string): Promise<GamePageSection[]>;
  createGamePageSection(section: InsertGamePageSection): Promise<GamePageSection>;
  updateGamePageSection(id: string, updates: Partial<GamePageSection>): Promise<GamePageSection>;
  deleteGamePageSection(id: string): Promise<void>;
  
  getGamePricingTiers(gameId: string): Promise<GamePricingTier[]>;
  createGamePricingTier(tier: InsertGamePricingTier): Promise<GamePricingTier>;
  updateGamePricingTier(id: string, updates: Partial<GamePricingTier>): Promise<GamePricingTier>;
  deleteGamePricingTier(id: string): Promise<void>;
  
  getGameFeatures(gameId: string): Promise<GameFeature[]>;
  createGameFeature(feature: InsertGameFeature): Promise<GameFeature>;
  updateGameFeature(id: string, updates: Partial<GameFeature>): Promise<GameFeature>;
  deleteGameFeature(id: string): Promise<void>;
  
  // FAQ methods
  getAllFaqCategories(): Promise<any[]>;
  getFaqCategory(id: string): Promise<any | undefined>;
  createFaqCategory(category: any): Promise<any>;
  updateFaqCategory(id: string, updates: any): Promise<any>;
  deleteFaqCategory(id: string): Promise<void>;
  getFaqItems(categoryId: string): Promise<any[]>;
  createFaqItem(item: any): Promise<any>;
  updateFaqItem(id: string, updates: any): Promise<any>;
  deleteFaqItem(id: string): Promise<void>;

  // Game methods
  getAllGames(): Promise<Game[]>;
  getGame(id: string): Promise<Game | undefined>;
  getGameBySlug(slug: string): Promise<Game | undefined>;
  createGame(game: InsertGame): Promise<Game>;
  updateGame(id: string, updates: Partial<InsertGame>): Promise<Game>;
  deleteGame(id: string): Promise<void>;
  
  // Game template methods
  updateGameFeatures(gameId: string, features: string[]): Promise<GameFeature[]>;
  updateGameSections(gameId: string, sections: any[]): Promise<GamePageSection[]>;
  updateGamePricingTiers(gameId: string, pricingTiers: any[]): Promise<GamePricingTier[]>;
  
  // Pricing methods
  getAllPricingPlans(): Promise<PricingPlan[]>;
  getPricingPlan(id: string): Promise<PricingPlan | undefined>;
  getPricingPlansByGameId(gameId: string): Promise<PricingPlan[]>;
  createPricingPlan(plan: InsertPricingPlan): Promise<PricingPlan>;
  updatePricingPlan(id: string, updates: Partial<PricingPlan>): Promise<PricingPlan | undefined>;
  deletePricingPlan(id: string): Promise<void>;
  
  // Server status methods
  getAllServerStatus(): Promise<ServerStatus[]>;
  getServerStatus(id: string): Promise<ServerStatus | undefined>;
  createServerStatus(status: InsertServerStatus): Promise<ServerStatus>;
  
  // Server location methods
  getAllServerLocations(): Promise<ServerLocation[]>;
  getServerLocation(id: string): Promise<ServerLocation | undefined>;
  createServerLocation(location: InsertServerLocation): Promise<ServerLocation>;
  updateServerLocation(id: string, updateData: Partial<ServerLocation>): Promise<ServerLocation | undefined>;
  deleteServerLocation(id: string): Promise<void>;
  
  // Minecraft tools methods
  getAllMinecraftTools(): Promise<MinecraftTool[]>;
  getMinecraftTool(id: string): Promise<MinecraftTool | undefined>;
  createMinecraftTool(tool: InsertMinecraftTool): Promise<MinecraftTool>;
  
  // Blog posts methods
  getAllBlogPosts(): Promise<BlogPost[]>;
  getBlogPost(id: string): Promise<BlogPost | undefined>;
  getBlogPostBySlug(slug: string): Promise<BlogPost | undefined>;
  createBlogPost(post: InsertBlogPost): Promise<BlogPost>;
  updateBlogPost(id: string, updates: Partial<InsertBlogPost>): Promise<BlogPost>;
  deleteBlogPost(id: string): Promise<void>;
  getPublishedBlogPosts(): Promise<BlogPost[]>;
  
  // Game pages methods
  getAllGamePages(): Promise<GamePage[]>;
  getGamePage(id: string): Promise<GamePage | undefined>;
  getGamePageByGameId(gameId: string): Promise<GamePage | undefined>;
  createGamePage(page: InsertGamePage): Promise<GamePage>;
  
  // Demo servers methods
  getAllDemoServers(): Promise<DemoServer[]>;
  getDemoServer(id: string): Promise<DemoServer | undefined>;
  getDemoServersByGameId(gameId: string): Promise<DemoServer[]>;
  createDemoServer(server: InsertDemoServer): Promise<DemoServer>;
  getActiveDemoServers(): Promise<DemoServer[]>;
  
  // Pricing details methods
  getAllPricingDetails(): Promise<PricingDetail[]>;
  getPricingDetail(id: string): Promise<PricingDetail | undefined>;
  getPricingDetailsByPlanId(planId: string): Promise<PricingDetail[]>;
  getPricingDetailsByGameId(gameId: string): Promise<PricingDetail[]>;
  createPricingDetail(detail: InsertPricingDetail): Promise<PricingDetail>;
  
  // Minecraft server management methods
  getAllMinecraftServers(): Promise<MinecraftServer[]>;
  getMinecraftServer(id: string): Promise<MinecraftServer | undefined>;
  getUserMinecraftServers(userId: string): Promise<MinecraftServer[]>;
  createMinecraftServer(server: InsertMinecraftServer): Promise<MinecraftServer>;
  updateMinecraftServer(id: string, updates: Partial<MinecraftServer>): Promise<MinecraftServer>;
  deleteMinecraftServer(id: string): Promise<void>;
  
  // Minecraft plugin methods
  getMinecraftPlugins(serverId: string): Promise<MinecraftPlugin[]>;
  createMinecraftPlugin(plugin: InsertMinecraftPlugin): Promise<MinecraftPlugin>;
  updateMinecraftPlugin(id: string, updates: Partial<MinecraftPlugin>): Promise<MinecraftPlugin>;
  deleteMinecraftPlugin(id: string): Promise<void>;
  
  // Minecraft world methods
  getMinecraftWorlds(serverId: string): Promise<MinecraftWorld[]>;
  createMinecraftWorld(world: InsertMinecraftWorld): Promise<MinecraftWorld>;
  updateMinecraftWorld(id: string, updates: Partial<MinecraftWorld>): Promise<MinecraftWorld>;
  deleteMinecraftWorld(id: string): Promise<void>;
  
  // Minecraft player methods
  getMinecraftPlayers(serverId: string): Promise<MinecraftPlayer[]>;
  createMinecraftPlayer(player: InsertMinecraftPlayer): Promise<MinecraftPlayer>;
  updateMinecraftPlayer(id: string, updates: Partial<MinecraftPlayer>): Promise<MinecraftPlayer>;
  deleteMinecraftPlayer(id: string): Promise<void>;
  
  // Minecraft backup methods
  getMinecraftBackups(serverId: string): Promise<MinecraftBackup[]>;
  createMinecraftBackup(backup: InsertMinecraftBackup): Promise<MinecraftBackup>;
  deleteMinecraftBackup(id: string): Promise<void>;
  
  // Minecraft log methods
  getMinecraftLogs(serverId: string, limit?: number): Promise<MinecraftLog[]>;
  createMinecraftLog(log: InsertMinecraftLog): Promise<MinecraftLog>;
  deleteOldMinecraftLogs(serverId: string, olderThanDays: number): Promise<void>;
}

export class MemStorage implements IStorage {
  private users: Map<string, User>;
  private games: Map<string, Game>;
  private pricingPlans: Map<string, PricingPlan>;
  private serverStatus: Map<string, ServerStatus>;
  private serverLocations: Map<string, ServerLocation>;
  private minecraftTools: Map<string, MinecraftTool>;
  private blogPosts: Map<string, BlogPost>;
  private gamePages: Map<string, GamePage>;
  private demoServers: Map<string, DemoServer>;
  private pricingDetails: Map<string, PricingDetail>;
  
  // Minecraft management storage
  private minecraftServers: Map<string, MinecraftServer>;
  private minecraftPlugins: Map<string, MinecraftPlugin>;
  private minecraftWorlds: Map<string, MinecraftWorld>;
  private minecraftPlayers: Map<string, MinecraftPlayer>;
  private minecraftBackups: Map<string, MinecraftBackup>;
  private minecraftLogs: Map<string, MinecraftLog>;
  
  // Admin settings storage
  private promoSettings: PromoSetting | null = null;
  private themeSettings: any = null;

  constructor() {
    this.users = new Map();
    this.games = new Map();
    this.pricingPlans = new Map();
    this.serverStatus = new Map();
    this.serverLocations = new Map();
    this.minecraftTools = new Map();
    this.blogPosts = new Map();
    this.gamePages = new Map();
    this.demoServers = new Map();
    this.pricingDetails = new Map();
    
    // Initialize Minecraft management maps
    this.minecraftServers = new Map();
    this.minecraftPlugins = new Map();
    this.minecraftWorlds = new Map();
    this.minecraftPlayers = new Map();
    this.minecraftBackups = new Map();
    this.minecraftLogs = new Map();
    
    this.initializeData();
    this.initializeMinecraftData();
    this.initializeBlogPosts();
  }

  private initializeData() {
    // Initialize sample games
    const sampleGames: Game[] = [
      {
        id: randomUUID(),
        name: "Minecraft",
        slug: "minecraft",
        description: "Java & Bedrock support, unlimited mods, automatic backups",
        imageUrl: "https://pixabay.com/get/g0f2a95e2a858acb44e5d404e612a684317375d9652e4fff2b2923d96673c86b933d76959bb030775cb48e79fb4a1b88692657d6eb50405ad040ba1f2dd006e09_1280.jpg",
        basePrice: "2.99",
        playerCount: 2847,
        isPopular: true,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "CS2",
        slug: "cs2",
        description: "Counter-Strike 2 servers with custom maps and plugins",
        imageUrl: "https://images.unsplash.com/photo-1542751371-adc38448a05e?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "4.99",
        playerCount: 1234,
        isPopular: false,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Rust",
        slug: "rust",
        description: "Survival servers with oxide plugins and custom maps",
        imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "6.99",
        playerCount: 892,
        isPopular: false,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "ARK: Survival",
        slug: "ark",
        description: "Dinosaur survival with clusters and mod support",
        imageUrl: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "8.99",
        playerCount: 445,
        isPopular: false,
        isNew: true,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Valheim",
        slug: "valheim",
        description: "Viking survival servers with dedicated worlds",
        imageUrl: "https://pixabay.com/get/g33c7bac813749618f16afdca5ee0feed251e74f4603a0fa395097d3bd61a82d70e151d59a5c90442f5cbea5228a4406bbed95fcbcb903ccd663509f00d72e42c_1280.jpg",
        basePrice: "5.99",
        playerCount: 678,
        isPopular: false,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "7 Days to Die",
        slug: "7dtd",
        description: "Zombie survival with custom mods and maps",
        imageUrl: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "7.99",
        playerCount: 223,
        isPopular: false,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Palworld",
        slug: "palworld",
        description: "Creature collection servers with multiplayer support",
        imageUrl: "https://images.unsplash.com/photo-1511512578047-dfb367046420?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "9.99",
        playerCount: 1567,
        isPopular: false,
        isNew: false,
        isTrending: true
      },
      {
        id: randomUUID(),
        name: "Project Zomboid",
        slug: "project-zomboid",
        description: "Isometric zombie survival with crafting and building",
        imageUrl: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "4.99",
        playerCount: 512,
        isPopular: true,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "The Forest",
        slug: "the-forest",
        description: "Survival horror with base building and cooperative play",
        imageUrl: "https://images.unsplash.com/photo-1516483638261-f4dbaf036963?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "6.99",
        playerCount: 298,
        isPopular: false,
        isNew: false,
        isTrending: true
      },
      {
        id: randomUUID(),
        name: "Terraria",
        slug: "terraria",
        description: "2D sandbox adventure with crafting and exploration",
        imageUrl: "https://images.unsplash.com/photo-1578632749014-ca77efd052ee?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "3.99",
        playerCount: 765,
        isPopular: true,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Space Engineers",
        slug: "space-engineers",
        description: "Space and planet exploration with construction and physics",
        imageUrl: "https://images.unsplash.com/photo-1582201942988-d4e8cc5b4be7?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "8.99",
        playerCount: 189,
        isPopular: false,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Garry's Mod",
        slug: "garrys-mod",
        description: "Physics sandbox with endless customization possibilities",
        imageUrl: "https://images.unsplash.com/photo-1542751371-adc38448a05e?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "4.99",
        playerCount: 423,
        isPopular: true,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "DayZ",
        slug: "dayz",
        description: "Post-apocalyptic survival with persistent character progression",
        imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "7.99",
        playerCount: 356,
        isPopular: false,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Left 4 Dead 2",
        slug: "left-4-dead-2",
        description: "Cooperative zombie shooter with campaign and versus modes",
        imageUrl: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "3.99",
        playerCount: 634,
        isPopular: true,
        isNew: false,
        isTrending: false
      },
      {
        id: randomUUID(),
        name: "Green Hell",
        slug: "green-hell",
        description: "Amazonian rainforest survival with psychological thriller elements",
        imageUrl: "https://images.unsplash.com/photo-1602491453631-e2a5ad90a131?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&h=250",
        basePrice: "5.99",
        playerCount: 167,
        isPopular: false,
        isNew: true,
        isTrending: false
      }
    ];

    sampleGames.forEach(game => this.games.set(game.id, game));

    // Initialize pricing plans
    const samplePlans: PricingPlan[] = [
      {
        id: randomUUID(),
        name: "Starter",
        price: "2.99",
        maxPlayers: 10,
        ram: "2GB RAM",
        storage: "20GB SSD Storage",
        features: ["DDoS Protection", "Basic Support"],
        isPopular: false
      },
      {
        id: randomUUID(),
        name: "Pro",
        price: "7.99",
        maxPlayers: 50,
        ram: "6GB RAM",
        storage: "100GB SSD Storage",
        features: ["Advanced DDoS Protection", "Priority Support", "Mod Support", "Daily Backups"],
        isPopular: true
      },
      {
        id: randomUUID(),
        name: "Enterprise",
        price: "19.99",
        maxPlayers: 999999,
        ram: "16GB RAM",
        storage: "500GB SSD Storage",
        features: ["Enterprise DDoS Protection", "24/7 Dedicated Support", "Custom Plugins", "Hourly Backups", "Multi-Server Management"],
        isPopular: false
      }
    ];

    samplePlans.forEach(plan => this.pricingPlans.set(plan.id, plan));

    // Initialize server status
    const sampleStatus: ServerStatus[] = [
      {
        id: randomUUID(),
        service: "Game Servers",
        status: "operational",
        responseTime: 12,
        uptime: "99.97",
        lastUpdated: new Date()
      },
      {
        id: randomUUID(),
        service: "Control Panel",
        status: "operational",
        responseTime: 15,
        uptime: "99.95",
        lastUpdated: new Date()
      },
      {
        id: randomUUID(),
        service: "API Services",
        status: "operational",
        responseTime: 8,
        uptime: "99.99",
        lastUpdated: new Date()
      },
      {
        id: randomUUID(),
        service: "Billing System",
        status: "operational",
        responseTime: 20,
        uptime: "99.98",
        lastUpdated: new Date()
      }
    ];

    sampleStatus.forEach(status => this.serverStatus.set(status.id, status));

    // Initialize server locations with real VintHill server
    const sampleServerLocations: ServerLocation[] = [
      {
        id: randomUUID(),
        city: "VintHill",
        country: "United States", 
        region: "VA",
        provider: "VINTHILL",
        ipAddress: "135.148.137.158",
        status: "online",
        ping: 12
      }
    ];

    sampleServerLocations.forEach(location => this.serverLocations.set(location.id, location));

    // Blog posts will be initialized by initializeBlogPosts() method

    // Initialize demo servers with real Minecraft servers
    const gameIds = Array.from(this.games.keys());
    const sampleDemoServers: DemoServer[] = [
      {
        id: randomUUID(),
        gameId: gameIds[0], // Minecraft
        serverName: "Hypixel Demo Server",
        serverIp: "mc.hypixel.net",
        serverPort: 25565,
        maxPlayers: 200000,
        description: "Experience the most popular Minecraft server with mini-games, SkyBlock, and more!",
        isActive: true,
        playtime: 30
      },
      {
        id: randomUUID(),
        gameId: gameIds[0], // Minecraft
        serverName: "Mineplex Demo Server", 
        serverIp: "us.mineplex.com",
        serverPort: 25565,
        maxPlayers: 4000,
        description: "Join one of the largest Minecraft networks with countless game modes and activities!",
        isActive: true,
        playtime: 30
      }
    ];

    sampleDemoServers.forEach(server => this.demoServers.set(server.id, server));

    // Initialize minecraft tools
    const sampleTools: MinecraftTool[] = [
      {
        id: randomUUID(),
        name: "Server Query Tool",
        description: "Check any Minecraft server's status, player count, version, and MOTD. Perfect for monitoring server health and performance.",
        category: "Server Management",
        url: "https://mcsrvstat.us/",
        features: [
          "Real-time server status checking",
          "Player count and max slots",
          "Server version detection",
          "MOTD and ping information",
          "Historical data tracking"
        ],
        isPremium: false
      },
      {
        id: randomUUID(),
        name: "Skin Viewer & Editor",
        description: "View, download, and edit Minecraft player skins. Supports both Steve and Alex models with 3D preview.",
        category: "Player Tools",
        url: "https://namemc.com/",
        features: [
          "3D skin preview",
          "High-resolution downloads",
          "Skin history tracking",
          "Custom skin upload",
          "Cape support"
        ],
        isPremium: false
      },
      {
        id: randomUUID(),
        name: "UUID Converter",
        description: "Convert between Minecraft usernames and UUIDs. Essential for server administration and player management.",
        category: "Utilities",
        url: "https://mcuuid.net/",
        features: [
          "Username to UUID conversion",
          "UUID to username lookup",
          "Bulk conversion support",
          "API integration",
          "Historical username data"
        ],
        isPremium: false
      },
      {
        id: randomUUID(),
        name: "Color Code Generator",
        description: "Generate Minecraft color codes for chat messages, signs, and books. Supports all formatting codes and hex colors.",
        category: "Design",
        url: "https://www.digminecraft.com/generators/color_text.php",
        features: [
          "All color codes supported",
          "Formatting codes (bold, italic)",
          "Hex color support (1.16+)",
          "Live preview",
          "Copy to clipboard"
        ],
        isPremium: false
      },
      {
        id: randomUUID(),
        name: "NBT Editor",
        description: "Advanced NBT data editor for items, entities, and world data. Professional tool for server administrators.",
        category: "Server Management",
        url: "https://www.nbteditor.com/",
        features: [
          "Full NBT editing capabilities",
          "Item modifier",
          "Entity data editing",
          "World data manipulation",
          "JSON export/import"
        ],
        isPremium: true
      },
      {
        id: randomUUID(),
        name: "Banner Designer",
        description: "Design custom Minecraft banners with our visual editor. Create unique banners for your server builds.",
        category: "Design",
        url: "https://www.needcoolshoes.com/banner",
        features: [
          "Visual banner editor",
          "Pattern library",
          "Color combinations",
          "Give command generator",
          "Banner gallery"
        ],
        isPremium: false
      }
    ];

    sampleTools.forEach(tool => this.minecraftTools.set(tool.id, tool));
  }

  // User methods
  async getUser(id: string): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username,
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = randomUUID();
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }

  // Game methods
  async getAllGames(): Promise<Game[]> {
    return Array.from(this.games.values());
  }

  async getGame(id: string): Promise<Game | undefined> {
    return this.games.get(id);
  }

  async createGame(insertGame: InsertGame): Promise<Game> {
    const id = randomUUID();
    const game: Game = { 
      ...insertGame, 
      id,
      playerCount: insertGame.playerCount ?? 0,
      isPopular: insertGame.isPopular ?? false,
      isNew: insertGame.isNew ?? false,
      isTrending: insertGame.isTrending ?? false
    };
    this.games.set(id, game);
    return game;
  }

  // Pricing methods
  async getAllPricingPlans(): Promise<PricingPlan[]> {
    return Array.from(this.pricingPlans.values());
  }

  async getPricingPlan(id: string): Promise<PricingPlan | undefined> {
    return this.pricingPlans.get(id);
  }

  async createPricingPlan(insertPlan: InsertPricingPlan): Promise<PricingPlan> {
    const id = randomUUID();
    const plan: PricingPlan = { 
      ...insertPlan, 
      id,
      isPopular: insertPlan.isPopular ?? false,
      maxPlayers: insertPlan.maxPlayers ?? null
    };
    this.pricingPlans.set(id, plan);
    return plan;
  }

  // Server status methods
  async getAllServerStatus(): Promise<ServerStatus[]> {
    return Array.from(this.serverStatus.values());
  }

  async getServerStatus(id: string): Promise<ServerStatus | undefined> {
    return this.serverStatus.get(id);
  }

  async createServerStatus(insertStatus: InsertServerStatus): Promise<ServerStatus> {
    const id = randomUUID();
    const status: ServerStatus = { 
      ...insertStatus, 
      id, 
      lastUpdated: new Date(),
      responseTime: insertStatus.responseTime ?? null,
      uptime: insertStatus.uptime ?? null
    };
    this.serverStatus.set(id, status);
    return status;
  }

  // Server location methods
  async getAllServerLocations(): Promise<ServerLocation[]> {
    return Array.from(this.serverLocations.values());
  }

  async getServerLocation(id: string): Promise<ServerLocation | undefined> {
    return this.serverLocations.get(id);
  }

  async createServerLocation(insertLocation: InsertServerLocation): Promise<ServerLocation> {
    const id = randomUUID();
    const location: ServerLocation = { ...insertLocation, id };
    this.serverLocations.set(id, location);
    return location;
  }

  async deleteServerLocation(id: string): Promise<void> {
    this.serverLocations.delete(id);
  }

  async updateServerLocation(id: string, updateData: Partial<ServerLocation>): Promise<ServerLocation | undefined> {
    const existing = this.serverLocations.get(id);
    if (existing) {
      const updated = { ...existing, ...updateData };
      this.serverLocations.set(id, updated);
      return updated;
    }
    return undefined;
  }

  // Method to update ping for real-time monitoring
  async updateServerLocationPing(ipAddress: string, ping: number): Promise<void> {
    for (const [id, location] of this.serverLocations.entries()) {
      if (location.ipAddress === ipAddress) {
        const updated = { ...location, ping };
        this.serverLocations.set(id, updated);
        break;
      }
    }
  }

  // Minecraft tools methods
  async getAllMinecraftTools(): Promise<MinecraftTool[]> {
    return Array.from(this.minecraftTools.values());
  }

  async getMinecraftTool(id: string): Promise<MinecraftTool | undefined> {
    return this.minecraftTools.get(id);
  }

  async createMinecraftTool(insertTool: InsertMinecraftTool): Promise<MinecraftTool> {
    const id = randomUUID();
    const tool: MinecraftTool = { ...insertTool, id };
    this.minecraftTools.set(id, tool);
    return tool;
  }

  // Blog posts methods
  async getAllBlogPosts(): Promise<BlogPost[]> {
    return Array.from(this.blogPosts.values());
  }

  async getBlogPost(id: string): Promise<BlogPost | undefined> {
    return this.blogPosts.get(id);
  }

  async getBlogPostBySlug(slug: string): Promise<BlogPost | undefined> {
    return Array.from(this.blogPosts.values()).find(post => post.slug === slug);
  }

  async createBlogPost(insertPost: InsertBlogPost): Promise<BlogPost> {
    const id = randomUUID();
    const now = new Date();
    const post: BlogPost = { 
      ...insertPost, 
      id, 
      publishedAt: now,
      updatedAt: now,
      isPublished: insertPost.isPublished ?? true
    };
    this.blogPosts.set(id, post);
    return post;
  }

  async getPublishedBlogPosts(): Promise<BlogPost[]> {
    return Array.from(this.blogPosts.values()).filter(post => post.isPublished);
  }

  async updateBlogPost(id: string, updateData: Partial<InsertBlogPost>): Promise<BlogPost> {
    const existingPost = this.blogPosts.get(id);
    if (!existingPost) {
      throw new Error(`Blog post with id ${id} not found`);
    }
    
    const updatedPost: BlogPost = {
      ...existingPost,
      ...updateData,
      id: existingPost.id, // Ensure ID doesn't change
      publishedAt: existingPost.publishedAt, // Keep original publish date
      updatedAt: new Date() // Set current time as update timestamp
    };
    
    this.blogPosts.set(id, updatedPost);
    return updatedPost;
  }

  async deleteBlogPost(id: string): Promise<void> {
    if (!this.blogPosts.has(id)) {
      throw new Error(`Blog post with id ${id} not found`);
    }
    this.blogPosts.delete(id);
  }

  private initializeBlogPosts() {
    // Clear any existing blog posts first
    this.blogPosts.clear();
    
    // Initialize comprehensive professional blog posts
    const sampleBlogPosts = [
      {
        id: "minecraft-ultimate-guide-2025",
        title: "Ultimate Minecraft Server Setup Guide 2025", 
        slug: "ultimate-minecraft-server-setup-guide-2025",
        excerpt: "Complete step-by-step guide to setting up and optimizing your Minecraft server for maximum performance and player satisfaction.",
        content: `# Ultimate Minecraft Server Setup Guide 2025

Setting up a Minecraft server can seem daunting, but with the right guidance, you'll have players exploring your world in no time. This comprehensive guide covers everything from basic setup to advanced optimization techniques.

## Getting Started

### 1. Choosing Your Server Type

**Vanilla Minecraft**: Perfect for pure gameplay experience
- **Pros**: Stable, no compatibility issues, authentic experience
- **Cons**: Limited customization, fewer features
- **Best for**: Small groups, pure survival gameplay

**Modded Servers (Forge/Fabric)**: Enhanced gameplay with mods
- **Pros**: Unlimited customization, enhanced features, community content
- **Cons**: More complex setup, potential stability issues
- **Best for**: Players wanting enhanced gameplay

**Plugin Servers (Bukkit/Spigot/Paper)**: Server-side enhancements
- **Pros**: Easy management, performance optimizations, admin tools
- **Cons**: Some limitations compared to mods
- **Best for**: Server administrators, multiplayer communities

### 2. Server Specifications

**RAM Requirements:**
- 1-10 players: 2-4GB RAM
- 10-20 players: 4-6GB RAM  
- 20-50 players: 6-8GB RAM
- 50+ players: 8GB+ RAM

**CPU Considerations:**
- Minecraft is single-threaded for world generation
- Higher clock speeds > more cores
- Intel processors often perform better

**Storage:**
- SSD strongly recommended for world loading
- Minimum 10GB free space
- Regular backups essential

## Installation Process

### Step 1: Download Server Files

\`\`\`bash
# Download latest Minecraft server
wget https://launcher.mojang.com/v1/objects/server.jar

# For Paper (recommended)
wget https://papermc.io/downloads/paper
\`\`\`

### Step 2: Initial Configuration

Create \`server.properties\` with optimal settings:

\`\`\`properties
# Basic Settings
server-name=Your Server Name
motd=Welcome to Your Server!
max-players=20
difficulty=normal
gamemode=survival

# Performance Settings
spawn-protection=0
view-distance=10
simulation-distance=10
entity-broadcast-range-percentage=100

# Security
online-mode=true
spawn-monsters=true
spawn-animals=true
\`\`\`

### Step 3: Memory Allocation

Launch with proper JVM flags:

\`\`\`bash
java -Xmx4G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -jar server.jar nogui
\`\`\`

## Essential Plugins

### Management Plugins
- **EssentialsX**: Core commands and utilities
- **WorldGuard**: Area protection and management
- **PermissionsEx**: Player permission management
- **Vault**: Economy and permission bridge

### Performance Plugins
- **ClearLag**: Remove entities to improve performance
- **NoChunkLag**: Optimize chunk loading
- **LagAssist**: Monitor and reduce server lag

### Quality of Life
- **Dynmap**: Live web map of your world
- **GriefPrevention**: Automatic grief protection
- **McMMO**: RPG skills and abilities

## Security Best Practices

### 1. Access Control
- Use strong RCON passwords
- Limit SSH access to specific IPs
- Regular security updates
- Monitor player activity

### 2. Backup Strategy
\`\`\`bash
#!/bin/bash
# Daily backup script
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf "/backups/minecraft_$DATE.tar.gz" /path/to/minecraft/world/
\`\`\`

### 3. DDoS Protection
- Use Cloudflare or similar service
- Configure firewall rules
- Monitor connection patterns
- Consider managed hosting

## Troubleshooting Common Issues

### Performance Problems
1. Check TPS with \`/tps\` command
2. Monitor RAM usage
3. Review entity counts
4. Check for problematic chunks

### Connection Issues
1. Verify port forwarding (25565)
2. Check firewall settings
3. Confirm server IP/domain
4. Test with direct IP connection

**Need help with your server setup?** Consider our managed Minecraft hosting solutions - we handle the technical details so you can focus on building your community!`,
        imageUrl: "/images/blog/minecraft-setup.svg",
        author: "VoltServers Team",
        publishedAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
        updatedAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
        isPublished: true,
        tags: ["minecraft", "server-setup", "guide", "gaming", "tutorial"]
      },
      {
        id: "rust-server-optimization-2025",
        title: "Rust Server Optimization: Performance Tuning Guide",
        slug: "rust-server-optimization-performance-guide",
        excerpt: "Master Rust server performance with advanced optimization techniques, memory management, and player capacity planning.",
        content: `# Rust Server Optimization: Performance Tuning Guide

Running a smooth Rust server requires understanding the game's unique resource demands and optimization strategies. This guide covers comprehensive performance tuning techniques.

## Understanding Rust Server Resources

### Memory Requirements
- **Minimum**: 4GB RAM for 50 players
- **Recommended**: 8GB RAM for 100 players
- **Optimal**: 16GB+ RAM for 200+ players
- **Map Size Impact**: Larger maps require exponentially more RAM

### CPU Considerations
- Rust is heavily multi-threaded
- Higher core count significantly improves performance
- AMD Ryzen processors excel for Rust hosting
- Intel 12th gen+ also performs excellently

### Storage Requirements
- NVMe SSD essential for map loading
- 20-50GB per server instance
- Regular wipe storage cleanup needed
- Automatic backup systems recommended

## Server Configuration Optimization

### 1. Server.cfg Essentials

\`\`\`cfg
# Performance Settings
fps.limit 60
physics.substeps 1
physics.iterations 7

# Network Optimization
server.maxplayers 100
server.netcache true
server.netcachesize 100

# Security Settings
server.secure true
server.encryption 2
server.anticheat true

# Resource Management
spawn.min_rate 0.5
spawn.max_rate 1.0
spawn.min_density 0.5
spawn.max_density 1.0
\`\`\`

### 2. Launch Parameters

\`\`\`bash
./RustDedicated -batchmode \\
  -nographics \\
  -server.ip 0.0.0.0 \\
  -server.port 28015 \\
  -server.maxplayers 100 \\
  -server.hostname "Your Server Name" \\
  -server.identity "server1" \\
  -server.seed 12345 \\
  -server.worldsize 3000 \\
  -server.saveinterval 300 \\
  -logfile /rust/logs/server.log
\`\`\`

### 3. Oxide/uMod Plugin Optimization

Essential performance plugins:
- **AdminHammer**: Quick building/destruction
- **CopyPaste**: Efficient structure management  
- **NightLantern**: Automatic lighting systems
- **AutoPurge**: Remove inactive player bases
- **BetterLoot**: Optimized loot distribution

## Map and World Generation

### 1. Map Size Considerations

- **1000 size**: 50-75 players maximum
- **2000 size**: 75-125 players optimal
- **3000 size**: 125-200 players
- **4000+ size**: 200+ players (high-end hardware)

### 2. Procedural Generation Settings

\`\`\`cfg
# World generation optimization
world.seed 12345
world.size 3000
world.monuments 10
world.roads true
world.rivers true
\`\`\`

## Monitoring and Maintenance

### 1. Performance Monitoring

\`\`\`bash
#!/bin/bash
# Performance monitoring script
echo "=== Rust Server Performance Report ===" > perf_report.log
echo "CPU Usage:" >> perf_report.log
top -b -n1 | grep RustDedicated >> perf_report.log
echo "Memory Usage:" >> perf_report.log
free -h >> perf_report.log
\`\`\`

### 2. Automated Maintenance

- Schedule regular server restarts
- Implement automatic updates
- Clean old log files
- Monitor player count patterns

## Security Considerations

### 1. Anti-Cheat Configuration
\`\`\`cfg
server.anticheat true
server.stats true
server.official false
server.secure true
\`\`\`

### 2. DDoS Protection
- Use services like Cloudflare
- Configure proper firewall rules
- Monitor traffic patterns
- Have mitigation plans ready

## Conclusion

Optimizing a Rust server is an ongoing process that requires attention to hardware, software, and community management. Regular monitoring, proactive maintenance, and understanding your player base's needs are key to success.

**Ready to launch your optimized Rust server?** Our managed hosting solutions include all these optimizations pre-configured, plus 24/7 monitoring and support.`,
        imageUrl: "/images/blog/server-optimization.svg",
        author: "VoltServers Team",
        publishedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
        updatedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
        isPublished: true,
        tags: ["rust", "server-optimization", "performance", "gaming", "hosting"]
      },
      {
        id: "ark-server-administration-2025",
        title: "ARK Server Administration: Complete Management Guide",
        slug: "ark-server-administration-complete-guide", 
        excerpt: "Everything you need to know about managing ARK: Survival Evolved servers, from basic setup to advanced cluster management.",
        content: `# ARK Server Administration: Complete Management Guide

ARK: Survival Evolved servers require specialized knowledge for optimal performance. This comprehensive guide covers everything from initial setup to advanced cluster management.

## ARK Server Basics

### System Requirements
- **Minimum RAM**: 6GB for basic server
- **Recommended RAM**: 12GB for modded server
- **CPU**: Intel i5-8400 or AMD Ryzen 5 2600+
- **Storage**: 100GB+ SSD space
- **Network**: 100Mbps+ upload speed

### Initial Server Setup

\`\`\`bash
# Steam CMD installation
./steamcmd.exe +login anonymous +force_install_dir /ark +app_update 376030 +quit

# Launch parameters
./ShooterGameServer.exe "TheIsland?listen?SessionName=Your Server?ServerPassword=yourpass?ServerAdminPassword=adminpass?Port=7777?QueryPort=27015?MaxPlayers=20" -server -log
\`\`\`

## Game.ini Configuration

### 1. Essential Settings

\`\`\`ini
[ServerSettings]
; Experience and leveling
OverrideOfficialDifficulty=1.0
DifficultyOffset=1.0
MaxDifficulty=true

; Player settings  
PlayerLevelMultiplier=1.5
PlayerCharacterStaminaDrainMultiplier=0.8
PlayerCharacterHealthRecoveryMultiplier=1.2

; Taming settings
TamingSpeedMultiplier=3.0
DinoCharacterFoodDrainMultiplier=0.5
WildDinoCharacterFoodDrainMultiplier=0.8

; Resource gathering
HarvestAmountMultiplier=2.0
HarvestHealthMultiplier=1.5
ResourcesRespawnPeriodMultiplier=0.5

; Quality of life
ShowMapPlayerLocation=true
AllowThirdPersonPlayer=true
AllowCaveBuildingPvE=true
DisableStructureDecayPvE=true
\`\`\`

## Mod Management

### 1. Popular Server Mods

**Quality of Life Mods:**
- **Structures Plus (S+)**: Enhanced building
- **Awesome Teleporters**: Fast travel system  
- **HG Stacking Mod**: Increased stack sizes
- **Dino Tracker**: Find lost dinosaurs

**Content Mods:**
- **Primal Fear**: New creatures and bosses
- **Extinction Core**: Hardcore survival
- **Crystal Isles**: New map content
- **Additional Creatures**: Expanded fauna

### 2. Mod Installation Process

\`\`\`bash
# Download mods via Steam CMD
./steamcmd.exe +login anonymous +workshop_download_item 346110 MODID +quit

# Configure GameUserSettings.ini
[ServerSettings]
ActiveMods=731604991,1404697612,1300713111
\`\`\`

## Performance Optimization

### 1. Memory Management

\`\`\`ini
[ServerSettings]
; Memory optimization
bUseVSync=false
bUseFastTurnaroundTime=true
bForceCanRideFliers=true

; Reduce memory usage
TheMaxStructuresInRange=10500
MaxPersonalTamedDinos=500
PersonalTamedDinosSaddleStructureCost=19
MaxNumberOfPlayersInTribe=10
\`\`\`

### 2. Automated Maintenance

\`\`\`bash
#!/bin/bash
# Daily maintenance script
ARK_DIR="/ark/ShooterGame"
LOG_DIR="/ark/logs"
DATE=$(date +%Y%m%d)

# Backup saves
tar -czf "/ark/backups/ark_save_$DATE.tar.gz" "$ARK_DIR/Saved"

# Clean old logs
find "$LOG_DIR" -name "*.log" -mtime +7 -delete

# Restart server for memory cleanup
systemctl restart ark-server
\`\`\`

## Admin Commands and Tools

### 1. Essential Admin Commands

\`\`\`
; Player management
SetPlayerPos 0 0 0
TeleportPlayerNameToMe PlayerName
BanPlayer PlayerName
UnbanPlayer PlayerName

; Spawning and cheats
GiveItemNum 1 1 1 0
Summon Rex_Character_BP_C
ForceTame

; Server management
SaveWorld
DestroyWildDinos
Broadcast Your message here
\`\`\`

## Conclusion

ARK server administration requires ongoing attention and optimization. Regular maintenance, proper configuration, and proactive monitoring are essential for a successful server.

**Looking for managed ARK hosting?** Our team handles all the technical complexity while you focus on building your community and creating engaging gameplay experiences.`,
        imageUrl: "/images/blog/ark-management.svg",
        author: "VoltServers Team",
        publishedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        updatedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        isPublished: true,
        tags: ["ark", "server-administration", "management", "gaming", "survival"]
      },
      {
        id: "ddos-protection-guide-2025",
        title: "DDoS Protection for Game Servers: Security Guide",
        slug: "ddos-protection-game-servers-security-guide",
        excerpt: "Comprehensive guide to protecting your game servers from DDoS attacks with practical mitigation strategies and monitoring tools.",
        content: `# DDoS Protection for Game Servers: Security Guide

DDoS attacks are one of the biggest threats to game server stability. This guide provides comprehensive protection strategies to keep your servers online and your community playing.

## Understanding DDoS Attacks

### Types of DDoS Attacks

**1. Volumetric Attacks**
- UDP floods
- ICMP floods
- Amplification attacks
- Target: Overwhelm bandwidth

**2. Protocol Attacks**
- SYN flood
- Ping of death
- Smurf attacks
- Target: Exhaust server resources

**3. Application Layer Attacks**
- HTTP floods
- Slowloris attacks
- Game-specific exploits
- Target: Application vulnerabilities

## Prevention Strategies

### 1. Network Architecture

\`\`\`
Internet → CDN/WAF → Load Balancer → Firewall → Game Servers
                                        ↓
                                   DDoS Scrubbing Center
\`\`\`

### 2. Firewall Configuration

\`\`\`bash
#!/bin/bash
# IPTables DDoS protection rules

# Rate limiting for new connections
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 2/min --limit-burst 2 -j ACCEPT

# Block common attack patterns
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP

# Game server specific protection
iptables -A INPUT -p udp --dport 27015 -m limit --limit 50/sec --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp --dport 27015 -m limit --limit 25/sec --limit-burst 50 -j ACCEPT
\`\`\`

### 3. Real-time Monitoring

\`\`\`python
#!/usr/bin/env python3
import psutil
import time
from datetime import datetime

class DDoSMonitor:
    def __init__(self):
        self.baseline_connections = 0
        self.alert_threshold = 1000
        self.email_alerts = True
    
    def monitor_connections(self):
        connections = len(psutil.net_connections())
        
        if connections > self.alert_threshold:
            self.send_alert(f"High connection count detected: {connections}")
            return True
        return False
    
    def send_alert(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"{timestamp}: {message}")

if __name__ == "__main__":
    monitor = DDoSMonitor()
    
    while True:
        monitor.monitor_connections()
        time.sleep(30)
\`\`\`

## Mitigation Techniques

### 1. Rate Limiting

Use services like Cloudflare or implement custom rate limiting:

\`\`\`nginx
# Nginx rate limiting configuration
http {
    limit_req_zone $binary_remote_addr zone=gameserver:10m rate=10r/s;
    
    server {
        listen 80;
        server_name your-game-server.com;
        
        location / {
            limit_req zone=gameserver burst=20 nodelay;
            proxy_pass http://backend_gameservers;
        }
    }
}
\`\`\`

### 2. Application-Level Protection

Implement connection validation in your game server:

\`\`\`python
class ConnectionValidator:
    def __init__(self):
        self.connection_history = {}
        self.rate_limits = {
            'connections_per_ip': 5,
            'packets_per_second': 50,
            'max_packet_size': 1024
        }
    
    def validate_connection(self, ip_address, packet_data):
        # Check rate limits and validate packet content
        if self.check_rate_limits(ip_address):
            return True, "Valid connection"
        return False, "Rate limit exceeded"
\`\`\`

## Best Practices Summary

### 1. Preparation
- Implement layered security architecture
- Configure monitoring and alerting systems
- Develop and test incident response procedures
- Establish relationships with DDoS mitigation providers

### 2. During an Attack
- Remain calm and follow procedures
- Document the attack for analysis
- Communicate with stakeholders
- Activate mitigation measures incrementally

### 3. Post-Attack
- Analyze attack patterns and sources
- Update protection measures
- Review and improve procedures
- Consider additional security investments

## Conclusion

DDoS protection requires a comprehensive approach combining network architecture, monitoring, automated responses, and human expertise. Regular testing and updates of your protection measures are essential for maintaining effective defense against evolving attack methods.

**Need professional DDoS protection?** Our enterprise hosting solutions include advanced DDoS mitigation with 24/7 monitoring and instant response capabilities.`,
        imageUrl: "/images/blog/security-guide.svg",
        author: "VoltServers Security Team",
        publishedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        updatedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        isPublished: true,
        tags: ["security", "ddos-protection", "networking", "server-management", "cybersecurity"]
      }
    ];

    sampleBlogPosts.forEach(post => this.blogPosts.set(post.id, post));
  }

  // Game pages methods
  async getAllGamePages(): Promise<GamePage[]> {
    return Array.from(this.gamePages.values());
  }

  async getGamePage(id: string): Promise<GamePage | undefined> {
    return this.gamePages.get(id);
  }

  async getGamePageByGameId(gameId: string): Promise<GamePage | undefined> {
    return Array.from(this.gamePages.values()).find(page => page.gameId === gameId);
  }

  async createGamePage(insertPage: InsertGamePage): Promise<GamePage> {
    const id = randomUUID();
    const page: GamePage = { ...insertPage, id };
    this.gamePages.set(id, page);
    return page;
  }

  // Demo servers methods
  async getAllDemoServers(): Promise<DemoServer[]> {
    return Array.from(this.demoServers.values());
  }

  async getDemoServer(id: string): Promise<DemoServer | undefined> {
    return this.demoServers.get(id);
  }

  async getDemoServersByGameId(gameId: string): Promise<DemoServer[]> {
    return Array.from(this.demoServers.values()).filter(server => server.gameId === gameId);
  }

  async createDemoServer(insertServer: InsertDemoServer): Promise<DemoServer> {
    const id = randomUUID();
    const server: DemoServer = { 
      ...insertServer, 
      id,
      isActive: insertServer.isActive ?? true,
      playtime: insertServer.playtime ?? 0
    };
    this.demoServers.set(id, server);
    return server;
  }

  async getActiveDemoServers(): Promise<DemoServer[]> {
    return Array.from(this.demoServers.values()).filter(server => server.isActive);
  }

  // Pricing details methods
  async getAllPricingDetails(): Promise<PricingDetail[]> {
    return Array.from(this.pricingDetails.values());
  }

  async getPricingDetail(id: string): Promise<PricingDetail | undefined> {
    return this.pricingDetails.get(id);
  }

  async getPricingDetailsByPlanId(planId: string): Promise<PricingDetail[]> {
    return Array.from(this.pricingDetails.values()).filter(detail => detail.planId === planId);
  }

  async getPricingDetailsByGameId(gameId: string): Promise<PricingDetail[]> {
    return Array.from(this.pricingDetails.values()).filter(detail => detail.gameId === gameId);
  }

  async createPricingDetail(insertDetail: InsertPricingDetail): Promise<PricingDetail> {
    const id = randomUUID();
    const detail: PricingDetail = { 
      ...insertDetail, 
      id,
      customPrice: insertDetail.customPrice ?? null
    };
    this.pricingDetails.set(id, detail);
    return detail;
  }

  // Minecraft server management methods
  async getAllMinecraftServers(): Promise<MinecraftServer[]> {
    return Array.from(this.minecraftServers.values());
  }

  async getMinecraftServer(id: string): Promise<MinecraftServer | undefined> {
    return this.minecraftServers.get(id);
  }

  async getUserMinecraftServers(userId: string): Promise<MinecraftServer[]> {
    return Array.from(this.minecraftServers.values()).filter(server => server.userId === userId);
  }

  async createMinecraftServer(insertServer: InsertMinecraftServer): Promise<MinecraftServer> {
    const id = randomUUID();
    const server: MinecraftServer = { 
      ...insertServer, 
      id,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this.minecraftServers.set(id, server);
    return server;
  }

  async updateMinecraftServer(id: string, updates: Partial<MinecraftServer>): Promise<MinecraftServer> {
    const existing = this.minecraftServers.get(id);
    if (!existing) {
      throw new Error(`Minecraft server with id ${id} not found`);
    }
    const updated = { ...existing, ...updates, updatedAt: new Date() };
    this.minecraftServers.set(id, updated);
    return updated;
  }

  async deleteMinecraftServer(id: string): Promise<void> {
    this.minecraftServers.delete(id);
    // Also delete related data
    const plugins = Array.from(this.minecraftPlugins.values()).filter(p => p.serverId === id);
    plugins.forEach(p => this.minecraftPlugins.delete(p.id));
    
    const worlds = Array.from(this.minecraftWorlds.values()).filter(w => w.serverId === id);
    worlds.forEach(w => this.minecraftWorlds.delete(w.id));
    
    const players = Array.from(this.minecraftPlayers.values()).filter(p => p.serverId === id);
    players.forEach(p => this.minecraftPlayers.delete(p.id));
    
    const backups = Array.from(this.minecraftBackups.values()).filter(b => b.serverId === id);
    backups.forEach(b => this.minecraftBackups.delete(b.id));
    
    const logs = Array.from(this.minecraftLogs.values()).filter(l => l.serverId === id);
    logs.forEach(l => this.minecraftLogs.delete(l.id));
  }

  // Minecraft plugin methods
  async getMinecraftPlugins(serverId: string): Promise<MinecraftPlugin[]> {
    return Array.from(this.minecraftPlugins.values()).filter(plugin => plugin.serverId === serverId);
  }

  async createMinecraftPlugin(insertPlugin: InsertMinecraftPlugin): Promise<MinecraftPlugin> {
    const id = randomUUID();
    const plugin: MinecraftPlugin = { 
      ...insertPlugin, 
      id,
      installedAt: new Date(),
    };
    this.minecraftPlugins.set(id, plugin);
    return plugin;
  }

  async updateMinecraftPlugin(id: string, updates: Partial<MinecraftPlugin>): Promise<MinecraftPlugin> {
    const existing = this.minecraftPlugins.get(id);
    if (!existing) {
      throw new Error(`Minecraft plugin with id ${id} not found`);
    }
    const updated = { ...existing, ...updates };
    this.minecraftPlugins.set(id, updated);
    return updated;
  }

  async deleteMinecraftPlugin(id: string): Promise<void> {
    this.minecraftPlugins.delete(id);
  }

  // Minecraft world methods
  async getMinecraftWorlds(serverId: string): Promise<MinecraftWorld[]> {
    return Array.from(this.minecraftWorlds.values()).filter(world => world.serverId === serverId);
  }

  async createMinecraftWorld(insertWorld: InsertMinecraftWorld): Promise<MinecraftWorld> {
    const id = randomUUID();
    const world: MinecraftWorld = { 
      ...insertWorld, 
      id,
      createdAt: new Date(),
    };
    this.minecraftWorlds.set(id, world);
    return world;
  }

  async updateMinecraftWorld(id: string, updates: Partial<MinecraftWorld>): Promise<MinecraftWorld> {
    const existing = this.minecraftWorlds.get(id);
    if (!existing) {
      throw new Error(`Minecraft world with id ${id} not found`);
    }
    const updated = { ...existing, ...updates };
    this.minecraftWorlds.set(id, updated);
    return updated;
  }

  async deleteMinecraftWorld(id: string): Promise<void> {
    this.minecraftWorlds.delete(id);
    // Also delete related backups
    const backups = Array.from(this.minecraftBackups.values()).filter(b => b.worldId === id);
    backups.forEach(b => this.minecraftBackups.delete(b.id));
  }

  // Minecraft player methods
  async getMinecraftPlayers(serverId: string): Promise<MinecraftPlayer[]> {
    return Array.from(this.minecraftPlayers.values()).filter(player => player.serverId === serverId);
  }

  async createMinecraftPlayer(insertPlayer: InsertMinecraftPlayer): Promise<MinecraftPlayer> {
    const id = randomUUID();
    const player: MinecraftPlayer = { 
      ...insertPlayer, 
      id,
      firstJoin: new Date(),
    };
    this.minecraftPlayers.set(id, player);
    return player;
  }

  async updateMinecraftPlayer(id: string, updates: Partial<MinecraftPlayer>): Promise<MinecraftPlayer> {
    const existing = this.minecraftPlayers.get(id);
    if (!existing) {
      throw new Error(`Minecraft player with id ${id} not found`);
    }
    const updated = { ...existing, ...updates };
    this.minecraftPlayers.set(id, updated);
    return updated;
  }

  async deleteMinecraftPlayer(id: string): Promise<void> {
    this.minecraftPlayers.delete(id);
  }

  // Minecraft backup methods
  async getMinecraftBackups(serverId: string): Promise<MinecraftBackup[]> {
    return Array.from(this.minecraftBackups.values()).filter(backup => backup.serverId === serverId);
  }

  async createMinecraftBackup(insertBackup: InsertMinecraftBackup): Promise<MinecraftBackup> {
    const id = randomUUID();
    const backup: MinecraftBackup = { 
      ...insertBackup, 
      id,
      createdAt: new Date(),
    };
    this.minecraftBackups.set(id, backup);
    return backup;
  }

  async updateMinecraftBackup(id: string, updates: Partial<MinecraftBackup>): Promise<MinecraftBackup> {
    const existing = this.minecraftBackups.get(id);
    if (!existing) {
      throw new Error(`Minecraft backup with id ${id} not found`);
    }
    const updated = { ...existing, ...updates };
    this.minecraftBackups.set(id, updated);
    return updated;
  }

  async deleteMinecraftBackup(id: string): Promise<void> {
    this.minecraftBackups.delete(id);
  }

  // Minecraft log methods
  async getMinecraftLogs(serverId: string, limit: number = 100): Promise<MinecraftLog[]> {
    return Array.from(this.minecraftLogs.values())
      .filter(log => log.serverId === serverId)
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, limit);
  }

  async createMinecraftLog(insertLog: InsertMinecraftLog): Promise<MinecraftLog> {
    const id = randomUUID();
    const log: MinecraftLog = { 
      ...insertLog, 
      id,
      timestamp: new Date(),
    };
    this.minecraftLogs.set(id, log);
    return log;
  }

  async deleteOldMinecraftLogs(serverId: string, olderThanDays: number): Promise<void> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);
    
    const logsToDelete = Array.from(this.minecraftLogs.values())
      .filter(log => log.serverId === serverId && new Date(log.timestamp) < cutoffDate);
    
    logsToDelete.forEach(log => this.minecraftLogs.delete(log.id));
  }

  // Initialize sample Minecraft data
  private initializeMinecraftData() {
    // Create sample Minecraft servers
    const server1Id = randomUUID();
    const server2Id = randomUUID();
    const server3Id = randomUUID();

    const servers: MinecraftServer[] = [
      {
        id: server1Id,
        userId: 'admin',
        serverName: 'Creative Build Server',
        serverType: 'paper',
        version: '1.20.4',
        status: 'online',
        ipAddress: 'creative.gamehost.pro',
        port: 25565,
        maxPlayers: 50,
        currentPlayers: 23,
        ramAllocation: 8,
        diskSpace: 50,
        lastOnline: new Date(),
        createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 days ago
        updatedAt: new Date(),
      },
      {
        id: server2Id,
        userId: 'admin',
        serverName: 'SMP Survival',
        serverType: 'spigot',
        version: '1.20.1',
        status: 'offline',
        ipAddress: 'survival.gamehost.pro',
        port: 25566,
        maxPlayers: 20,
        currentPlayers: 0,
        ramAllocation: 4,
        diskSpace: 25,
        lastOnline: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
        createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // 30 days ago
        updatedAt: new Date(),
      },
      {
        id: server3Id,
        userId: 'admin',
        serverName: 'Modded Adventure',
        serverType: 'forge',
        version: '1.19.4',
        status: 'starting',
        ipAddress: 'modded.gamehost.pro',
        port: 25567,
        maxPlayers: 30,
        currentPlayers: 0,
        ramAllocation: 12,
        diskSpace: 100,
        lastOnline: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
        createdAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // 14 days ago
        updatedAt: new Date(),
      },
    ];

    servers.forEach(server => this.minecraftServers.set(server.id, server));

    // Create sample plugins
    const plugins: MinecraftPlugin[] = [
      {
        id: randomUUID(),
        serverId: server1Id,
        pluginName: 'WorldEdit',
        version: '7.2.15',
        author: 'sk89q',
        description: 'Fast world editing plugin for builders',
        isEnabled: true,
        installedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server1Id,
        pluginName: 'CoreProtect',
        version: '21.2',
        author: 'Intelli',
        description: 'Block logging and rollback plugin',
        isEnabled: true,
        installedAt: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server2Id,
        pluginName: 'EssentialsX',
        version: '2.20.1',
        author: 'EssentialsX Team',
        description: 'Essential commands and features',
        isEnabled: true,
        installedAt: new Date(Date.now() - 25 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server2Id,
        pluginName: 'LuckPerms',
        version: '5.4.94',
        author: 'Luck',
        description: 'Advanced permissions management',
        isEnabled: true,
        installedAt: new Date(Date.now() - 25 * 24 * 60 * 60 * 1000),
      },
    ];

    plugins.forEach(plugin => this.minecraftPlugins.set(plugin.id, plugin));

    // Create sample worlds
    const worlds: MinecraftWorld[] = [
      {
        id: randomUUID(),
        serverId: server1Id,
        worldName: 'Creative_Main',
        worldType: 'flat',
        seed: 'creative_world_2024',
        gamemode: 'creative',
        difficulty: 'peaceful',
        createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server2Id,
        worldName: 'Survival_World',
        worldType: 'default',
        seed: '-2043500553',
        gamemode: 'survival',
        difficulty: 'normal',
        createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server3Id,
        worldName: 'Modded_Adventure',
        worldType: 'biomesoplenty',
        seed: 'modded_2024',
        gamemode: 'survival',
        difficulty: 'hard',
        createdAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000),
      },
    ];

    worlds.forEach(world => this.minecraftWorlds.set(world.id, world));

    // Create sample players
    const players: MinecraftPlayer[] = [
      {
        id: randomUUID(),
        serverId: server1Id,
        playerName: 'Steve_Builder',
        uuid: '069a79f4-44e9-4726-a5be-fca90e38aaf5',
        isOnline: true,
        isOp: false,
        isBanned: false,
        isWhitelisted: true,
        playtime: 245 * 60 * 60 * 1000, // 245 hours
        lastLogin: new Date(Date.now() - 30 * 60 * 1000), // 30 min ago
        firstJoin: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server1Id,
        playerName: 'Alex_Architect',
        uuid: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        isOnline: true,
        isOp: true,
        isBanned: false,
        isWhitelisted: true,
        playtime: 180 * 60 * 60 * 1000, // 180 hours
        lastLogin: new Date(Date.now() - 5 * 60 * 1000), // 5 min ago
        firstJoin: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server2Id,
        playerName: 'Survivor123',
        uuid: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
        isOnline: false,
        isOp: false,
        isBanned: false,
        isWhitelisted: true,
        playtime: 95 * 60 * 60 * 1000, // 95 hours
        lastLogin: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3 days ago
        firstJoin: new Date(Date.now() - 28 * 24 * 60 * 60 * 1000),
      },
    ];

    players.forEach(player => this.minecraftPlayers.set(player.id, player));

    // Create sample backups
    const backups: MinecraftBackup[] = [
      {
        id: randomUUID(),
        serverId: server1Id,
        worldId: worlds[0].id,
        backupName: 'Daily Backup - Creative',
        backupType: 'full',
        status: 'completed',
        sizeBytes: 2.5 * 1024 * 1024 * 1024, // 2.5 GB
        createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server2Id,
        worldId: worlds[1].id,
        backupName: 'Weekly Backup - Survival',
        backupType: 'world',
        status: 'completed',
        sizeBytes: 1.8 * 1024 * 1024 * 1024, // 1.8 GB
        createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server1Id,
        backupName: 'Plugin Backup',
        backupType: 'plugins',
        status: 'completed',
        sizeBytes: 50 * 1024 * 1024, // 50 MB
        createdAt: new Date(Date.now() - 12 * 60 * 60 * 1000),
      },
    ];

    backups.forEach(backup => this.minecraftBackups.set(backup.id, backup));

    // Create sample logs
    const logs: MinecraftLog[] = [
      {
        id: randomUUID(),
        serverId: server1Id,
        logLevel: 'INFO',
        message: 'Server started successfully',
        source: 'System',
        timestamp: new Date(Date.now() - 30 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server1Id,
        logLevel: 'INFO',
        message: 'Steve_Builder joined the game',
        source: 'Player',
        timestamp: new Date(Date.now() - 25 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server1Id,
        logLevel: 'INFO',
        message: 'Alex_Architect joined the game',
        source: 'Player',
        timestamp: new Date(Date.now() - 20 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server1Id,
        logLevel: 'WARN',
        message: 'Player tried to use restricted command',
        source: 'Security',
        timestamp: new Date(Date.now() - 15 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server2Id,
        logLevel: 'INFO',
        message: 'Server stopped gracefully',
        source: 'System',
        timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
      },
      {
        id: randomUUID(),
        serverId: server3Id,
        logLevel: 'INFO',
        message: 'Loading forge mods...',
        source: 'Forge',
        timestamp: new Date(Date.now() - 5 * 60 * 1000),
      },
    ];

    logs.forEach(log => this.minecraftLogs.set(log.id, log));
  }

  // Promo settings methods
  async getPromoSettings(): Promise<PromoSetting | undefined> {
    return this.promoSettings || undefined;
  }

  async updatePromoSettings(settings: InsertPromoSetting): Promise<PromoSetting> {
    const promoSetting: PromoSetting = {
      id: this.promoSettings?.id || "promo-1",
      ...settings,
      updatedAt: new Date()
    };
    this.promoSettings = promoSetting;
    return promoSetting;
  }

  // Theme settings methods
  async getThemeSettings(): Promise<any> {
    return this.themeSettings || {
      primaryColor: "#22c55e",
      backgroundColor: "#0a0a0a",
      accentColor: "#34d399",
      textColor: "#ffffff",
      cardColor: "#1a1a1a",
      siteName: "VoltServers",
      siteTagline: "Premium Game Server Hosting",
      siteDescription: "Professional game server hosting with 24/7 support and premium hardware",
      heroTitle: "Deploy Your Game Server in Minutes",
      heroSubtitle: "Experience lightning-fast deployment with our premium game server hosting platform",
      heroDescription: "Join thousands of gamers who trust our reliable infrastructure for their Minecraft, CS2, Rust, and other game servers.",
      heroButtonText: "Get Started",
      heroButtonUrl: "/pricing",
      logoUrl: null,
      faviconUrl: null,
      footerText: null,
      fontFamily: "Inter",
      borderRadius: "0.5rem",
      holidayTheme: "none"
    };
  }

  async updateThemeSettings(settings: any): Promise<any> {
    this.themeSettings = { ...this.themeSettings, ...settings };
    return this.themeSettings;
  }
}

// Create a shared singleton memory storage instance for persistence across requests
const sharedMemStorage = new MemStorage();

// Use DatabaseStorage for persistence, with shared memory fallback
export const storage = new DatabaseStorage();
export const memStorage = sharedMemStorage;
