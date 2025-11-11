#!/bin/bash

echo "========================================"
echo "🔧 VPS Database Migration - Add Missing Columns"
echo "========================================"
echo ""

cat << 'VPSCMD'
cd /var/www/saroyarsir
source venv/bin/activate

python3 << 'EOF'
from app import create_app
from models import db
import sys

app = create_app('production')

with app.app_context():
    print("=" * 60)
    print("DATABASE MIGRATION - Adding Missing Columns")
    print("=" * 60)
    print()
    
    try:
        # ===== FIX 1: Add description column to online_exams =====
        print("1️⃣ Checking online_exams table...")
        result = db.session.execute(db.text("PRAGMA table_info(online_exams)")).fetchall()
        columns = [row[1] for row in result]
        
        if 'description' not in columns:
            print("   ➕ Adding 'description' column...")
            db.session.execute(db.text(
                "ALTER TABLE online_exams ADD COLUMN description TEXT"
            ))
            db.session.commit()
            print("   ✅ Column 'description' added!")
        else:
            print("   ✅ Column 'description' already exists")
        
        # ===== FIX 2: Verify exam_fee and others_fee columns =====
        print()
        print("2️⃣ Checking fees table...")
        result = db.session.execute(db.text("PRAGMA table_info(fees)")).fetchall()
        columns = [row[1] for row in result]
        
        fees_updated = False
        
        if 'exam_fee' not in columns:
            print("   ➕ Adding 'exam_fee' column...")
            db.session.execute(db.text(
                "ALTER TABLE fees ADD COLUMN exam_fee DECIMAL(10, 2) DEFAULT 0.00"
            ))
            db.session.commit()
            print("   ✅ Column 'exam_fee' added!")
            fees_updated = True
        else:
            print("   ✅ Column 'exam_fee' already exists")
        
        if 'others_fee' not in columns:
            print("   ➕ Adding 'others_fee' column...")
            db.session.execute(db.text(
                "ALTER TABLE fees ADD COLUMN others_fee DECIMAL(10, 2) DEFAULT 0.00"
            ))
            db.session.commit()
            print("   ✅ Column 'others_fee' added!")
            fees_updated = True
        else:
            print("   ✅ Column 'others_fee' already exists")
        
        # ===== VERIFY ALL FIXES =====
        print()
        print("=" * 60)
        print("VERIFICATION")
        print("=" * 60)
        
        # Verify online_exams
        result = db.session.execute(db.text("PRAGMA table_info(online_exams)")).fetchall()
        online_exam_cols = [row[1] for row in result]
        if 'description' in online_exam_cols:
            print("✅ online_exams.description - EXISTS")
        else:
            print("❌ online_exams.description - MISSING")
            sys.exit(1)
        
        # Verify fees
        result = db.session.execute(db.text("PRAGMA table_info(fees)")).fetchall()
        fee_cols = [row[1] for row in result]
        if 'exam_fee' in fee_cols and 'others_fee' in fee_cols:
            print("✅ fees.exam_fee & fees.others_fee - EXIST")
        else:
            print("❌ Fee columns - MISSING")
            sys.exit(1)
        
        # Count records
        exam_count = db.session.execute(db.text("SELECT COUNT(*) FROM online_exams")).fetchone()[0]
        fee_count = db.session.execute(db.text("SELECT COUNT(*) FROM fees")).fetchone()[0]
        
        print()
        print(f"📊 Current data:")
        print(f"   - Online Exams: {exam_count}")
        print(f"   - Fee Records: {fee_count}")
        print()
        print("=" * 60)
        print("✅ DATABASE MIGRATION COMPLETE!")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.session.rollback()
        sys.exit(1)
EOF

deactivate

echo ""
echo "========================================" 
echo "✅ Migration Complete!"
echo "========================================" 
echo ""
echo "Now restart the service:"
echo "sudo systemctl restart saro.service"
echo ""

VPSCMD
