#!/bin/bash
set -e

# OpenClaw Fleet Manager - Deploy and manage multiple instances

COMMAND="$1"
INSTANCE="$2"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTANCES_DIR="./instances"

usage() {
    echo "🦞 OpenClaw Fleet Manager"
    echo ""
    echo "Usage: $0 <command> [instance-name]"
    echo ""
    echo "Commands:"
    echo "  list              List all instances"
    echo "  create <name>    Create new instance"
    echo "  start <name>     Start instance"
    echo "  stop <name>      Stop instance"
    echo "  restart <name>   Restart instance"
    echo "  logs <name>      View logs"
    echo "  delete <name>    Delete instance"
    echo "  status <name>    Show instance status"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 create customer-1"
    echo "  $0 logs customer-1"
}

list_instances() {
    echo -e "${BLUE}Instances:${NC}"
    if [ -d "$INSTANCES_DIR" ]; then
        for dir in $INSTANCES_DIR/*/; do
            if [ -d "$dir" ]; then
                name=$(basename "$dir")
                if [ -f "$dir/docker-compose.yml" ]; then
                    status=$(cd "$dir" && docker compose ps --format json 2>/dev/null | grep -q "running" && echo "running" || echo "stopped")
                    echo "  - $name ($status)"
                fi
            fi
        done
    else
        echo "  No instances found"
    fi
}

create_instance() {
    if [ -z "$INSTANCE" ]; then
        echo -e "${RED}Please specify instance name${NC}"
        exit 1
    fi
    
    INSTANCE_DIR="$INSTANCES_DIR/$INSTANCE"
    
    if [ -d "$INSTANCE_DIR" ]; then
        echo -e "${RED}Instance '$INSTANCE' already exists${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Creating instance: $INSTANCE${NC}"
    
    # Create directory
    mkdir -p "$INSTANCE_DIR"
    
    # Copy docker files
    cp docker/docker-compose.yml "$INSTANCE_DIR/"
    cp docker/.env.example "$INSTANCE_DIR/.env"
    
    # Create data directory
    mkdir -p "$INSTANCE_DIR/data"
    
    echo -e "${GREEN}✓ Instance created at $INSTANCE_DIR${NC}"
    echo "Edit .env with your configuration, then run:"
    echo "  cd $INSTANCE_DIR && docker compose up -d"
}

start_instance() {
    if [ ! -d "$INSTANCES_DIR/$INSTANCE" ]; then
        echo -e "${RED}Instance '$INSTANCE' not found${NC}"
        exit 1
    fi
    
    cd "$INSTANCES_DIR/$INSTANCE"
    docker compose up -d
    echo -e "${GREEN}✓ Instance started${NC}"
}

stop_instance() {
    if [ ! -d "$INSTANCES_DIR/$INSTANCE" ]; then
        echo -e "${RED}Instance '$INSTANCE' not found${NC}"
        exit 1
    fi
    
    cd "$INSTANCES_DIR/$INSTANCE"
    docker compose stop
    echo -e "${GREEN}✓ Instance stopped${NC}"
}

restart_instance() {
    stop_instance
    start_instance
}

delete_instance() {
    if [ ! -d "$INSTANCES_DIR/$INSTANCE" ]; then
        echo -e "${RED}Instance '$INSTANCE' not found${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}This will delete all data for '$INSTANCE'. Continue? (y/N)${NC}"
    read -p "> " confirm
    
    if [ "$confirm" = "y" ]; then
        cd "$INSTANCES_DIR/$INSTANCE"
        docker compose down -v 2>/dev/null || true
        rm -rf "$INSTANCES_DIR/$INSTANCE"
        echo -e "${GREEN}✓ Instance deleted${NC}"
    else
        echo "Cancelled"
    fi
}

show_logs() {
    if [ ! -d "$INSTANCES_DIR/$INSTANCE" ]; then
        echo -e "${RED}Instance '$INSTANCE' not found${NC}"
        exit 1
    fi
    
    cd "$INSTANCES_DIR/$INSTANCE"
    docker compose logs -f
}

show_status() {
    if [ ! -d "$INSTANCES_DIR/$INSTANCE" ]; then
        echo -e "${RED}Instance '$INSTANCE' not found${NC}"
        exit 1
    fi
    
    cd "$INSTANCES_DIR/$INSTANCE"
    docker compose ps
}

case "$COMMAND" in
    list)
        list_instances
        ;;
    create)
        create_instance
        ;;
    start)
        start_instance
        ;;
    stop)
        stop_instance
        ;;
    restart)
        restart_instance
        ;;
    delete)
        delete_instance
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    *)
        usage
        ;;
esac
