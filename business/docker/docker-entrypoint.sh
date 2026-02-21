#!/bin/bash
set -e

echo "🦞 Starting OpenClaw..."

# Wait for Docker daemon (if running in Docker)
if [ -z "$SKIP_DOCKER_WAIT" ]; then
    echo "Waiting for Docker..."
    until docker info >/dev/null 2>&1; do
        sleep 1
    done
fi

# Generate secure random secrets if not provided
export OPENCLAW_SECRET=${OPENCLAW_SECRET:-$(openssl rand -hex 32)}

# Create config directory
mkdir -p /app/config

# If no config exists, create default
if [ ! -f /app/config/openclaw.json ]; then
    echo "Creating default configuration..."
    cat > /app/config/openclaw.json << EOF
{
  "channels": {
    "telegram": {
      "enabled": ${TELEGRAM_ENABLED:-false},
      "botToken": "${TELEGRAM_BOT_TOKEN:-}"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "0.0.0.0"
  }
}
EOF
fi

# Install OpenClaw if not already installed
if ! command -v openclaw &> /dev/null; then
    echo "Installing OpenClaw..."
    npm install -g openclaw@latest
fi

# Run OpenClaw gateway
echo "Starting OpenClaw gateway on port 18789..."
exec openclaw gateway --port 18789 --bind 0.0.0.0
