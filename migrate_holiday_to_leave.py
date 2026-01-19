#!/usr/bin/env python3
"""
Migration Script: Update Attendance Status from 'holiday' to 'leave'
This script updates all existing attendance records with status 'holiday' to 'leave'
"""

from app import app
from models import db, Attendance
from sqlalchemy import text

def migrate_holiday_to_leave():
    """Update all attendance records from holiday to leave status"""
    with app.app_context():
        try:
            print("=" * 60)
            print("ATTENDANCE STATUS MIGRATION: holiday -> leave")
            print("=" * 60)
            
            # Count existing holiday records
            holiday_count = db.session.execute(
                text("SELECT COUNT(*) FROM attendance WHERE status = 'holiday'")
            ).scalar()
            
            print(f"\nFound {holiday_count} attendance records with 'holiday' status")
            
            if holiday_count == 0:
                print("\n✅ No records to migrate. Database is already up to date!")
                return
            
            # Confirm before proceeding
            confirm = input(f"\nUpdate {holiday_count} records from 'holiday' to 'leave'? (yes/no): ")
            if confirm.lower() != 'yes':
                print("\n❌ Migration cancelled by user")
                return
            
            # Update the records
            result = db.session.execute(
                text("UPDATE attendance SET status = 'leave' WHERE status = 'holiday'")
            )
            
            db.session.commit()
            
            print(f"\n✅ Successfully updated {result.rowcount} attendance records!")
            
            # Verify the update
            remaining_holiday = db.session.execute(
                text("SELECT COUNT(*) FROM attendance WHERE status = 'holiday'")
            ).scalar()
            
            new_leave_count = db.session.execute(
                text("SELECT COUNT(*) FROM attendance WHERE status = 'leave'")
            ).scalar()
            
            print(f"\nVerification:")
            print(f"  - Remaining 'holiday' records: {remaining_holiday}")
            print(f"  - Total 'leave' records: {new_leave_count}")
            
            if remaining_holiday == 0:
                print("\n✅ Migration completed successfully!")
            else:
                print(f"\n⚠️  Warning: {remaining_holiday} 'holiday' records still exist")
            
        except Exception as e:
            db.session.rollback()
            print(f"\n❌ Error during migration: {str(e)}")
            raise

if __name__ == '__main__':
    migrate_holiday_to_leave()
