#!/bin/bash
#
# SQLite Production Deployment Script for VPS
# This script deploys the application with SQLite optimizations for production
#
set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/var/www/saroyarsir"
DB_FILE="$APP_DIR/smartgardenhub.db"
BACKUP_DIR="$APP_DIR/backups"
SERVICE_NAME="saro.service"
VENV_DIR="$APP_DIR/venv"
LOG_DIR="/var/log"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   SQLite Production Deployment Script${NC}"
echo -e "${BLUE}================================================${NC}"

# Function to print section headers
print_section() {
    echo ""
    echo -e "${GREEN}=== $1 ===${NC}"
}

# Function to print errors
print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

# Function to print warnings
print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root or with sudo"
    exit 1
fi

print_section "Step 1: Stopping Service"
if systemctl is-active --quiet $SERVICE_NAME; then
    systemctl stop $SERVICE_NAME
    print_success "Service stopped"
else
    print_warning "Service was not running"
fi

print_section "Step 2: Creating Backup"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/smartgardenhub_${TIMESTAMP}.db"

if [ -f "$DB_FILE" ]; then
    cp "$DB_FILE" "$BACKUP_FILE"
    print_success "Database backed up to: $BACKUP_FILE"
    
    # Keep only last 10 backups
    cd $BACKUP_DIR
    ls -t smartgardenhub_*.db | tail -n +11 | xargs -r rm
    print_success "Cleaned old backups (keeping last 10)"
else
    print_warning "No existing database found - fresh installation"
fi

print_section "Step 3: Pulling Latest Code"
cd $APP_DIR
git fetch origin
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
print_warning "Current branch: $CURRENT_BRANCH"

git pull origin $CURRENT_BRANCH
print_success "Code updated to latest version"

# Show last commit
LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%ar)")
echo "Last commit: $LAST_COMMIT"

print_section "Step 4: Setting Up Python Virtual Environment"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
    print_success "Virtual environment created"
else
    print_success "Virtual environment exists"
fi

# Activate virtual environment
source $VENV_DIR/bin/activate

print_section "Step 5: Installing/Updating Python Dependencies"
pip install --upgrade pip
pip install -r requirements.txt
print_success "Dependencies installed"

print_section "Step 6: Configuring SQLite for Production"

# Create optimized config_sqlite.py if it doesn't exist
cat > $APP_DIR/config_sqlite_prod.py << 'EOF'
"""
SQLite Production Configuration
Optimizations for production use with SQLite
"""
import os

# Database Configuration
SQLALCHEMY_DATABASE_URI = 'sqlite:///smartgardenhub.db'
SQLALCHEMY_TRACK_MODIFICATIONS = False

# SQLite Optimizations for Production
SQLALCHEMY_ENGINE_OPTIONS = {
    'connect_args': {
        'timeout': 30,  # Increase timeout for busy database
        'check_same_thread': False,  # Allow multi-threaded access
        'isolation_level': None,  # Autocommit mode for better concurrency
    },
    'pool_pre_ping': True,  # Verify connections before using
    'pool_recycle': 3600,  # Recycle connections after 1 hour
    'echo': False,  # Disable SQL query logging in production
}

# Session Configuration
SESSION_COOKIE_SECURE = True  # Use HTTPS only
SESSION_COOKIE_HTTPONLY = True  # Prevent JavaScript access
SESSION_COOKIE_SAMESITE = 'Lax'  # CSRF protection
PERMANENT_SESSION_LIFETIME = 86400  # 24 hours

# Security
SECRET_KEY = os.environ.get('SECRET_KEY') or os.urandom(32).hex()
EOF

print_success "SQLite production config created"

print_section "Step 7: Optimizing SQLite Database"

# Create optimization script
cat > $APP_DIR/optimize_sqlite.py << 'EOF'
#!/usr/bin/env python3
"""
SQLite Database Optimization Script
Applies production optimizations to SQLite database
"""
import sqlite3
import os
import sys

DB_PATH = '/var/www/saroyarsir/smartgardenhub.db'

def optimize_database():
    """Apply SQLite optimizations"""
    print("🔧 Optimizing SQLite database...")
    
    if not os.path.exists(DB_PATH):
        print(f"❌ Database not found: {DB_PATH}")
        return False
    
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()
        
        # Enable WAL (Write-Ahead Logging) mode for better concurrency
        cursor.execute("PRAGMA journal_mode=WAL;")
        print("✅ Enabled WAL mode (better concurrency)")
        
        # Set synchronous to NORMAL (good balance of safety and performance)
        cursor.execute("PRAGMA synchronous=NORMAL;")
        print("✅ Set synchronous mode to NORMAL")
        
        # Set cache size to 10MB (10000 pages of 1KB each)
        cursor.execute("PRAGMA cache_size=-10000;")
        print("✅ Set cache size to 10MB")
        
        # Enable memory-mapped I/O (faster reads)
        cursor.execute("PRAGMA mmap_size=268435456;")  # 256MB
        print("✅ Enabled memory-mapped I/O (256MB)")
        
        # Set temp store to memory
        cursor.execute("PRAGMA temp_store=MEMORY;")
        print("✅ Set temp storage to memory")
        
        # Optimize database (rebuild indexes, reclaim space)
        cursor.execute("VACUUM;")
        print("✅ Database vacuumed")
        
        cursor.execute("ANALYZE;")
        print("✅ Statistics analyzed")
        
        # Check integrity
        cursor.execute("PRAGMA integrity_check;")
        result = cursor.fetchone()
        if result[0] == 'ok':
            print("✅ Database integrity check passed")
        else:
            print(f"⚠️  Database integrity issues: {result}")
        
        conn.commit()
        conn.close()
        
        # Get database size
        size_bytes = os.path.getsize(DB_PATH)
        size_mb = size_bytes / (1024 * 1024)
        print(f"📊 Database size: {size_mb:.2f} MB")
        
        return True
        
    except Exception as e:
        print(f"❌ Error optimizing database: {e}")
        return False

if __name__ == "__main__":
    success = optimize_database()
    sys.exit(0 if success else 1)
EOF

chmod +x $APP_DIR/optimize_sqlite.py
python3 $APP_DIR/optimize_sqlite.py
print_success "Database optimized for production"

print_section "Step 8: Setting Correct Permissions"

# Set ownership
chown -R www-data:www-data $APP_DIR
print_success "Ownership set to www-data"

# Set file permissions
find $APP_DIR -type f -exec chmod 644 {} \;
find $APP_DIR -type d -exec chmod 755 {} \;

# Make scripts executable
chmod +x $APP_DIR/*.sh
chmod +x $APP_DIR/*.py

# Database file needs write permission
chmod 664 $DB_FILE
chmod 775 $(dirname $DB_FILE)
print_success "File permissions set"

print_section "Step 9: Configuring Systemd Service"

# Create/update systemd service file
cat > /etc/systemd/system/$SERVICE_NAME << EOF
[Unit]
Description=Saro Student Management System
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
Environment="PYTHONUNBUFFERED=1"
Environment="FLASK_ENV=production"

# SQLite-specific optimizations
Environment="SQLITE_TMPDIR=/tmp"

ExecStart=$VENV_DIR/bin/gunicorn \\
    --bind 0.0.0.0:8001 \\
    --workers 4 \\
    --threads 2 \\
    --worker-class gthread \\
    --timeout 120 \\
    --keep-alive 5 \\
    --max-requests 1000 \\
    --max-requests-jitter 50 \\
    --access-logfile $LOG_DIR/saro_access.log \\
    --error-logfile $LOG_DIR/saro_error.log \\
    --log-level info \\
    app:app

Restart=always
RestartSec=10

# Resource limits
LimitNOFILE=4096
MemoryLimit=1G

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
print_success "Systemd service configured"

print_section "Step 10: Creating Maintenance Scripts"

# Daily backup script
cat > $APP_DIR/backup_daily.sh << 'EOF'
#!/bin/bash
# Daily SQLite backup script

APP_DIR="/var/www/saroyarsir"
DB_FILE="$APP_DIR/smartgardenhub.db"
BACKUP_DIR="$APP_DIR/backups/daily"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Create backup
cp "$DB_FILE" "$BACKUP_DIR/backup_${TIMESTAMP}.db"

# Compress old backups (older than 1 day)
find $BACKUP_DIR -name "backup_*.db" -mtime +1 -exec gzip {} \;

# Keep only last 30 days of backups
find $BACKUP_DIR -name "backup_*.db.gz" -mtime +30 -delete

echo "$(date): Daily backup completed" >> $APP_DIR/backup.log
EOF

chmod +x $APP_DIR/backup_daily.sh

# Add to crontab if not exists
CRON_JOB="0 2 * * * $APP_DIR/backup_daily.sh"
(crontab -l 2>/dev/null | grep -F "$APP_DIR/backup_daily.sh" > /dev/null) || \
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

print_success "Daily backup script created and scheduled (2 AM daily)"

# Health check script
cat > $APP_DIR/health_check.sh << 'EOF'
#!/bin/bash
# Health check script

SERVICE_NAME="saro.service"
APP_URL="http://localhost:8001"

# Check if service is running
if ! systemctl is-active --quiet $SERVICE_NAME; then
    echo "$(date): Service is down! Restarting..." >> /var/log/saro_health.log
    systemctl restart $SERVICE_NAME
    exit 1
fi

# Check if app responds
if ! curl -s -f -o /dev/null "$APP_URL"; then
    echo "$(date): App not responding! Restarting..." >> /var/log/saro_health.log
    systemctl restart $SERVICE_NAME
    exit 1
fi

exit 0
EOF

chmod +x $APP_DIR/health_check.sh
print_success "Health check script created"

print_section "Step 11: Configuring Nginx (if needed)"

# Check if nginx is installed
if command -v nginx &> /dev/null; then
    NGINX_CONFIG="/etc/nginx/sites-available/saroyarsir"
    
    if [ ! -f "$NGINX_CONFIG" ]; then
        print_warning "Creating Nginx configuration..."
        
        cat > $NGINX_CONFIG << 'EOF'
server {
    listen 80;
    server_name your_domain.com www.your_domain.com;
    
    client_max_body_size 50M;
    
    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # Static files (if serving directly)
    location /static {
        alias /var/www/saroyarsir/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
        
        ln -sf $NGINX_CONFIG /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
        print_success "Nginx configured"
    else
        print_success "Nginx configuration exists"
    fi
else
    print_warning "Nginx not installed - skipping nginx configuration"
fi

print_section "Step 12: Starting Service"
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# Wait a moment for service to start
sleep 3

if systemctl is-active --quiet $SERVICE_NAME; then
    print_success "Service started successfully"
else
    print_error "Service failed to start"
    echo "Check logs with: journalctl -u $SERVICE_NAME -n 50"
    exit 1
fi

print_section "Step 13: Verification"

# Check service status
echo "Service Status:"
systemctl status $SERVICE_NAME --no-pager -l | head -20

echo ""
echo "Recent Logs:"
journalctl -u $SERVICE_NAME -n 10 --no-pager

# Test HTTP endpoint
echo ""
if curl -s -f -o /dev/null http://localhost:8001; then
    print_success "HTTP endpoint responding"
else
    print_error "HTTP endpoint not responding"
fi

# Database info
if [ -f "$DB_FILE" ]; then
    DB_SIZE=$(du -h "$DB_FILE" | cut -f1)
    echo "Database size: $DB_SIZE"
    
    # Count tables
    TABLE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM sqlite_master WHERE type='table';" 2>/dev/null || echo "0")
    echo "Database tables: $TABLE_COUNT"
fi

print_section "Deployment Summary"
echo ""
echo "✅ Code updated: $LAST_COMMIT"
echo "✅ Database optimized and backed up"
echo "✅ Service: $SERVICE_NAME"
echo "✅ Database: $DB_FILE"
echo "✅ Backups: $BACKUP_DIR"
echo "✅ Logs: $LOG_DIR/saro_*.log"
echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo ""
echo "Useful commands:"
echo "  - View logs: journalctl -u $SERVICE_NAME -f"
echo "  - Restart: systemctl restart $SERVICE_NAME"
echo "  - Status: systemctl status $SERVICE_NAME"
echo "  - Database backup: $APP_DIR/backup_daily.sh"
echo "  - Optimize DB: python3 $APP_DIR/optimize_sqlite.py"
echo ""
echo -e "${BLUE}================================================${NC}"
