module.exports = {
  apps: [
    {
      name: "MCBitcoin",
      script: "/app/mc-dolleurz/dist/app.js",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "1G",
      cwd: "/app/mc-dolleurz",
      exec_mode: "fork"
    },
  ],
};
