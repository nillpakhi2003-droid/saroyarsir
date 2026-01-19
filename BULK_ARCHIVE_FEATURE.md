# Bulk Archive Students Feature

## Feature Overview
Teachers can now select multiple students and archive them all at once using checkboxes.

## How to Use

### 1. **Select Students**
- ✅ Click individual checkboxes next to student names
- ✅ Use "Select All" checkbox in header to select all visible students
- ✅ Selected rows are highlighted in blue

### 2. **Archive Selected**
- Click the "Archive Selected (X)" button that appears when students are selected
- Enter an optional reason for archiving
- Confirm the action
- All selected students will be archived

### 3. **Visual Feedback**
- Selected students: Blue background highlight
- "Archive Selected" button shows count of selected students
- Button only appears when students are selected
- Success/error toasts after archiving

## Features

### Backend API
**Endpoint:** `POST /api/students/bulk-archive`

**Request:**
```json
{
  "student_ids": [1, 2, 3, 4],
  "reason": "End of semester"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Successfully archived 4 student(s)",
  "data": {
    "archived_count": 4,
    "archived_students": [
      {"id": 1, "name": "John Doe"},
      {"id": 2, "name": "Jane Smith"}
    ],
    "already_archived_count": 0,
    "already_archived": [],
    "not_found_count": 0,
    "not_found": []
  }
}
```

### UI Components

1. **Select All Checkbox** (Table Header)
   - Selects/deselects all visible students
   - Shows indeterminate state when some selected

2. **Individual Checkboxes** (Each Row)
   - Select/deselect individual students
   - Works with filtering (only visible students)

3. **Archive Selected Button** (Top Right)
   - Only visible when students are selected
   - Shows count of selected students
   - Orange/red gradient color scheme

4. **Row Highlighting**
   - Selected rows have blue background (`bg-blue-50`)
   - Easy to see which students are selected

## Workflow

1. **Teacher selects students:**
   - Click checkboxes next to student names
   - OR click "Select All" to select all visible students

2. **Click "Archive Selected (X)":**
   - Button appears in header when selections made
   - Shows number of students selected

3. **Enter reason (optional):**
   - Popup dialog asks for archive reason
   - Can leave blank or press Cancel to abort

4. **Confirmation:**
   - All selected students are archived
   - Success toast shows count archived
   - Student list refreshes automatically
   - Checkboxes are cleared

## Technical Details

### State Management
```javascript
selectedStudents: new Set()  // Tracks selected student IDs
```

### Functions Added

**`toggleStudentSelection(studentId, isChecked)`**
- Adds/removes student from selection set

**`toggleSelectAll(isChecked)`**
- Selects/deselects all filtered students

**`bulkArchiveStudents()`**
- Archives all selected students
- Sends array of IDs to backend
- Clears selection after success

### Database Updates
For each archived student:
- `is_archived = True`
- `archived_at = current timestamp`
- `archived_by = current teacher ID`
- `archive_reason = provided reason or default`

## Error Handling

- ✅ **No students selected:** Warning toast
- ✅ **Already archived:** Skipped, reported in response
- ✅ **Student not found:** Skipped, reported in response
- ✅ **Network error:** Error toast with message
- ✅ **Cancelled by user:** No action taken

## Benefits

1. **Efficiency** - Archive multiple students at once
2. **Batch Operations** - End of semester, class transitions
3. **Flexibility** - Can select any combination of students
4. **Safety** - Requires confirmation before archiving
5. **Transparency** - Clear visual feedback on selections

## Example Use Cases

### End of Semester
1. Filter by graduating batch
2. Click "Select All"
3. Click "Archive Selected"
4. Enter reason: "Completed semester 2025-2026"

### Individual Selection
1. Select specific students who left
2. Click "Archive Selected (3)"
3. Enter reason: "Transferred to other institution"

### Mixed Batches
1. Use filters to narrow down
2. Select individual students across batches
3. Bulk archive with single click

## Security

- ✅ Requires teacher or super_user role
- ✅ Login required
- ✅ Validates student IDs
- ✅ Transaction rollback on error
- ✅ Records who archived and when

## Database Impact

- No schema changes required
- Uses existing `is_archived`, `archived_at`, `archived_by` fields
- Atomic transaction for all archives
- Rollback on any error

## Testing

To test the feature:

1. **Load student list**
2. **Select multiple students** (checkboxes)
3. **Click "Archive Selected"**
4. **Verify:**
   - Success message shows correct count
   - Students removed from active list
   - Students appear in Archive Management
   - Archive reason saved correctly

## Files Modified

1. `/workspaces/saroyarsir/routes/students.py`
   - Added `bulk-archive` endpoint

2. `/workspaces/saroyarsir/templates/templates/partials/student_management.html`
   - Added checkboxes to table
   - Added "Archive Selected" button
   - Added selection functions
   - Added bulk archive logic

## Future Enhancements

Possible improvements:
- Bulk restore students
- Export selected students
- Bulk assign to batch
- Bulk SMS to selected students
- CSV export of selected students
