# Deploy Fixes to VPS

## Fixes Included in This Update

### 1. ✅ Monthly Exam Delete Fix
- Changed `MonthlyExam.query.get()` to `db.session.get()` (proper SQLAlchemy 2.0 syntax)
- Added `current_app` import for logging
- Fixed permission check to use `get_current_user()`
- Delete now works correctly and removes:
  - Monthly exam record
  - All individual exams (cascade)
  - All rankings (cascade)
  - **Note:** Cannot delete if marks exist (must delete marks first)

### 2. ✅ Archived Students Filter
- Archived students are now properly excluded from:
  - Monthly exam rankings display
  - Attendance sheets (already working)
  - All student lists
- Old ranking data from archived students will not appear anymore

## Deployment Steps on VPS

### Step 1: Pull Latest Code
```bash
cd /var/www/saroyarsir
git pull origin main
```

Expected output:
```
Updating afb5234..69bfd11
Fast-forward
 routes/monthly_exams.py | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)
```

### Step 2: Restart the Application

If you already have the service running:
```bash
sudo systemctl restart smartgardenhub
sudo systemctl status smartgardenhub
```

If the service doesn't exist yet, run the setup script:
```bash
cd /var/www/saroyarsir
chmod +x vps_quick_fix.sh
sudo ./vps_quick_fix.sh
```

### Step 3: Verify the Fixes

#### Test Delete Monthly Exam:
1. Open browser: `http://YOUR_VPS_IP:8001`
2. Login as teacher (01711111111 / teacher123)
3. Go to "Monthly Exams" → "Monthly Periods" tab
4. Find a monthly exam that has **NO MARKS** entered
5. Click the red trash button 🗑️
6. Confirm deletion
7. Should see: "Monthly exam period deleted successfully!"

**Note:** If the exam has marks, you'll see:
"Cannot delete exam period. Marks have been entered. Please delete all marks first."

#### Test Archived Students Filter:
1. Go to "Archive" section
2. Note which students are archived
3. Go to "Attendance" - archived students should NOT appear
4. Go to "Monthly Exams" → Check rankings - archived students should NOT appear

### Step 4: Clear Browser Cache (Important!)

On the VPS browser, press:
- **Chrome/Edge:** `Ctrl + Shift + Delete` → Clear "Cached images and files"
- **Firefox:** `Ctrl + Shift + Delete` → Clear "Cache"

Or do a hard refresh: `Ctrl + F5`

## Troubleshooting

### If delete still shows "Not found":
1. Check the exam still exists:
   ```bash
   python3 -c "from app import create_app, db; from models import MonthlyExam; app = create_app(); 
   with app.app_context(): 
       exam = db.session.get(MonthlyExam, 1); 
       print('Exam exists:' if exam else 'Exam not found')"
   ```

2. Check service logs:
   ```bash
   sudo journalctl -u smartgardenhub -n 50 -f
   ```

### If archived students still visible:
1. Verify which students are archived:
   ```bash
   python3 -c "from app import create_app; from models import User, UserRole; app = create_app();
   with app.app_context():
       archived = User.query.filter_by(role=UserRole.STUDENT, is_archived=True).all();
       print('Archived students:');
       for s in archived: print(f'  - {s.full_name} (ID: {s.id})')"
   ```

2. Clear browser cache completely
3. Restart the service: `sudo systemctl restart smartgardenhub`

### Check Application Logs:
```bash
# Service logs
sudo journalctl -u smartgardenhub -f

# Application error logs
tail -f /var/www/saroyarsir/logs/error.log

# Application access logs
tail -f /var/www/saroyarsir/logs/access.log
```

### If service won't start:
```bash
# Check status
sudo systemctl status smartgardenhub

# View detailed logs
sudo journalctl -u smartgardenhub -xe

# Test manually
cd /var/www/saroyarsir
source venv/bin/activate
python app.py
# Press Ctrl+C to stop, then use systemctl to start properly
```

## What Changed

### File: `routes/monthly_exams.py`

**Line 1542:** Changed from:
```python
monthly_exam = MonthlyExam.query.get(exam_id)
```
To:
```python
monthly_exam = db.session.get(MonthlyExam, exam_id)
```

**Lines 471-473:** Added filter to exclude archived students:
```python
# Filter out archived students from rankings before returning
active_student_ids = [s.id for s in batch_students]
rankings = [r for r in rankings if r['user_id'] in active_student_ids]
```

## Verification Checklist

After deployment, verify:
- [ ] Service is running: `sudo systemctl status smartgardenhub`
- [ ] App accessible at: http://YOUR_VPS_IP:8001
- [ ] Can login as teacher
- [ ] Delete button visible on monthly exams
- [ ] Delete works for exams without marks
- [ ] Delete blocked for exams with marks (proper error message)
- [ ] Archived students don't appear in attendance
- [ ] Archived students don't appear in rankings
- [ ] Error messages are clear and helpful

## Support

If you encounter any issues:
1. Check the logs (commands above)
2. Verify the code was pulled correctly: `git log -1`
3. Ensure service restarted: `sudo systemctl restart smartgardenhub`
4. Clear browser cache completely

Current commit: **69bfd11**
Previous commit: **afb5234**
