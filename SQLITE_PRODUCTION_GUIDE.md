# SQLite Production - Complete Deployment Guide

## 🚀 Quick Deploy (Most Common Use)

For regular code updates:

```bash
cd /var/www/saroyarsir
sudo ./quick_deploy.sh
```

⏱️ Takes ~10 seconds

## 🔧 Full Production Deployment

For initial setup or major updates with database optimization:

```bash
cd /var/www/saroyarsir
sudo chmod +x deploy_sqlite_production.sh
sudo ./deploy_sqlite_production.sh
```

⏱️ Takes ~2-3 minutes

### What It Does:

1. ✅ **Stop Service** - Gracefully stops the application
2. ✅ **Backup Database** - Creates timestamped backup (keeps last 10)
3. ✅ **Pull Latest Code** - Updates from Git repository
4. ✅ **Setup Virtual Environment** - Creates/updates Python venv
5. ✅ **Install Dependencies** - Installs from requirements.txt
6. ✅ **Configure SQLite** - Production optimizations applied
7. ✅ **Optimize Database** - WAL mode, cache, vacuum, analyze
8. ✅ **Set Permissions** - Correct ownership and file permissions
9. ✅ **Configure Service** - Systemd service with Gunicorn
10. ✅ **Setup Backups** - Daily automated backups (2 AM)
11. ✅ **Configure Nginx** - Reverse proxy setup (if installed)
12. ✅ **Start & Verify** - Starts service and runs health checks

## 📦 Database Migration

When you add new tables/columns to models:

```bash
cd /var/www/saroyarsir
sudo python3 migrate_db.py
```

This will:
- Create backup before migration
- Update schema using SQLAlchemy
- Verify tables created successfully

## 🔍 Service Management

```bash
# Start
sudo systemctl start saro.service

# Stop
sudo systemctl stop saro.service

# Restart
sudo systemctl restart saro.service

# Status
sudo systemctl status saro.service

# Enable on boot
sudo systemctl enable saro.service

# View live logs
sudo journalctl -u saro.service -f

# View last 50 lines
sudo journalctl -u saro.service -n 50
```

## 💾 Database Operations

### Optimize Database
```bash
sudo python3 /var/www/saroyarsir/optimize_sqlite.py
```

Applies:
- WAL mode (better concurrency)
- NORMAL synchronous mode
- 10MB cache size
- 256MB memory-mapped I/O
- VACUUM (reclaim space)
- ANALYZE (update statistics)

### Manual Backup
```bash
sudo /var/www/saroyarsir/backup_daily.sh
```

### Access Database CLI
```bash
sqlite3 /var/www/saroyarsir/smartgardenhub.db
```

Common queries:
```sql
-- List all tables
.tables

-- Check table structure
.schema users

-- Count records
SELECT COUNT(*) FROM users;

-- Check database size
SELECT page_count * page_size / 1024.0 / 1024.0 as size_mb 
FROM pragma_page_count(), pragma_page_size();

-- Exit
.quit
```

### Database Integrity Check
```bash
sqlite3 /var/www/saroyarsir/smartgardenhub.db "PRAGMA integrity_check;"
```

## 🏥 Health Checks

### Automated Health Check
```bash
sudo /var/www/saroyarsir/health_check.sh
```

Checks:
- Service is running
- HTTP endpoint responds
- Auto-restarts if needed

### Manual Checks
```bash
# Is service active?
systemctl is-active saro.service

# HTTP response
curl -I http://localhost:8001

# Check port
sudo netstat -tlnp | grep 8001

# Check processes
ps aux | grep gunicorn
```

## 📊 Monitoring & Logs

### Application Logs
```bash
# Access log
tail -f /var/log/saro_access.log

# Error log
tail -f /var/log/saro_error.log

# Combined
sudo journalctl -u saro.service -f
```

### Database Size
```bash
du -h /var/www/saroyarsir/smartgardenhub.db
```

### Table Count
```bash
sqlite3 /var/www/saroyarsir/smartgardenhub.db \
  "SELECT COUNT(*) FROM sqlite_master WHERE type='table';"
```

### Disk Space
```bash
df -h /var/www/saroyarsir
```

## 🔐 Security & Permissions

### Fix Permissions
```bash
cd /var/www/saroyarsir
sudo chown -R www-data:www-data .
sudo chmod 664 smartgardenhub.db
sudo chmod 775 .
sudo find . -type f -exec chmod 644 {} \;
sudo find . -type d -exec chmod 755 {} \;
sudo chmod +x *.sh *.py
```

### Check Current Permissions
```bash
ls -la /var/www/saroyarsir/smartgardenhub.db
```

Should show:
```
-rw-rw-r-- 1 www-data www-data ... smartgardenhub.db
```

## 🔄 Backup & Restore

### Automated Backups
- **Schedule**: Daily at 2:00 AM
- **Location**: `/var/www/saroyarsir/backups/daily/`
- **Retention**: 30 days
- **Compression**: Files older than 1 day

### Manual Backup
```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp /var/www/saroyarsir/smartgardenhub.db \
   /var/www/saroyarsir/backups/manual_backup_${TIMESTAMP}.db
```

### Restore from Backup
```bash
# 1. Stop service
sudo systemctl stop saro.service

# 2. Backup current database
sudo cp /var/www/saroyarsir/smartgardenhub.db \
        /var/www/saroyarsir/smartgardenhub.db.before_restore

# 3. Restore from backup
BACKUP_FILE="/var/www/saroyarsir/backups/daily/backup_20251113_020000.db"
sudo cp $BACKUP_FILE /var/www/saroyarsir/smartgardenhub.db

# 4. Fix permissions
sudo chown www-data:www-data /var/www/saroyarsir/smartgardenhub.db
sudo chmod 664 /var/www/saroyarsir/smartgardenhub.db

# 5. Start service
sudo systemctl start saro.service
```

### List Available Backups
```bash
ls -lth /var/www/saroyarsir/backups/daily/ | head -20
```

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check detailed logs
sudo journalctl -u saro.service -n 100 --no-pager

# Check if port is in use
sudo lsof -i :8001

# Kill processes on port (if needed)
sudo kill $(sudo lsof -t -i:8001)

# Try starting manually
cd /var/www/saroyarsir
source venv/bin/activate
python3 app.py
```

### Database Locked Error

```bash
# Check for open connections
sudo lsof /var/www/saroyarsir/smartgardenhub.db

# Restart service
sudo systemctl restart saro.service

# If still locked, check for zombie processes
ps aux | grep python | grep saroyarsir
sudo kill -9 <PID>
```

### Import Errors

```bash
# Reinstall dependencies
cd /var/www/saroyarsir
source venv/bin/activate
pip install --upgrade -r requirements.txt
```

### Permission Denied

```bash
# Fix all permissions
cd /var/www/saroyarsir
sudo chown -R www-data:www-data .
sudo chmod 664 smartgardenhub.db
sudo chmod 775 .
```

### High Memory Usage

```bash
# Check current usage
ps aux | grep gunicorn | awk '{sum+=$4} END {print sum "%"}'

# Restart to clear memory
sudo systemctl restart saro.service
```

### Nginx 502 Bad Gateway

```bash
# Check if service is running
systemctl status saro.service

# Check logs
sudo tail -f /var/log/nginx/error.log

# Test backend
curl http://localhost:8001

# Restart both
sudo systemctl restart saro.service
sudo systemctl restart nginx
```

## 🔄 Rollback Procedure

If deployment causes issues:

```bash
# 1. Stop service
sudo systemctl stop saro.service

# 2. List recent commits
cd /var/www/saroyarsir
git log --oneline -10

# 3. Rollback code
git reset --hard <previous-commit-hash>

# 4. Restore database (if needed)
LATEST_BACKUP=$(ls -t /var/www/saroyarsir/backups/*.db | head -1)
sudo cp $LATEST_BACKUP /var/www/saroyarsir/smartgardenhub.db
sudo chown www-data:www-data /var/www/saroyarsir/smartgardenhub.db

# 5. Restart service
sudo systemctl start saro.service

# 6. Verify
sudo systemctl status saro.service
curl http://localhost:8001
```

## 📁 File Locations

| Item | Path |
|------|------|
| Application Root | `/var/www/saroyarsir/` |
| Database File | `/var/www/saroyarsir/smartgardenhub.db` |
| Virtual Environment | `/var/www/saroyarsir/venv/` |
| Backups | `/var/www/saroyarsir/backups/` |
| Daily Backups | `/var/www/saroyarsir/backups/daily/` |
| Access Logs | `/var/log/saro_access.log` |
| Error Logs | `/var/log/saro_error.log` |
| Service File | `/etc/systemd/system/saro.service` |
| Nginx Config | `/etc/nginx/sites-available/saroyarsir` |

## 📋 Maintenance Schedule

### Daily (Automated)
- ✅ Database backup at 2:00 AM
- ✅ Log rotation

### Weekly
```bash
# Check disk space
df -h

# Optimize database
sudo python3 /var/www/saroyarsir/optimize_sqlite.py

# Review error logs
sudo journalctl -u saro.service --since "1 week ago" | grep -i error
```

### Monthly
```bash
# Update system
sudo apt update && sudo apt upgrade

# Check backup integrity
ls -lh /var/www/saroyarsir/backups/daily/

# Clean old logs
sudo journalctl --vacuum-time=30d
```

## 🚀 Initial Setup (First Time)

```bash
# 1. Install system dependencies
sudo apt update
sudo apt install -y python3 python3-pip python3-venv \
                    git nginx sqlite3 curl

# 2. Create app directory
sudo mkdir -p /var/www/saroyarsir
sudo chown $USER:$USER /var/www/saroyarsir

# 3. Clone repository
cd /var/www
git clone https://github.com/sa5613675-jpg/saroyarsir.git
cd saroyarsir

# 4. Make scripts executable
chmod +x *.sh *.py

# 5. Run full deployment
sudo ./deploy_sqlite_production.sh

# 6. Configure domain (if using nginx)
sudo nano /etc/nginx/sites-available/saroyarsir
# Change: server_name your_domain.com

# 7. Test nginx config
sudo nginx -t

# 8. Reload nginx
sudo systemctl reload nginx

# 9. Setup SSL (optional)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your_domain.com

# 10. Verify deployment
curl http://localhost:8001
systemctl status saro.service
```

## 📞 Support Commands

```bash
# Quick status check
sudo systemctl status saro.service

# Full diagnostic
cd /var/www/saroyarsir
sudo python3 check_student_batches.py
sudo python3 optimize_sqlite.py
sudo ./health_check.sh

# View all logs
sudo journalctl -u saro.service -n 200 --no-pager

# Check configuration
cat /etc/systemd/system/saro.service

# Test endpoint
curl -v http://localhost:8001
```

## ⚡ Performance Tips

1. **Regular Optimization**: Run `optimize_sqlite.py` weekly
2. **Monitor Size**: Keep database under 1GB for best performance
3. **Archive Old Data**: Move historical data to separate database
4. **Use Indexes**: Ensure frequently queried columns have indexes
5. **Connection Pooling**: Gunicorn handles this automatically
6. **WAL Mode**: Already enabled for better concurrency
7. **Cache Size**: Set to 10MB for faster queries

## 🎯 Production Checklist

- [x] Database in WAL mode
- [x] Automated daily backups
- [x] Service auto-restart on failure
- [x] Correct file permissions
- [x] Gunicorn with multiple workers
- [x] Nginx reverse proxy
- [x] Error logging configured
- [x] Health checks enabled
- [x] SSL certificate (optional)
- [x] Firewall configured

## 📚 Additional Resources

- SQLite Documentation: https://www.sqlite.org/docs.html
- Gunicorn Settings: https://docs.gunicorn.org/en/stable/settings.html
- Systemd Service: `man systemd.service`
- Flask Production: https://flask.palletsprojects.com/en/latest/deploying/
