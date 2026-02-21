#!/bin/bash
# OpenClaw Auto-Provisioning Script
# Usage: ./provision.sh <customer_email> <messaging_app>

set -e

CUSTOMER_EMAIL=$1
MESSAGING_APP=${2:-telegram}
VPS_IP=$(hostname -I | awk '{print $1}')

echo "=== OpenClaw Provisioning ==="
echo "Customer: $CUSTOMER_EMAIL"
echo "Messaging: $MESSAGING_APP"
echo "IP: $VPS_IP"

# Update system
echo "[1/6] Updating system..."
apt update && apt upgrade -y

# Install Docker
echo "[2/6] Installing Docker..."
curl -fsSL https://get.docker.com | sh
systemctl enable docker

# Create openclaw user
echo "[3/6] Creating isolated user..."
useradd -m -s /bin/bash openclaw || true
usermod -aG docker openclaw

# Firewall setup
echo "[4/6] Configuring firewall..."
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw --force enable

# Install OpenClaw (placeholder - would use actual install method)
echo "[5/6] Installing OpenClaw..."
mkdir -p /opt/openclaw
cd /opt/openclaw

# TODO: Add actual OpenClaw installation
# curl -sL https://get.openclaw.ai | sh -s -- --email $CUSTOMER_EMAIL

# Security hardening
echo "[6/6] Security hardening..."
# - Disable root login
# - Set up fail2ban
# - Configure backups

echo "=== Provisioning Complete ==="
echo "Next steps:"
echo "1. Configure messaging ($MESSAGING_APP)"
echo "2. Set up API keys"
echo "3. Test connectivity"
