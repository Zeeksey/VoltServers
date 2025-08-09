# VS Code Setup Guide

This guide helps you set up VS Code to work with your VoltServers project.

## Option 1: Local Development

### Prerequisites
1. Install [Node.js](https://nodejs.org/) (version 16 or higher)
2. Install [VS Code](https://code.visualstudio.com/)
3. Install [Git](https://git-scm.com/) (if cloning from repository)

### Setup Steps
1. **Clone/Download the project** to your local machine
2. **Open the project** in VS Code (`File > Open Folder`)
3. **Install recommended extensions** - VS Code will prompt you to install the recommended extensions from `.vscode/extensions.json`
4. **Install dependencies**:
   ```bash
   npm install
   ```
5. **Set up environment variables**:
   - Create a `.env` file in the project root
   - Add your database URL and any API keys:
     ```
     DATABASE_URL=your_postgresql_connection_string
     SESSION_SECRET=your_session_secret
     ```

6. **Run the development server**:
   ```bash
   npm run dev
   ```

### VS Code Features Configured
- **IntelliSense** for TypeScript and React
- **Tailwind CSS** autocomplete and validation
- **Debugging** configuration for both frontend and backend
- **Tasks** for common development commands
- **Auto-formatting** on save
- **Path intellisense** for imports

## Option 2: Remote Development (Replit Integration)

### Using Replit Extension
1. Install the [Replit VS Code Extension](https://marketplace.visualstudio.com/items?itemName=replit.replit)
2. Connect to your Replit workspace
3. Edit files directly in VS Code while running on Replit

### Using GitHub Codespaces (if project is on GitHub)
1. Open the repository in GitHub
2. Click "Code" > "Codespaces" > "Create codespace"
3. VS Code will open in your browser with full development environment

## Option 3: SSH/Remote Connection

If your project is running on a remote server:
1. Install the [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
2. Configure SSH connection to your server
3. Open the remote folder in VS Code

## Recommended Extensions

The following extensions are automatically suggested when you open the project:

- **TypeScript and JavaScript Language Features** - Enhanced TypeScript support
- **Tailwind CSS IntelliSense** - Autocomplete and validation for Tailwind classes
- **Prettier** - Code formatting
- **ESLint** - Code linting and error detection
- **Auto Rename Tag** - Automatically rename paired HTML/JSX tags
- **Path Intellisense** - Autocomplete for file paths
- **Material Icon Theme** - Better file icons
- **Todo Tree** - Highlight TODO comments
- **Code Spell Checker** - Spell checking for code

## Available Tasks (Ctrl+Shift+P > "Tasks: Run Task")

- **Start Development Server** - Runs `npm run dev`
- **Install Dependencies** - Runs `npm install`
- **Database Push** - Runs `npm run db:push`
- **Type Check** - Runs TypeScript compiler check

## Debugging

Two debug configurations are available:
1. **Launch Application** - Starts the full application with debugging
2. **Debug Server Only** - Debugs just the backend server

Access via the Debug panel (Ctrl+Shift+D) or F5 to start debugging.

## Project Structure

```
├── .vscode/                 # VS Code configuration
├── client/                  # Frontend React application
│   ├── src/                # React components and pages
│   └── public/             # Static assets
├── server/                  # Backend Express server
│   ├── routes.ts           # API routes
│   ├── storage.ts          # Data storage interface
│   └── database-storage.ts # Database implementation
├── shared/                  # Shared TypeScript types
│   └── schema.ts           # Database schema and types
└── package.json            # Dependencies and scripts
```

## Troubleshooting

### Common Issues
1. **Import errors** - Make sure to run `npm install` after opening the project
2. **TypeScript errors** - Run "TypeScript: Reload Projects" from command palette
3. **Tailwind not working** - Ensure the Tailwind CSS extension is installed and enabled
4. **Database connection issues** - Check your `.env` file and database URL

### Need Help?
- Check the project's README.md for additional setup instructions
- Review the deployment guides for production setup
- Ensure all environment variables are properly configured