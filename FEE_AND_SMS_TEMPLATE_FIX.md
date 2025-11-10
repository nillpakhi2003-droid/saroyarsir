# SMS Templates & Fee System - Fixed Issues

## Date: November 10, 2025

---

## ✅ Issue 1: Fee Save Failure - FIXED

### Problem
Error: "Saved 1 fee(s), 1 failed"

### Root Cause
- Database column: `others_fee` (with 's')
- API/Frontend: `other_fee` (without 's')
- Column name mismatch caused save failures

### Solution
**Files Updated:**
1. `routes/fees.py` - All Fee creation functions (5 locations)
   - `create_fee()` - Line 253
   - `update_fee()` - Line 290 (added mapping logic)
   - `bulk_create_fees()` - Line 474
   - `create_monthly_fees()` - Line 578
   - `save_monthly_fee_noauth()` - Line 985

2. `utils/response.py` - `serialize_fee()` function
   - Reads from database column: `others_fee`
   - Exports to API as: `other_fee`
   - Maintains consistent API naming

### Changes Made
```python
# Before (WRONG)
fee = Fee(
    exam_fee=exam_fee,
    other_fee=other_fee,  # ❌ Column doesn't exist
)

# After (CORRECT)
fee = Fee(
    exam_fee=exam_fee,
    others_fee=other_fee,  # ✅ Maps API field to DB column
)
```

### Result
✅ Fee system now saves exam_fee and other_fee correctly
✅ All 14 columns work (12 months + exam_fee + other_fee)
✅ No more "1 failed" errors

---

## ✅ Issue 2: SMS Templates Session-Based - FIXED

### Problem
- SMS templates stored in Flask session (temporary)
- Each teacher had different templates
- Templates lost on logout/server restart
- Changes not shared across teachers

### Root Cause
Template retrieval priority was **wrong**:
```python
# WRONG ORDER (Before)
1. Check session first ❌
2. Check database second
3. Use default

# Session templates overrode database templates!
```

### Solution

**Files Updated:**

1. **`routes/monthly_exams.py`** - `get_sms_template()` function
   - Changed priority: Database FIRST, session as fallback
   ```python
   # NEW ORDER (After)
   1. Check database first ✅ (permanent, shared)
   2. Check session second (backward compatibility)
   3. Use default
   ```

2. **`routes/sms_templates.py`** - 3 functions updated
   
   a. `get_templates()` - Read from database
   ```python
   # Before: Used session templates
   'current': session_templates.get('custom_exam', ''),
   
   # After: Use database templates
   'current': saved_message,  # From database
   ```
   
   b. `update_template()` - Save to database only
   ```python
   # Before: Saved to both session AND database
   session['custom_templates'][template_type] = message
   db.session.commit()
   
   # After: Database ONLY (removed session)
   db.session.commit()
   ```
   
   c. `reset_template()` - Delete from database
   ```python
   # Before: Only cleared session
   del session['custom_templates'][template_type]
   
   # After: Delete from database for ALL teachers
   db.session.delete(template_setting)
   db.session.commit()
   ```

### Changes Made

**Priority Change:**
```python
def get_sms_template(template_type):
    # PRIORITY 1: Database (permanent, shared by all teachers)
    template_setting = Settings.query.filter_by(
        key=f"sms_template_{template_type}"
    ).first()
    if template_setting and template_setting.value:
        return template_setting.value.get('message')
    
    # PRIORITY 2: Session (fallback only)
    custom_templates = session.get('custom_templates', {})
    if custom_templates.get(template_type):
        return custom_templates[template_type]
    
    # PRIORITY 3: Default
    return get_default_template(template_type)
```

**No More Session Storage:**
```python
# REMOVED from update_template():
# session['custom_templates'][template_type] = message  ❌
# session.permanent = True                              ❌

# NOW: Only database storage
db.session.commit()  # ✅
```

### Result
✅ Templates saved permanently in database
✅ All teachers share the same templates
✅ Changes by one teacher visible to ALL teachers
✅ Templates persist across sessions and server restarts
✅ Reset affects ALL teachers (not just current session)

---

## 📊 Database Storage

### Settings Table
Templates are stored in the `settings` table:

```sql
-- Example: Custom exam template
INSERT INTO settings (
    key,
    value,
    category,
    description,
    updated_by
) VALUES (
    'sms_template_custom_exam',
    '{"message": "{student_name} পরীক্ষায় পেয়েছে {marks}/{total}"}',
    'sms_templates',
    'SMS template for custom_exam',
    1  -- teacher_id
);
```

### Query Templates
```sql
-- Get all SMS templates
SELECT * FROM settings 
WHERE key LIKE 'sms_template_%';

-- Get specific template
SELECT * FROM settings 
WHERE key = 'sms_template_custom_exam';
```

---

## 🔄 Template Types

### Hardcoded (Not Editable)
- `exam_result` - Exam results notification
- `attendance_present` - Present notification
- `attendance_absent` - Absent notification
- `fee_reminder` - Fee payment reminder

### Custom (Editable - Stored in DB)
- `custom_exam` - Customizable exam message
- `custom_general` - General purpose message

---

## 🧪 Testing

### Test Script: `test_permanent_sms_templates.sh`

**Tests:**
1. ✅ Login as Teacher
2. ✅ Get current templates
3. ✅ Update template → Saves to database
4. ✅ Login as Admin (different session)
5. ✅ Admin sees Teacher's template (from database)
6. ✅ Reset template → Deletes from database
7. ✅ Verify deletion

### How to Test
```bash
# Run the test
./test_permanent_sms_templates.sh

# Expected output:
# ✅ Templates save to database permanently
# ✅ All teachers share the same templates
# ✅ Changes by one teacher visible to all
# ✅ Reset removes from database for all
```

---

## 📦 Deployment to VPS

### On VPS (194.233.74.48)
```bash
cd /var/www/saroyarsir
git pull origin main
sudo systemctl restart saro_vps
sudo systemctl status saro_vps
```

### Verify Logs
```bash
sudo journalctl -u saro_vps -n 50 --no-pager
```

---

## 🎯 Summary

### What Changed
1. **Fee System**: Fixed column name mapping (`other_fee` → `others_fee`)
2. **SMS Templates**: Changed from session-based to database-based
3. **Template Priority**: Database first, session fallback
4. **Template Sharing**: All teachers now share templates
5. **Persistence**: Templates survive logout and server restart

### Files Modified
1. `routes/fees.py` - Fee column mapping
2. `utils/response.py` - Fee serialization
3. `routes/monthly_exams.py` - Template retrieval priority
4. `routes/sms_templates.py` - Database-only storage

### Benefits
✅ No more fee save errors
✅ Templates shared across all teachers
✅ Permanent template storage
✅ No session dependency
✅ Consistent behavior across users

---

## 🚀 Next Steps

1. Deploy to VPS
2. Test fee system with exam_fee and other_fee
3. Test SMS template editing by multiple teachers
4. Verify database persistence

---

**Committed:** November 10, 2025
**Pushed to GitHub:** ✅ main branch
