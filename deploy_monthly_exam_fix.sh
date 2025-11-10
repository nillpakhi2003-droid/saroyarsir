#!/bin/bash

#####################################################################
# Deploy Monthly Exam Delete Fix to VPS
# Fixes cascade delete for monthly exams and individual exams
#####################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}"
echo "═══════════════════════════════════════════════════════════"
echo "  🔧 Deploying Monthly Exam Delete Fix to VPS"
echo "═══════════════════════════════════════════════════════════"
echo -e "${NC}"

VPS_DIR="/var/www/saroyarsir"
DB_PATH="$VPS_DIR/smartgardenhub.db"

echo -e "${YELLOW}📋 What this fix does:${NC}"
echo "  ✅ Allows deletion of individual exams even if marks exist"
echo "  ✅ Cascade deletes all associated marks when deleting exams"
echo "  ✅ Allows deletion of monthly exam periods with all data"
echo "  ✅ Properly cleans up rankings when exams are deleted"
echo ""

# Check if running on VPS or local
if [ -d "$VPS_DIR" ]; then
    echo -e "${GREEN}✅ VPS environment detected${NC}"
    IS_VPS=true
else
    echo -e "${YELLOW}⚠️  Not running on VPS - displaying instructions${NC}"
    IS_VPS=false
fi

if [ "$IS_VPS" = true ]; then
    echo -e "\n${YELLOW}1️⃣  Backing up database...${NC}"
    if [ -f "$DB_PATH" ]; then
        cp "$DB_PATH" "$DB_PATH.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✅ Database backed up${NC}"
    else
        echo -e "${RED}⚠️  Database not found at $DB_PATH${NC}"
    fi
    
    echo -e "\n${YELLOW}2️⃣  Stopping service...${NC}"
    sudo systemctl stop saro 2>/dev/null || true
    echo -e "${GREEN}✅ Service stopped${NC}"
    
    echo -e "\n${YELLOW}3️⃣  Pulling latest code...${NC}"
    cd "$VPS_DIR"
    git pull origin main
    echo -e "${GREEN}✅ Code updated${NC}"
    
    echo -e "\n${YELLOW}4️⃣  Restarting service...${NC}"
    sudo systemctl start saro
    sleep 2
    
    if systemctl is-active --quiet saro; then
        echo -e "${GREEN}✅ Service restarted successfully${NC}"
    else
        echo -e "${RED}❌ Service failed to start${NC}"
        echo -e "${YELLOW}Check logs: sudo journalctl -u saro -n 50${NC}"
        exit 1
    fi
    
    echo -e "\n${GREEN}"
    echo "═══════════════════════════════════════════════════════════"
    echo "  ✅ DEPLOYMENT COMPLETED SUCCESSFULLY!"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    
    echo -e "${YELLOW}📝 Changes applied:${NC}"
    echo "  • Individual exams can now be deleted with all marks"
    echo "  • Monthly exams can be deleted with cascade cleanup"
    echo "  • Rankings are automatically cleaned up"
    echo ""
    echo -e "${YELLOW}🧪 Test the fix:${NC}"
    echo "  1. Login as teacher"
    echo "  2. Try deleting an individual exam with marks"
    echo "  3. It should delete successfully with all marks"
    echo ""
    
else
    # Not on VPS - show instructions
    echo ""
    echo -e "${YELLOW}📋 DEPLOYMENT INSTRUCTIONS FOR VPS:${NC}"
    echo ""
    echo "1. Push changes to GitHub:"
    echo "   ${GREEN}git add .${NC}"
    echo "   ${GREEN}git commit -m \"Fix monthly exam delete cascade\"${NC}"
    echo "   ${GREEN}git push origin main${NC}"
    echo ""
    echo "2. SSH to your VPS:"
    echo "   ${GREEN}ssh your_user@gsteaching.com${NC}"
    echo ""
    echo "3. Run deployment:"
    echo "   ${GREEN}cd /var/www/saroyarsir${NC}"
    echo "   ${GREEN}sudo bash deploy_monthly_exam_fix.sh${NC}"
    echo ""
    echo "Or use quick update:"
    echo "   ${GREEN}cd /var/www/saroyarsir${NC}"
    echo "   ${GREEN}bash quick_update.sh${NC}"
    echo ""
fi
