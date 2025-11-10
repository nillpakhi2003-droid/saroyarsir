#!/bin/bash
cd /var/www/saroyarsir
export FLASK_ENV=production
export DATABASE_PATH=/var/www/saroyarsir/smartgardenhub.db
/var/www/saroyarsir/venv/bin/python3 backup_database.py >> logs/backup_cron.log 2>&1
