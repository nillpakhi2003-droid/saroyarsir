# Online Exam & Resources Issues - Diagnostic & Fix Guide

## Summary of Issues Found

### Issue 1: Alpine.js Not Loaded on Student Dashboard
**Problem:** The student dashboard (`dashboard_student_new.html`) uses Alpine.js directives (`x-data`, `x-init`) but Alpine.js was never included in the page.

**Impact:** 
- Student online exams component never initialized
- Student sees empty page even when exams exist
- No fetch call to `/api/online-exams` happens

**Fix Applied:**
Added Alpine.js CDN to `dashboard_student_new.html`:
```html
<script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
```

---

### Issue 2: Backend Field Name Mismatch  
**Problem:** Backend returns `attempts_count` but student template expected `my_attempts_count`

**Backend Response (routes/online_exams.py):**
```python
exam_dict['attempts_count'] = len(attempts)  # ✅ Correct
exam_dict['best_score'] = max([a.percentage for a in attempts]) if attempts else 0
```

**Student Template (student_online_exams.html) - OLD:**
```html
<div x-show="exam.my_attempts_count > 0">  <!-- ❌ Wrong field name -->
```

**Student Template - FIXED:**
```html
<div x-show="exam.attempts_count > 0">  <!-- ✅ Correct -->
```

**Impact:**
- Attempt summary never showed even when student had attempts
- "Take Again" button logic broken

**Fix Applied:**
Changed `exam.my_attempts_count` to `exam.attempts_count` in student_online_exams.html

---

### Issue 3: Exams Not Published/Active by Default
**Problem:** When teacher creates exam and adds questions, the exam is NOT auto-published. Backend defaults:
```python
is_published=False  # Not published by default
is_active=True      # Active by default
```

**Impact:**
- Teacher creates exam, adds all questions
- Exam saved successfully but `is_published=False`
- Students fetch `/api/online-exams` which filters:
  ```python
  exams = OnlineExam.query.filter_by(is_published=True, is_active=True).all()
  ```
- Result: Student sees 0 exams even though exams exist

**Current Teacher UI:**
The teacher template (`online_exam_management.html`) has auto-publish in `saveAllQuestions()`:
```javascript
// Auto-publish the exam
const publishResponse = await fetch(`/api/online-exams/${this.currentExam.id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ is_published: true })
});
```

**But:** This only works if teacher uses "Save All & Publish" button.

**Fix Options:**

#### Option A: Auto-publish on question save (Already implemented in teacher UI)
The code is there but teacher must click "Save All & Publish"

#### Option B: Manual toggle (Teacher dashboard)
Teacher can click eye icon to publish/unpublish

#### Option C: Auto-publish via script (For existing exams)
Run on VPS:
```bash
python3 publish_ready_exams.py
```

---

## Diagnostic Steps for VPS

### Step 1: Run Full Diagnostic
```bash
cd /var/www/saroyarsir
python3 debug_online_exams_full.py
```

This will show:
- All exams with published/active status
- Questions count per exam
- What students should see
- Quick fix suggestions

### Step 2: Publish Ready Exams
If diagnostic shows exams with all questions but not published:
```bash
python3 publish_ready_exams.py
```

This auto-publishes exams that have all questions saved.

### Step 3: Deploy Latest Frontend
```bash
git pull
systemctl restart saro.service
```

### Step 4: Test Student View
1. Open student login in **Incognito** window
2. Open DevTools Console
3. Click "Online Exam" tab
4. Check console for:
   ```
   🎯 student_online_exams partial init triggered
   📡 Fetching /api/online-exams ...
   📡 Status: 200
   ✅ Published exams for student: N
   ```
5. You should see version badge "v1.2" in top right

### Step 5: Check Server Logs
```bash
journalctl -u saro.service -n 100 | grep online_exams.get_exams
```

Look for:
```
[online_exams.get_exams] user_id=X role=UserRole.STUDENT
[online_exams.get_exams] total_fetched=N for role=UserRole.STUDENT
[online_exams.get_exams] returning count=N
```

---

## Online Resources (Documents) Issue

### Current Status
The student documents partial (`student_documents.html`) should work correctly. It:
- Loads on page init or when section becomes visible
- Fetches from `/api/documents/?include_inactive=true`
- Filters by category tags in description

### Potential Issues

#### Issue A: Documents not loading
**Check:** Console logs when clicking "Online Resources"
```
📄 Documents Module Loading v2.0.1
Loading documents from /api/documents/
Documents response status: 200
Total documents loaded: N
```

#### Issue B: Empty documents list
**Possible causes:**
1. No documents uploaded (teacher must upload via dashboard)
2. API endpoint not returning documents
3. Filtering issue

**Test API directly:**
```bash
curl -b cookies.txt https://YOUR_DOMAIN/api/documents/?include_inactive=true
```

Should return:
```json
{
  "success": true,
  "data": {
    "documents": [...]
  }
}
```

---

## Complete Fix Checklist

### On Local Dev
- [x] Add Alpine.js to student dashboard
- [x] Fix field name: `my_attempts_count` → `attempts_count`  
- [x] Add backend logging to `/api/online-exams`
- [x] Add version badge "v1.2" to student exams UI
- [x] Expose Alpine component globally for reload
- [x] Add reload on tab switch
- [x] Create diagnostic scripts

### On VPS
- [ ] Pull latest code: `git pull`
- [ ] Restart service: `systemctl restart saro.service`
- [ ] Run diagnostic: `python3 debug_online_exams_full.py`
- [ ] Publish exams: `python3 publish_ready_exams.py` (if needed)
- [ ] Test student login in Incognito
- [ ] Verify v1.2 badge visible
- [ ] Check console logs for fetch + exams count
- [ ] Check server logs: `journalctl -u saro.service | grep online_exams`

### Teacher Actions Needed
- [ ] For each exam: Click "Manage Questions" → "Save All & Publish"
- [ ] Or: Click eye icon to toggle publish for existing exams
- [ ] Verify exam shows "Published" badge (green)

---

## Expected Console Output (Working State)

### Student Dashboard Console
```
=== STUDENT DASHBOARD LOADED ===
💾 Storing user data in localStorage: {id: X, role: 'student', ...}
window.studentMonthlyExams available? true
window.loadDocuments available? true
📚 Student Dashboard Script Loading v2.0.1

[User clicks "Online Exam" tab]
🔄 SWITCHING TO SECTION: online-exams
✅ Section visible: online-examsSection
📝 Online Exams Section
  - window.studentOnlineExamsComp exists? true
🎯 student_online_exams partial init triggered
🧪 studentOnlineExams.init() start
📡 Fetching /api/online-exams ...
📡 Status: 200
📡 Response JSON: {success: true, data: [{...}, {...}]}
✅ Published exams for student: 2
🧪 Exams loaded count: 2
```

### Server Logs
```
[online_exams.get_exams] user_id=15 role=UserRole.STUDENT
[online_exams.get_exams] total_fetched=2 for role=UserRole.STUDENT
[online_exams.get_exams] returning count=2
```

---

## Quick Commands Reference

```bash
# Deploy updates
cd /var/www/saroyarsir
git pull
systemctl restart saro.service

# Diagnose exam state
python3 debug_online_exams_full.py

# Auto-publish ready exams
python3 publish_ready_exams.py

# Check logs
journalctl -u saro.service -n 50 --no-pager | grep online_exams

# Test API as student
curl -X GET -H "Cookie: session=..." https://YOUR_DOMAIN/api/online-exams

# Manually publish exam via SQL (if needed)
sqlite3 /var/www/saroyarsir/smartgardenhub.db \
  "UPDATE online_exams SET is_published=1, is_active=1 WHERE id=EXAM_ID;"
```

---

## Root Cause Summary

1. **Frontend initialization failure:** Alpine.js not loaded → component never ran
2. **Field name mismatch:** Backend `attempts_count` vs frontend `my_attempts_count`
3. **Publishing workflow gap:** Exams created but not published → filtered out for students

All three issues combined meant: even if teacher created exams, students saw nothing.

**Fix:** Alpine.js included, field names aligned, auto-publish on "Save All", diagnostic scripts provided.
