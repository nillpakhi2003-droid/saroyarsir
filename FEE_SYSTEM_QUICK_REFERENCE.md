# Quick Reference: Fee System Changes

## What Changed?

### Before:
- Fee table had: `jf_amount` + `tf_amount` + `amount`
- UI showed: 24 columns (JF and TF for each of 12 months)
- User had to enter fees in two separate fields per month

### After:
- Fee table has: `amount` only (simpler)
- UI shows: 12 columns (one per month)
- User enters one amount per month
- `paid_date` automatically set when fee is marked as PAID

## Quick Start

### 1. Deploy Changes
```bash
cd /workspaces/saroyarsir
./deploy_fee_simplification.sh
```

### 2. Manual Template Update
Edit `templates/templates/dashboard_teacher.html`:
```html
<!-- OLD -->
{% include 'partials/fee_management_new.html' %}

<!-- NEW -->
{% include 'partials/fee_management_simple.html' %}
```

### 3. Restart Server
```bash
# Development
Ctrl+C
flask run --port 8001

# Production
sudo systemctl restart saroyarsir
```

## API Quick Reference

### Load Fees
```bash
GET /api/fees/load-monthly?batch_id=1&year=2025
```

### Save Fee
```bash
POST /api/fees/save-monthly
Content-Type: application/json

{
  "student_id": 1,
  "batch_id": 1,
  "month": 11,
  "year": 2025,
  "amount": 1000.00
}
```

### Mark as Paid
```bash
POST /api/fees/mark-paid
Content-Type: application/json

{
  "fee_id": 123
}
```

## Database Schema

### Fee Table (New)
```sql
CREATE TABLE fees (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    batch_id INTEGER NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,        -- Monthly fee
    exam_fee NUMERIC(10, 2) DEFAULT 0.00,  -- Exam fee
    others_fee NUMERIC(10, 2) DEFAULT 0.00, -- Other fees
    due_date DATE NOT NULL,
    paid_date DATE,                        -- Auto-set when status=PAID
    status TEXT DEFAULT 'pending',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    late_fee NUMERIC(10, 2) DEFAULT 0.00,
    discount NUMERIC(10, 2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (batch_id) REFERENCES batches(id)
);
```

## UI Features

### Simplified Fee Table
- **12 columns**: One per month (Jan-Dec)
- **Student row**: Shows student name and phone
- **Input field**: Single amount per month
- **Auto-totals**: Row totals and column totals
- **Change tracking**: Shows count of unsaved changes
- **Batch save**: Save all changes at once

### Features Kept
✓ Batch selection
✓ Year selection  
✓ Auto-calculation of totals
✓ Change tracking before save
✓ Loading states
✓ Error handling

### Features Removed
✗ JF/TF split (simplified to single amount)
✗ Complex column structure

## Troubleshooting

### Migration fails
```bash
# Check if database exists
ls -la *.db

# If backup exists, you can restore
cp smartgardenhub.db.backup_before_jf_tf_removal smartgardenhub.db
```

### UI doesn't show changes
1. Clear browser cache (Ctrl+Shift+R)
2. Check template includes correct partial
3. Check browser console for JavaScript errors

### API errors
```bash
# Test if routes are loaded
curl http://localhost:8001/api/fees/test

# Check server logs
tail -f logs/app.log
```

## Files Modified

| File | Purpose |
|------|---------|
| `models.py` | Removed jf_amount, tf_amount columns |
| `routes/fees_new.py` | Simplified fee routes |
| `templates/partials/fee_management_simple.html` | New simplified UI |
| `migrate_remove_jf_tf.py` | Database migration script |
| `deploy_fee_simplification.sh` | Deployment automation |

## Benefits Summary

1. **Simpler for users** - One field instead of two per month
2. **Cleaner UI** - Less visual clutter
3. **Faster data entry** - 50% fewer fields to fill
4. **Auto paid_date** - No manual date entry when marking paid
5. **SQLite ready** - Production-ready without MySQL
6. **Easier maintenance** - Less code complexity

## Support

For issues or questions:
1. Check `FEE_SYSTEM_SIMPLIFICATION.md` for details
2. Review migration logs
3. Check database backup in case rollback needed
