#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🦞 OpenClaw Quick Deploy${NC}"
echo "=============================="

# Check prerequisites
check_prereqs() {
    echo -e "\n${YELLOW}Checking prerequisites...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}Docker Compose is not installed.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisites OK${NC}"
}

# Get instance name
get_instance_name() {
    echo -e "\n${YELLOW}Enter instance name (e.g., customer-1, production):${NC}"
    read -p "> " INSTANCE_NAME
    
    if [ -z "$INSTANCE_NAME" ]; then
        INSTANCE_NAME="openclaw-default"
    fi
}

# Get Telegram token
get_telegram_token() {
    echo -e "\n${YELLOW}Enter Telegram Bot Token (or press Enter to skip):${NC}"
    read -p "> " TELEGRAM_TOKEN
    
    if [ -n "$TELEGRAM_TOKEN" ]; then
        TELEGRAM_ENABLED=true
    else
        TELEGRAM_ENABLED=false
        TELEGRAM_TOKEN=""
    fi
}

# Generate .env file
generate_env() {
    echo -e "\n${YELLOW}Generating configuration...${NC}"
    
    SECRET=$(openssl rand -hex 32)
    
    cat > .env.${INSTANCE_NAME} << EOF
# OpenClaw Instance: ${INSTANCE_NAME}
# Generated: $(date)

COMPOSE_PROJECT_NAME=${INSTANCE_NAME}

TELEGRAM_ENABLED=${TELEGRAM_ENABLED}
TELEGRAM_BOT_TOKEN=${TELEGRAM_TOKEN}
OPENCLAW_SECRET=${SECRET}

# Data persistence
OPENCLAW_DATA_DIR=./data/${INSTANCE_NAME}
EOF
    
    echo -e "${GREEN}✓ Configuration saved to .env.${INSTANCE_NAME}${NC}"
}

# Deploy
deploy() {
    echo -e "\n${YELLOW}Deploying OpenClaw...${NC}"
    
    # Create data directory
    mkdir -p data/${INSTANCE_NAME}
    
    # Run docker compose
    export COMPOSE_PROJECT_NAME=${INSTANCE_NAME}
    export TELEGRAM_ENABLED
    export TELEGRAM_BOT_TOKEN
    
    if docker compose -f docker-compose.yml up -d --build; then
        echo -e "${GREEN}✓ OpenClaw deployed!${NC}"
    else
        echo -e "${RED}✗ Deployment failed${NC}"
        exit 1
    fi
}

# Show status
show_status() {
    echo -e "\n${BLUE}Instance Status:${NC}"
    docker compose -f docker-compose.yml ps
    
    echo -e "\n${BLUE}Ports:${NC}"
    echo "  - HTTP: http://localhost:18789"
    echo "  - Control UI: http://localhost:18789/"
    
    echo -e "\n${GREEN}🎉 Deployment complete!${NC}"
}

# Main
main() {
    check_prereqs
    get_instance_name
    get_telegram_token
    generate_env
    deploy
    show_status
}

main "$@"
