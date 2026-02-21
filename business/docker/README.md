# 🦞 OpenClaw Docker Deployment

Quickly deploy OpenClaw instances using Docker.

## 🚀 Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/jjsmithok/openclaw-business.git
cd openclaw-business/docker

# 2. Run the deploy script
chmod +x deploy.sh
./deploy.sh

# 3. Enter your instance name and Telegram bot token
```

That's it! OpenClaw will be running on http://localhost:18789

---

## 📋 Requirements

- Docker 20.10+
- Docker Compose v2+
- OpenSSL (for secret generation)

---

## 🔧 Configuration

Edit the `.env` file:

| Variable | Description |
|----------|-------------|
| `TELEGRAM_ENABLED` | Enable Telegram bot |
| `TELEGRAM_BOT_TOKEN` | Your Telegram bot token |
| `OPENCLAW_SECRET` | Auto-generated secure secret |

---

## 🐳 Manual Deployment

```bash
# Build and start
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

---

## 🌐 Ports

| Port | Service |
|------|---------|
| 18789 | OpenClaw Gateway HTTP |
| 18790 | Control UI WebSocket |

---

## 📦 Fleet Management

Manage multiple instances:

```bash
# Create new instance
./fleet.sh create customer-1

# List all instances
./fleet.sh list

# Start/stop/restart
./fleet.sh start customer-1
./fleet.sh stop customer-1
./fleet.sh restart customer-1

# View logs
./fleet.sh logs customer-1

# Delete instance
./fleet.sh delete customer-1
```

---

## 🔒 Security

- All data stored in Docker volumes
- Random secrets auto-generated
- Run behind Traefik for SSL (optional)

---

## 🆘 Troubleshooting

```bash
# Check if container is running
docker ps | grep openclaw

# View logs
docker compose logs

# Restart
docker compose restart

# Rebuild
docker compose build --no-cache
docker compose up -d
```

---

## 📝 License

MIT
