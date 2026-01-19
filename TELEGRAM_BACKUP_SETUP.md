# Telegram Backup Setup Guide

## Overview
Automated daily database backup system that sends backups to Telegram at 2 AM.

## Features
- ✅ Daily automatic backups at 2 AM
- ✅ Sends backup to Telegram
- ✅ Compresses backups (gzip)
- ✅ Database statistics in message
- ✅ Auto-cleanup of old backups (7 days)
- ✅ Error notifications via Telegram
- ✅ Detailed logging

## Setup Instructions

### Step 1: Create Telegram Bot

1. **Open Telegram** and search for `@BotFather`
2. **Send** `/newbot` command
3. **Follow prompts** to create your bot:
   - Choose a name (e.g., "Database Backup Bot")
   - Choose a username (e.g., "saroyarsir_backup_bot")
4. **Save the token** - You'll get something like: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`

### Step 2: Get Your Chat ID

**Option A: Using Your Personal Chat**
1. Send a message to your bot
2. Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
3. Look for `"chat":{"id":123456789}` - that's your chat ID

**Option B: Using a Channel/Group**
1. Create a Telegram channel/group
2. Add your bot as administrator
3. Send a message in the channel
4. Visit the getUpdates URL above
5. Find the chat ID (will be negative for groups/channels)

### Step 3: Configure Environment Variables

Edit your environment file or add to `/etc/environment`:

```bash
# Add to /var/www/saroyarsir/.env or set system-wide
export TELEGRAM_BOT_TOKEN="123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
export TELEGRAM_CHAT_ID="123456789"
```

Or edit the cron script directly:
```bash
nano /var/www/saroyarsir/telegram_backup_cron.sh
```

Add after the "Telegram Configuration" comment:
```bash
export TELEGRAM_BOT_TOKEN="your_actual_token_here"
export TELEGRAM_CHAT_ID="your_actual_chat_id_here"
```

### Step 4: Make Scripts Executable

```bash
chmod +x /var/www/saroyarsir/telegram_backup.py
chmod +x /var/www/saroyarsir/telegram_backup_cron.sh
```

### Step 5: Install Required Python Package

```bash
cd /var/www/saroyarsir
source venv/bin/activate
pip install requests
```

### Step 6: Test the Backup

Run manually to test:
```bash
cd /var/www/saroyarsir
python3 telegram_backup.py
```

You should see output and receive a backup file in Telegram!

### Step 7: Setup Cron Job

Edit crontab:
```bash
crontab -e
```

Add this line for daily backup at 2 AM:
```
0 2 * * * /var/www/saroyarsir/telegram_backup_cron.sh
```

Or for testing (every 5 minutes):
```
*/5 * * * * /var/www/saroyarsir/telegram_backup_cron.sh
```

Save and exit.

### Step 8: Verify Cron Setup

Check if cron job is added:
```bash
crontab -l
```

Check cron logs:
```bash
tail -f /var/www/saroyarsir/logs/telegram_backup.log
```

## Configuration Options

Edit `telegram_backup.py` to customize:

```python
# Backup Settings
KEEP_BACKUPS_DAYS = 7      # Keep local backups for 7 days
COMPRESS_BACKUP = True      # Compress with gzip (recommended)
```

## File Locations

```
/var/www/saroyarsir/
├── telegram_backup.py          # Main backup script
├── telegram_backup_cron.sh     # Cron wrapper script
├── backups/                    # Local backup storage
│   ├── backup_20260119_020000.db.gz
│   └── backup_20260120_020000.db.gz
└── logs/
    └── telegram_backup.log     # Backup logs
```

## Telegram Message Format

You'll receive:
```
🔄 **Database Backup**
📅 Date: 2026-01-19 02:00:00
💾 Size: 2.45 MB
📊 Database: smartgardenhub.db

**Records:**
• users: 150
• batches: 12
• attendance: 3,450
• fees: 1,800
• exams: 45

✅ Backup completed successfully
```

## Troubleshooting

### Backup not sent to Telegram
Check:
```bash
# Test Telegram connectivity
curl "https://api.telegram.org/bot<YOUR_TOKEN>/getMe"

# Check environment variables
env | grep TELEGRAM

# View logs
tail -100 /var/www/saroyarsir/logs/telegram_backup.log
```

### File too large (>50MB)
- Database has grown beyond Telegram's 50MB limit
- Options:
  1. Compress more aggressively
  2. Use Telegram API with chunked upload
  3. Upload to cloud storage and send link

### Cron not running
```bash
# Check cron service
sudo systemctl status cron

# Check system logs
grep CRON /var/log/syslog

# Test cron script manually
/var/www/saroyarsir/telegram_backup_cron.sh
```

### Permissions errors
```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/saroyarsir/backups
sudo chown -R www-data:www-data /var/www/saroyarsir/logs

# Fix permissions
chmod 755 /var/www/saroyarsir/backups
chmod 755 /var/www/saroyarsir/logs
```

## Backup Retention

- **Telegram**: Keep backups in Telegram forever (or manage manually)
- **Local**: Automatically deleted after 7 days (configurable)

## Security Notes

⚠️ **Important:**
1. Keep your bot token secret
2. Don't commit tokens to git
3. Restrict Telegram bot/channel access
4. Backups contain sensitive data - secure your Telegram account with 2FA

## Advanced: Multiple Destinations

To send to multiple chats/channels, modify the script to loop through chat IDs:

```python
TELEGRAM_CHAT_IDS = ['123456789', '-100123456789']  # Personal + Channel

for chat_id in TELEGRAM_CHAT_IDS:
    send_to_telegram(backup_path, chat_id)
```

## Restore from Backup

To restore a backup:

```bash
# Stop the application
sudo systemctl stop saroyarsir

# Restore from backup
gunzip -c backup_20260119_020000.db.gz > /var/www/saroyarsir/smartgardenhub.db

# Start the application
sudo systemctl start saroyarsir
```

## Monitoring

Set up monitoring alerts for:
- ❌ Backup failures (check logs daily)
- 📊 Database size growth
- 💾 Disk space on backup directory

## Cron Schedule Examples

```bash
# Daily at 2 AM
0 2 * * * /var/www/saroyarsir/telegram_backup_cron.sh

# Twice daily (2 AM and 2 PM)
0 2,14 * * * /var/www/saroyarsir/telegram_backup_cron.sh

# Every 6 hours
0 */6 * * * /var/www/saroyarsir/telegram_backup_cron.sh

# Weekly on Sunday at 3 AM
0 3 * * 0 /var/www/saroyarsir/telegram_backup_cron.sh
```

## Support

For issues:
1. Check logs: `/var/www/saroyarsir/logs/telegram_backup.log`
2. Test manually: `python3 telegram_backup.py`
3. Verify Telegram token and chat ID
4. Check disk space: `df -h`
