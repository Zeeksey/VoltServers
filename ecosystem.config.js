// PM2 ecosystem configuration for VoltServers
// This file uses CommonJS format for PM2 compatibility

const apps = [{
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
}];

module.exports = {
  apps: apps
};