#!/bin/bash

#####################################################################
# Deploy Online Exam System to VPS
#####################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "════════════════════════════════════════════════════════════"
echo "  🎓 Deploying Online Exam System to VPS"
echo "════════════════════════════════════════════════════════════"
echo -e "${NC}"

VPS_DIR="/var/www/saroyarsir"
DB_PATH="$VPS_DIR/smartgardenhub.db"

echo -e "${YELLOW}📋 What's New:${NC}"
echo "  ✅ Online MCQ Exam System"
echo "  ✅ Teacher can create class-wise exams"
echo "  ✅ Up to 40 questions per exam with 4 options each"
echo "  ✅ Auto-submit when time expires"
echo "  ✅ Instant results with explanations"
echo "  ✅ Retake functionality"
echo "  ✅ Analytics for teachers"
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
    fi
    
    echo -e "\n${YELLOW}2️⃣  Stopping service...${NC}"
    sudo systemctl stop saro 2>/dev/null || true
    echo -e "${GREEN}✅ Service stopped${NC}"
    
    echo -e "\n${YELLOW}3️⃣  Pulling latest code...${NC}"
    cd "$VPS_DIR"
    git pull origin main
    echo -e "${GREEN}✅ Code updated${NC}"
    
    echo -e "\n${YELLOW}4️⃣  Creating database tables...${NC}"
    source venv/bin/activate
    python3 << 'PYTHON_EOF'
from app import create_app
from models import db

app = create_app('production')
with app.app_context():
    db.create_all()
    print("✅ Database tables created/updated")
PYTHON_EOF
    
    echo -e "\n${YELLOW}5️⃣  Restarting service...${NC}"
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
    echo "════════════════════════════════════════════════════════════"
    echo "  ✅ ONLINE EXAM SYSTEM DEPLOYED!"
    echo "════════════════════════════════════════════════════════════"
    echo -e "${NC}"
    
    echo -e "${YELLOW}📝 New Database Tables:${NC}"
    echo "  • online_exams - Exam details"
    echo "  • online_questions - Questions with 4 options each"
    echo "  • online_exam_attempts - Student attempts"
    echo "  • online_student_answers - Individual answers"
    echo ""
    echo -e "${YELLOW}🔌 New API Endpoints:${NC}"
    echo "  • POST   /api/online-exams - Create exam"
    echo "  • GET    /api/online-exams - List exams"
    echo "  • POST   /api/online-exams/{id}/questions - Add question"
    echo "  • POST   /api/online-exams/{id}/start - Start exam"
    echo "  • POST   /api/online-exams/attempts/{id}/submit - Submit"
    echo "  • GET    /api/online-exams/attempts/{id}/results - Results"
    echo ""
    echo -e "${YELLOW}📖 Full Documentation:${NC}"
    echo "  See ONLINE_EXAM_SYSTEM.md for complete guide"
    echo ""
    
else
    # Not on VPS - show instructions
    echo ""
    echo -e "${YELLOW}📋 DEPLOYMENT INSTRUCTIONS FOR VPS:${NC}"
    echo ""
    echo "1. Commit and push changes:"
    echo "   ${GREEN}git add .${NC}"
    echo "   ${GREEN}git commit -m \"Add Online Exam System\"${NC}"
    echo "   ${GREEN}git push origin main${NC}"
    echo ""
    echo "2. SSH to your VPS:"
    echo "   ${GREEN}ssh your_user@gsteaching.com${NC}"
    echo ""
    echo "3. Run deployment:"
    echo "   ${GREEN}cd /var/www/saroyarsir${NC}"
    echo "   ${GREEN}sudo bash deploy_online_exam_system.sh${NC}"
    echo ""
fi
