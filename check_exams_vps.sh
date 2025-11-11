#!/bin/bash
# Check online exams on VPS
cd /var/www/saroyarsir
source venv/bin/activate
python3 check_online_exams.py
