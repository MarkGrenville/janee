module.exports = {
  apps: [
    {
      name: 'janee-emulators',
      cwd: __dirname,
      script: 'npx',
      args: 'firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data',
      autorestart: false,
      watch: false,
      env: {
        FIRESTORE_EMULATOR_HOST: 'localhost:6412',
        FIREBASE_AUTH_EMULATOR_HOST: 'localhost:6411',
        FIREBASE_STORAGE_EMULATOR_HOST: 'localhost:6415',
      },
    },
    {
      name: 'janee-web',
      cwd: `${__dirname}/web`,
      script: 'npx',
      args: 'vite dev --port 6400 --host',
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'development',
        PUBLIC_FIREBASE_AUTH_EMULATOR_HOST: 'localhost:6411',
        PUBLIC_FIRESTORE_EMULATOR_HOST: 'localhost:6412',
        PUBLIC_FIREBASE_STORAGE_EMULATOR_HOST: 'localhost:6415',
        PUBLIC_FIREBASE_FUNCTIONS_EMULATOR_HOST: 'localhost:6413',
      },
    },
    {
      name: 'janee-flutter',
      cwd: `${__dirname}/app`,
      script: 'flutter',
      args: 'run -d chrome --web-port=6410',
      autorestart: false,
      watch: false,
    },
    {
      name: 'janee-backup',
      cwd: __dirname,
      script: 'bash',
      args: 'scripts/backup-emulator.sh',
      autorestart: true,
      watch: false,
      restart_delay: 180000,
    },
  ],
};
