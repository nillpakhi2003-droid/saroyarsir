#!/bin/bash

# VPS Deployment Script for SQLite Production
# Run this on your VPS server

echo "🚀 Starting VPS Deployment..."
echo "================================"

# Stop the service
echo "⏸️  Stopping service..."
sudo systemctl stop saro_vps

# Pull latest code
echo "📥 Pulling latest code from GitHub..."
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
pip3 install -r requirements.txt

# Set environment variables
export FLASK_ENV=production
export DATABASE_URL=sqlite:////root/saroyarsir/smartgardenhub_production.db

# Check if database exists
if [ ! -f "/root/saroyarsir/smartgardenhub_production.db" ]; then
    echo "🗄️  Creating production database..."
    python3 << 'EOF'
from app import create_app
from models import db

app = create_app('production')
with app.app_context():
    db.create_all()
    print("✅ Production database tables created!")
EOF

    # Create default accounts
    echo "👤 Creating default accounts..."
    python3 << 'EOF'
from app import create_app
from models import db, User, UserRole
from flask_bcrypt import Bcrypt

app = create_app('production')
bcrypt = Bcrypt(app)

with app.app_context():
    admin = User.query.filter_by(phoneNumber='01700000000').first()
    if not admin:
        admin = User(
            first_name='Admin',
            last_name='User',
            phoneNumber='01700000000',
            role=UserRole.SUPER_USER,
            is_active=True,
            email='admin@gsteaching.com'
        )
        admin.password_hash = bcrypt.generate_password_hash('admin123').decode('utf-8')
        db.session.add(admin)
    
    teacher = User.query.filter_by(phoneNumber='01800000000').first()
    if not teacher:
        teacher = User(
            first_name='Teacher',
            last_name='One',
            phoneNumber='01800000000',
            role=UserRole.TEACHER,
            is_active=True,
            email='teacher@gsteaching.com'
        )
        teacher.password_hash = bcrypt.generate_password_hash('teacher123').decode('utf-8')
        db.session.add(teacher)
    
    db.session.commit()
    print("✅ Default accounts created!")
    print("   Admin: 01700000000 / admin123")
    print("   Teacher: 01800000000 / teacher123")
EOF
else
    echo "✅ Database already exists, skipping creation..."
fi

# Set database permissions
echo "🔒 Setting database permissions..."
chmod 644 /root/saroyarsir/smartgardenhub_production.db
chown root:root /root/saroyarsir/smartgardenhub_production.db

# Copy service file
echo "📋 Copying service file..."
sudo cp saro_vps.service /etc/systemd/system/

# Reload systemd
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reload

# Start service
echo "▶️  Starting service..."
sudo systemctl start saro_vps

# Enable on boot
echo "🔁 Enabling service on boot..."
sudo systemctl enable saro_vps

# Wait a moment
sleep 2

# Check status
echo ""
echo "================================"
echo "📊 Service Status:"
sudo systemctl status saro_vps --no-pager

echo ""
echo "================================"
echo "✅ Deployment Complete!"
echo ""
echo "🌐 Access your app at: http://$(hostname -I | awk '{print $1}'):8001"
echo ""
echo "🔐 Default Login:"
echo "   Admin: 01700000000 / admin123"
echo "   Teacher: 01800000000 / teacher123"
echo ""
echo "📝 View logs: sudo journalctl -u saro_vps -f"
echo "================================"
