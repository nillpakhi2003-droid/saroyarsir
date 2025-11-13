#!/bin/bash
#
# Quick Deploy Script - Fast deployment without full optimization
# Use this for code updates when database doesn't need optimization
#
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="/var/www/saroyarsir"
SERVICE_NAME="saro.service"

echo -e "${GREEN}🚀 Quick Deploy Starting...${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run with sudo${NC}"
    exit 1
fi

cd $APP_DIR

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin main

# Restart service
echo "🔄 Restarting service..."
systemctl restart $SERVICE_NAME

# Wait and check status
sleep 2

if systemctl is-active --quiet $SERVICE_NAME; then
    echo -e "${GREEN}✅ Service restarted successfully${NC}"
    echo ""
    echo "Last commit:"
    git log -1 --oneline
    echo ""
    echo "Service status:"
    systemctl status $SERVICE_NAME --no-pager -l | head -10
else
    echo -e "${RED}❌ Service failed to start${NC}"
    echo "Check logs: journalctl -u $SERVICE_NAME -n 50"
    exit 1
fi
