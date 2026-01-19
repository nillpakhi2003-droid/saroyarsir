# Monthly Attendance Sheet Download Feature

## Overview
Added a "Download Sheet" button to export monthly attendance data as a CSV file.

## Features

### 📥 Download Button
- Located in the Monthly Sheet tab header
- Green button with download icon
- Shows loading state while downloading
- Automatically names file with batch, month, and year

### 📊 CSV File Contents

**File includes:**
1. **Header Section**
   - Batch name
   - Month and year
   
2. **Attendance Table**
   - Student names and phone numbers
   - Daily attendance (P/A/L/-)
   - Day names (Mon, Tue, Wed, etc.)
   - Summary statistics per student:
     - Total Present
     - Total Absent  
     - Total Leave
     - Attendance Percentage

3. **Legend**
   - P = Present
   - A = Absent
   - L = Leave
   - - = Not Marked

### 📋 File Naming
Format: `Attendance_{BatchName}_{Month}_{Year}.csv`

Example: `Attendance_SSC-26_January_2026.csv`

## How to Use

1. **Navigate to Attendance → Monthly Sheet tab**
2. **Select:**
   - Batch (e.g., SSC-26 - Class 10 - Mathematics)
   - Month (e.g., January)
   - Year (e.g., 2026)
3. **Click "Download Sheet" button**
4. **File downloads automatically** to your Downloads folder

## Technical Details

### Backend API
**Endpoint:** `GET /api/attendance/download-monthly`

**Parameters:**
- `batch_id` (int) - Required
- `month` (int, 1-12) - Required
- `year` (int) - Required

**Response:**
- Content-Type: `text/csv`
- File download with proper headers

### Frontend
**Button Location:** Monthly Sheet tab header

**Function:** `downloadMonthlySheet()`
- Validates selection
- Shows loading state
- Fetches CSV file
- Triggers browser download
- Shows success message

## Files Modified

1. **`/workspaces/saroyarsir/routes/attendance.py`**
   - Added `download-monthly` endpoint
   - Generates CSV with attendance data
   - Includes statistics and formatting

2. **`/workspaces/saroyarsir/templates/templates/partials/attendance_management.html`**
   - Added "Download Sheet" button
   - Positioned in header with flex layout

3. **`/workspaces/saroyarsir/templates/templates/dashboard_teacher.html`**
   - Added `downloadMonthlySheet()` function
   - Handles file download with proper naming
   - Shows loading and success states

## Example CSV Output

```csv
Monthly Attendance Sheet - SSC-26 - Class 10 - Mathematics
January 2026

Student Name,Phone,1,2,3,...,31,Total Present,Total Absent,Total Leave,Attendance %
,Mon,Tue,Wed,...,Sat,,,,
Arko Mohanta,01712345678,P,P,A,...,P,25,3,2,83.3%
Bivash Chandra,01798765432,P,P,P,...,P,28,1,1,93.3%

Legend:,P = Present,A = Absent,L = Leave,- = Not Marked
```

## Use Cases

### For Teachers
- ✅ Print attendance sheets for records
- ✅ Share with administration
- ✅ Submit monthly reports
- ✅ Backup attendance data
- ✅ Analyze attendance patterns in Excel

### For Administration
- ✅ Monitor batch attendance
- ✅ Identify students with low attendance
- ✅ Generate reports
- ✅ Archive records

## Benefits

1. **Easy Export** - One-click download
2. **Professional Format** - Well-formatted CSV
3. **Complete Data** - All attendance info included
4. **Statistics** - Auto-calculated percentages
5. **Portable** - Opens in Excel, Google Sheets, etc.
6. **Printable** - Ready for printing

## Browser Compatibility

Works on all modern browsers:
- ✅ Chrome/Edge
- ✅ Firefox
- ✅ Safari
- ✅ Mobile browsers

## Future Enhancements

Possible improvements:
- PDF export option
- Excel (.xlsx) format with styling
- Email attendance sheet
- Schedule automatic monthly exports
- Custom date range exports
- Filter by student
- Include guardian phone numbers
