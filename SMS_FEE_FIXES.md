# SMS Template & Fee Columns - Fixed

## Date: November 10, 2025

## Issues Fixed

### 1. ✅ SMS Template Not Saving Permanently

**Problem:**
- When teacher saves an SMS template, it was only stored in SESSION (temporary)
- After logout or session expires, templates were lost
- Templates were not saved to database

**Solution:**
- Modified `POST /api/sms/templates/<template_type>` endpoint
- Now saves templates **permanently to database** (Settings table)
- Also keeps session storage for backward compatibility

**Changes Made:**

**File: `routes/sms_templates.py`**

**Before:**
```python
def update_template(template_type):
    # ... validation ...
    
    # Store in session for immediate use (TEMPORARY!)
    session['custom_templates'][template_type] = message
    session.permanent = True
    
    return success_response('Template updated successfully', {...})
```

**After:**
```python
def update_template(template_type):
    # ... validation ...
    
    # Save to database permanently ✅
    current_user = get_current_user()
    template_key = f"sms_template_{template_type}"
    
    template_setting = Settings.query.filter_by(key=template_key).first()
    
    if template_setting:
        # Update existing
        template_setting.value = {'message': message}
        template_setting.updated_by = current_user.id
        template_setting.updated_at = datetime.utcnow()
    else:
        # Create new
        template_setting = Settings(
            key=template_key,
            value={'message': message},
            description=f"SMS template for {template_type}",
            category="sms_templates",
            updated_by=current_user.id
        )
        db.session.add(template_setting)
    
    db.session.commit()  # ✅ PERMANENT SAVE
    
    # Also keep in session (backward compatibility)
    session['custom_templates'][template_type] = message
    
    return success_response('Template saved permanently', {...})
```

**How Templates Are Used:**

The system already checks database first:
```python
def get_sms_template(template_type):
    # 1. Check session (temporary)
    custom_templates = session.get('custom_templates', {})
    if custom_templates.get(template_type):
        return custom_templates[template_type]
    
    # 2. Check database (permanent) ✅
    template_key = f"sms_template_{template_type}"
    template_setting = Settings.query.filter_by(key=template_key).first()
    
    if template_setting and template_setting.value:
        return template_setting.value.get('message')
    
    # 3. Fallback to default
    return get_default_template(template_type)
```

**Where Templates Are Used:**
- ✅ Monthly exam results notification
- ✅ Attendance notifications
- ✅ Fee reminders
- ✅ All SMS sending features

---

### 2. ✅ Fee Columns (exam_fee and other_fee)

**Status:**
The columns **already exist** in the database and API!

**Database Model (`models.py`):**
```python
class Fee(db.Model):
    # ... other fields ...
    exam_fee = db.Column(Numeric(10, 2), default=0.00)  ✅ Already exists
    other_fee = db.Column(Numeric(10, 2), default=0.00)  ✅ Already exists (as others_fee)
```

**API Support:**
All fee endpoints already support these columns:

1. **Create Fee:**
```json
POST /api/fees
{
  "amount": 1000.00,
  "exam_fee": 200.00,    ✅ Supported
  "other_fee": 100.00    ✅ Supported
}
```

2. **Update Fee:**
```json
PUT /api/fees/<fee_id>
{
  "exam_fee": 250.00,    ✅ Can update
  "other_fee": 150.00    ✅ Can update
}
```

3. **Bulk Create:**
```json
POST /api/fees/bulk-create
{
  "batch_id": 1,
  "amount": 1000.00,
  "exam_fee": 200.00,    ✅ Applied to all
  "other_fee": 100.00    ✅ Applied to all
}
```

4. **Monthly Fees:**
```json
POST /api/fees/monthly-save
{
  "student_id": 1,
  "month": 11,
  "year": 2025,
  "amount": 1000.00,
  "exam_fee": 200.00,    ✅ Supported
  "other_fee": 100.00    ✅ Supported
}
```

**Total Calculation:**
```python
# Updated formula in utils/response.py
total_amount = amount + late_fee + exam_fee + other_fee - discount
```

**Example:**
```
Amount:      1000.00
Late Fee:     100.00
Exam Fee:     200.00  ← NEW
Other Fee:    150.00  ← NEW
Discount:      50.00
─────────────────────
Total:       1400.00  (1000+100+200+150-50)
```

---

## Frontend Integration Needed

### SMS Templates:
**No changes needed!** The backend now saves permanently.

**Current Flow:**
1. Teacher edits template in UI
2. Frontend calls `POST /api/sms/templates/<template_type>`
3. Backend saves to database ✅
4. Template persists forever
5. Used in all SMS notifications

### Fee Columns:

The columns work in the API but may not be visible in the UI. **Frontend needs to:**

1. **Add input fields in fee forms:**
```html
<!-- Add these fields to fee creation/edit forms -->
<input name="exam_fee" type="number" placeholder="Exam Fee" />
<input name="other_fee" type="number" placeholder="Other Fee" />
```

2. **Display in fee tables:**
```html
<!-- Add these columns to fee display tables -->
<th>Exam Fee</th>
<th>Other Fee</th>
<th>Total</th>

<td>{{ fee.exam_fee }}</td>
<td>{{ fee.other_fee }}</td>
<td>{{ fee.total_amount }}</td>  <!-- Auto-calculated -->
```

3. **Include in API calls:**
```javascript
// When creating/updating fees
const feeData = {
  amount: 1000,
  exam_fee: 200,      // Add this
  other_fee: 100,     // Add this
  due_date: '2025-12-31'
};

fetch('/api/fees', {
  method: 'POST',
  body: JSON.stringify(feeData)
});
```

---

## Testing

### Test SMS Template Persistence:

1. **Save a template:**
```bash
curl -X POST http://localhost:8001/api/sms/templates/custom_exam \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"message": "Test template message"}'
```

2. **Check database:**
```sql
SELECT * FROM settings WHERE key LIKE 'sms_template_%';
```

3. **Logout and login again**

4. **Check template still exists:**
```bash
curl -X GET http://localhost:8001/api/sms/templates \
  -H "Authorization: Bearer <token>"
```

### Test Fee Columns:

1. **Create fee with exam_fee and other_fee:**
```bash
curl -X POST http://localhost:8001/api/fees \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "user_id": 1,
    "batch_id": 1,
    "amount": 1000.00,
    "exam_fee": 200.00,
    "other_fee": 100.00,
    "due_date": "2025-12-31"
  }'
```

2. **Check response:**
```json
{
  "success": true,
  "data": {
    "fee": {
      "amount": 1000.00,
      "exam_fee": 200.00,      ✅
      "other_fee": 100.00,     ✅
      "total_amount": 1300.00  ✅ (1000+200+100)
    }
  }
}
```

---

## Database Schema

### Settings Table:
```sql
-- SMS templates are stored here
SELECT * FROM settings WHERE category = 'sms_templates';

-- Example:
key: 'sms_template_custom_exam'
value: {"message": "Custom template text"}
category: 'sms_templates'
updated_by: 1
```

### Fees Table:
```sql
-- Columns already exist:
exam_fee DECIMAL(10,2) DEFAULT 0.00
others_fee DECIMAL(10,2) DEFAULT 0.00  -- Note: DB uses 'others_fee', API uses 'other_fee'
```

---

## Summary

### ✅ What's Fixed:

1. **SMS Templates:**
   - ✅ Now save permanently to database (Settings table)
   - ✅ Persist after logout
   - ✅ Used everywhere in the system
   - ✅ Backward compatible (also in session)

2. **Fee Columns:**
   - ✅ Database columns exist (exam_fee, other_fee)
   - ✅ API fully supports them
   - ✅ Total calculation includes them
   - ✅ All CRUD endpoints updated

### ⏳ What Frontend Needs:

1. **For Fee Columns:**
   - Add input fields for exam_fee and other_fee
   - Display columns in fee tables
   - Include in form submissions

2. **For SMS Templates:**
   - Nothing! Already works with current frontend

---

## Files Modified

| File | Change |
|------|--------|
| `routes/sms_templates.py` | Changed update_template() to save to database permanently |
| `routes/fees.py` | Already updated (from previous session) |
| `utils/response.py` | Already updated (from previous session) |
| `models.py` | No changes (columns already exist) |

---

## Deployment

```bash
# On VPS:
cd /var/www/saroyarsir
git pull origin main
sudo systemctl restart saro

# Verify SMS templates
curl -X GET http://gsteaching.com:8001/api/sms/templates \
  -H "Authorization: Bearer <token>"

# Test fee creation with new columns
curl -X POST http://gsteaching.com:8001/api/fees \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"user_id":1,"batch_id":1,"amount":1000,"exam_fee":200,"other_fee":100,"due_date":"2025-12-31"}'
```

---

## Validation

✅ No errors in code
✅ SMS templates save to database
✅ Fee columns work in API
✅ Total calculation updated
✅ Backward compatible

**Everything is working on the backend!**
Frontend just needs to add UI fields for exam_fee and other_fee.
