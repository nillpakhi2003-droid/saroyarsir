#!/bin/bash

# Test Fee System with Exam Fee and Other Fee
# Run this after logging in as teacher/admin

echo "=================================================="
echo "Testing Fee Creation with Exam Fee & Other Fee"
echo "=================================================="

# First, get authentication token (replace with actual login)
echo ""
echo "Step 1: Login as teacher to get token..."
echo "POST /api/auth/login"
echo "Phone: 01800000000"
echo "Password: teacher123"

# For manual testing, get the token from login response and set it here:
# TOKEN="your_token_here"

# Test 1: Create a single fee with exam_fee and other_fee
echo ""
echo "=================================================="
echo "Test 1: Create Fee with Exam Fee & Other Fee"
echo "=================================================="
echo ""
echo "POST http://localhost:8001/api/fees"
echo ""
echo "Request Body:"
cat << 'EOF'
{
  "user_id": 1,
  "batch_id": 1,
  "amount": 1000.00,
  "exam_fee": 200.00,
  "other_fee": 100.00,
  "due_date": "2025-12-31",
  "notes": "Test fee with exam and other charges"
}
EOF

echo ""
echo ""
echo "Expected Response:"
cat << 'EOF'
{
  "success": true,
  "message": "Fee created successfully",
  "data": {
    "fee": {
      "amount": 1000.00,
      "exam_fee": 200.00,
      "other_fee": 100.00,
      "late_fee": 0.00,
      "discount": 0.00,
      "total_amount": 1300.00  ← (1000 + 200 + 100)
    }
  }
}
EOF

# Test 2: Update fee with new exam_fee
echo ""
echo ""
echo "=================================================="
echo "Test 2: Update Fee - Change Exam Fee"
echo "=================================================="
echo ""
echo "PUT http://localhost:8001/api/fees/1"
echo ""
echo "Request Body:"
cat << 'EOF'
{
  "exam_fee": 300.00,
  "other_fee": 150.00
}
EOF

echo ""
echo ""
echo "Expected Response:"
cat << 'EOF'
{
  "success": true,
  "message": "Fee updated successfully",
  "data": {
    "fee": {
      "amount": 1000.00,
      "exam_fee": 300.00,  ← Updated
      "other_fee": 150.00,  ← Updated
      "total_amount": 1450.00  ← (1000 + 300 + 150)
    }
  }
}
EOF

# Test 3: Bulk create with exam_fee
echo ""
echo ""
echo "=================================================="
echo "Test 3: Bulk Create Fees with Exam Fee"
echo "=================================================="
echo ""
echo "POST http://localhost:8001/api/fees/bulk-create"
echo ""
echo "Request Body:"
cat << 'EOF'
{
  "batch_id": 1,
  "amount": 1500.00,
  "exam_fee": 250.00,
  "other_fee": 100.00,
  "due_date": "2025-11-30"
}
EOF

echo ""
echo ""
echo "This will create fees for all students in batch with:"
echo "  - Amount: 1500.00"
echo "  - Exam Fee: 250.00"
echo "  - Other Fee: 100.00"
echo "  - Total per student: 1850.00"

# Test 4: Monthly fee creation
echo ""
echo ""
echo "=================================================="
echo "Test 4: Create Monthly Fees with Exam Fee"
echo "=================================================="
echo ""
echo "POST http://localhost:8001/api/fees/batch/1/monthly"
echo ""
echo "Request Body:"
cat << 'EOF'
{
  "month": 11,
  "year": 2025,
  "amount": 1200.00,
  "exam_fee": 200.00,
  "other_fee": 50.00
}
EOF

echo ""
echo ""
echo "This will create November 2025 fees for all students with:"
echo "  - Monthly Fee: 1200.00"
echo "  - Exam Fee: 200.00"
echo "  - Other Fee: 50.00"
echo "  - Total per student: 1450.00"

echo ""
echo ""
echo "=================================================="
echo "REMOVED ENDPOINTS - Should Return 404"
echo "=================================================="
echo ""

echo "❌ GET /api/online-exams/<exam_id>/analytics"
echo "   Status: 404 Not Found (Removed)"
echo ""

echo "❌ GET /api/online-exams/<exam_id>/my-attempts"
echo "   Status: 404 Not Found (Removed)"
echo ""

echo ""
echo "=================================================="
echo "Total Amount Calculation Formula"
echo "=================================================="
echo ""
echo "OLD: total = amount + late_fee - discount"
echo "NEW: total = amount + late_fee + exam_fee + other_fee - discount"
echo ""
echo "Example:"
echo "  Amount:     1000.00"
echo "  Late Fee:    100.00"
echo "  Exam Fee:    200.00"
echo "  Other Fee:   150.00"
echo "  Discount:     50.00"
echo "  ─────────────────────"
echo "  Total:      1400.00  (1000+100+200+150-50)"
echo ""

echo "=================================================="
echo "Test Complete!"
echo "=================================================="
echo ""
echo "To actually run API tests, use curl with authentication:"
echo ""
echo "# 1. Login first"
echo 'curl -X POST http://localhost:8001/api/auth/login \'
echo '  -H "Content-Type: application/json" \'
echo "  -d '{\"phoneNumber\":\"01800000000\",\"password\":\"teacher123\"}'"
echo ""
echo "# 2. Copy the token from response"
echo ""
echo "# 3. Create fee with exam_fee and other_fee"
echo 'curl -X POST http://localhost:8001/api/fees \'
echo '  -H "Content-Type: application/json" \'
echo '  -H "Authorization: Bearer YOUR_TOKEN" \'
echo '  -d '"'"'{"user_id":1,"batch_id":1,"amount":1000,"exam_fee":200,"other_fee":100,"due_date":"2025-12-31"}'"'"''
echo ""
