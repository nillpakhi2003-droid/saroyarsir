# VPS Production Configuration - SQLite + Port 8001

## 🎯 Overview
Your application is now configured to use:
- **Database**: SQLite (Production & Development)
- **Port**: 8001
- **Service**: systemd (saro.service)

## 📋 Files Modified

### 1. config.py
- ✅ ProductionConfig now uses SQLite instead of MySQL
- Database file: `smartgardenhub_production.db`
- Located in application root directory

### 2. gunicorn.conf.py
- ✅ Default port changed from 5000 to 8001
- Can be overridden with PORT environment variable

### 3. saro_vps.service (NEW)
- ✅ Systemd service file for VPS deployment
- Configured for port 8001 and production environment
- Copy to `/etc/systemd/system/saro.service` on VPS

### 4. deploy_vps_sqlite.sh (NEW)
- ✅ Complete automated deployment script
- Handles all setup steps automatically

## 🚀 Deployment Instructions

### Option 1: Automated Deployment (Recommended)

1. **Push changes to GitHub:**
   ```bash
   git add .
   git commit -m "Configure for SQLite production + port 8001"
   git push origin main
   ```

2. **On your VPS, run:**
   ```bash
   cd /var/www/saroyarsir
   sudo bash deploy_vps_sqlite.sh
   ```

### Option 2: Manual Deployment

1. **Connect to VPS:**
   ```bash
   ssh your_user@gsteaching.com
   ```

2. **Navigate to app directory:**
   ```bash
   cd /var/www/saroyarsir
   ```

3. **Pull latest code:**
   ```bash
   git pull origin main
   ```

4. **Copy service file:**
   ```bash
   sudo cp saro_vps.service /etc/systemd/system/saro.service
   ```

5. **Reload systemd and restart service:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable saro
   sudo systemctl restart saro
   ```

6. **Configure firewall (if needed):**
   ```bash
   sudo ufw allow 8001/tcp
   ```

7. **Check status:**
   ```bash
   sudo systemctl status saro
   ```

## 🔍 Verification Steps

1. **Check service status:**
   ```bash
   sudo systemctl status saro
   ```

2. **Check if port 8001 is listening:**
   ```bash
   sudo netstat -tlnp | grep 8001
   # OR
   sudo ss -tlnp | grep 8001
   ```

3. **Test the application:**
   ```bash
   curl http://localhost:8001/health
   ```

4. **View logs:**
   ```bash
   sudo journalctl -u saro -f
   ```

## 📝 Useful Commands

### Service Management
```bash
# Start service
sudo systemctl start saro

# Stop service
sudo systemctl stop saro

# Restart service
sudo systemctl restart saro

# Check status
sudo systemctl status saro

# Enable auto-start on boot
sudo systemctl enable saro

# Disable auto-start
sudo systemctl disable saro
```

### Log Viewing
```bash
# Live logs
sudo journalctl -u saro -f

# Last 100 lines
sudo journalctl -u saro -n 100

# Logs since today
sudo journalctl -u saro --since today

# Logs from specific time
sudo journalctl -u saro --since "2025-11-10 10:00:00"
```

### Database Management
```bash
# Backup SQLite database
cp smartgardenhub_production.db smartgardenhub_production_backup_$(date +%Y%m%d).db

# Check database size
ls -lh smartgardenhub_production.db

# Access database with sqlite3
sqlite3 smartgardenhub_production.db
```

### Process Monitoring
```bash
# Check running processes
ps aux | grep gunicorn

# Check port usage
sudo netstat -tlnp | grep 8001

# Check application process
top -p $(pgrep -f gunicorn)
```

## 🌐 Access URLs

- **Local (on VPS)**: http://localhost:8001
- **Public**: http://YOUR_SERVER_IP:8001
- **Domain**: http://gsteaching.com:8001 (if DNS configured)

## 🔒 Security Recommendations

1. **Update SECRET_KEY** in `/var/www/saroyarsir/.env`:
   ```bash
   nano /var/www/saroyarsir/.env
   # Change SECRET_KEY to a random string
   ```

2. **Set up regular backups** for SQLite database:
   ```bash
   # Add to crontab
   crontab -e
   # Add: 0 2 * * * cp /var/www/saroyarsir/smartgardenhub_production.db /backup/smartgardenhub_$(date +\%Y\%m\%d).db
   ```

3. **Set up Nginx reverse proxy** for HTTPS (optional):
   ```nginx
   server {
       listen 80;
       server_name gsteaching.com;
       
       location / {
           proxy_pass http://localhost:8001;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

## 🐛 Troubleshooting

### Service won't start
```bash
# Check detailed logs
sudo journalctl -u saro -n 100 --no-pager

# Check if port is already in use
sudo netstat -tlnp | grep 8001

# Verify service file syntax
sudo systemd-analyze verify /etc/systemd/system/saro.service
```

### Database issues
```bash
# Check database file permissions
ls -la smartgardenhub_production.db

# Set correct permissions
sudo chown www-data:www-data smartgardenhub_production.db
sudo chmod 664 smartgardenhub_production.db
```

### Port access issues
```bash
# Check firewall status
sudo ufw status

# Allow port 8001
sudo ufw allow 8001/tcp

# Check if service is binding to correct port
sudo netstat -tlnp | grep gunicorn
```

## 📦 Environment Variables

The application uses these environment variables (set in .env or service file):

- `FLASK_ENV=production` - Sets production mode
- `PORT=8001` - Application port
- `SECRET_KEY=...` - Flask secret key for sessions

## ✅ Quick Health Check

Run this one-liner to verify everything:
```bash
sudo systemctl status saro && curl -s http://localhost:8001/health && echo -e "\n✅ All systems operational!"
```

## 📞 Support

If you encounter issues:
1. Check the logs: `sudo journalctl -u saro -n 100`
2. Verify database exists: `ls -la smartgardenhub_production.db`
3. Check service status: `sudo systemctl status saro`
4. Verify port is open: `sudo netstat -tlnp | grep 8001`
