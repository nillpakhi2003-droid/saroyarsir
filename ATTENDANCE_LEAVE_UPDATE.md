# Attendance Status Update: Holiday → Leave

## Summary of Changes

Changed the attendance system to use **"L" for Leave** instead of **"H" for Holiday"**.

## What Changed

### 1. **Database Model** ([models.py](models.py))
- `AttendanceStatus.HOLIDAY` → `AttendanceStatus.LEAVE`
- Enum value changed from `"holiday"` to `"leave"`

### 2. **Frontend UI** ([attendance_management.html](templates/templates/partials/attendance_management.html))
- **Button Label**: "Mark All Holiday" → "Mark All Leave"
- **Button Letter**: "H" → "L"
- **Statistics**: "Holiday" count → "Leave" count
- **Status Badge**: "Holiday" → "Leave"
- **All references to 'holiday' status changed to 'leave'**

### 3. **JavaScript Functions** ([dashboard_teacher.html](templates/templates/dashboard_teacher.html))
- `markAllHoliday()` → `markAllLeave()`
- `holidayCount` → `leaveCount`
- `getAttendanceSymbol()`: Returns 'L' for leave status
- `getAttendanceClass()`: Uses 'leave' instead of 'holiday'

### 4. **Display Changes**
- **Mark Attendance Tab**:
  - P = Present (Green)
  - A = Absent (Red)
  - L = Leave (Orange) ← Changed from H
  
- **Monthly Sheet**:
  - Shows "L" for leave days instead of "H"

## Migration Required

To update existing attendance records in the database:

```bash
python3 migrate_holiday_to_leave.py
```

This will:
1. Count all attendance records with 'holiday' status
2. Ask for confirmation
3. Update them to 'leave' status
4. Verify the changes

## Status Meanings

| Status | Letter | Color | Meaning |
|--------|--------|-------|---------|
| Present | P | Green | Student attended class |
| Absent | A | Red | Student did not attend |
| Leave | L | Orange | Student on approved leave |
| Late | L | Yellow | Student arrived late (Note: Same letter as Leave) |

## Files Modified

1. `/workspaces/saroyarsir/models.py`
   - Changed AttendanceStatus enum

2. `/workspaces/saroyarsir/templates/templates/partials/attendance_management.html`
   - Updated UI labels, buttons, and status displays

3. `/workspaces/saroyarsir/templates/templates/dashboard_teacher.html`
   - Updated JavaScript functions and computed properties

4. `/workspaces/saroyarsir/migrate_holiday_to_leave.py` (NEW)
   - Migration script for database records

## Testing Checklist

- [ ] Mark individual student as Leave (L button works)
- [ ] "Mark All Leave" button works
- [ ] Leave count displays correctly in statistics
- [ ] Status badge shows "Leave" not "Holiday"
- [ ] Monthly attendance sheet shows "L" for leave days
- [ ] Database migration completed successfully
- [ ] No references to "holiday" remain in UI

## API Compatibility

The backend API automatically accepts both:
- New requests with `status: "leave"`
- Old data might have `status: "holiday"` (before migration)

After running the migration script, all data will use the new "leave" status.

## Note on "Late" Status

⚠️ Both "Late" and "Leave" now use the letter "L". However:
- **Leave** has orange background (`bg-orange-500`)
- **Late** has yellow background (`bg-yellow-500`)
- They can be distinguished by color in the UI

If this creates confusion, consider changing:
- Late to use a different letter (e.g., "T" for Tardy)
- Or keep the color distinction clear

## Deployment Steps

1. **Update code** (already done)
2. **Run migration**:
   ```bash
   python3 migrate_holiday_to_leave.py
   ```
3. **Test the changes** in development
4. **Deploy to production**:
   ```bash
   ./deploy_to_vps.sh  # or your deployment script
   ```
5. **Run migration on production database**

## Rollback (if needed)

If you need to revert:

```sql
UPDATE attendance SET status = 'holiday' WHERE status = 'leave';
```

Then restore the old code from git.
