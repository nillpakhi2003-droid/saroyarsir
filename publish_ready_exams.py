#!/usr/bin/env python3
"""
Auto-publish online exams that have all questions saved
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from models import db, OnlineExam, OnlineQuestion

def main():
    app = create_app('production')
    
    with app.app_context():
        print("Auto-Publishing Ready Online Exams...")
        print("=" * 60)
        
        # Find exams with complete questions
        exams = OnlineExam.query.all()
        published_count = 0
        
        for exam in exams:
            questions_count = OnlineQuestion.query.filter_by(exam_id=exam.id).count()
            
            # Only publish if has all questions
            if questions_count >= exam.total_questions:
                if not exam.is_published or not exam.is_active:
                    print(f"Publishing: {exam.title} (ID {exam.id})")
                    print(f"  Questions: {questions_count}/{exam.total_questions} ✓")
                    exam.is_published = True
                    exam.is_active = True
                    published_count += 1
        
        if published_count > 0:
            db.session.commit()
            print(f"\n✅ Published {published_count} exam(s)")
        else:
            print("No exams needed publishing (all complete exams already published)")
        
        # Show final status
        print("\nFinal Status:")
        print("-" * 60)
        student_visible = OnlineExam.query.filter_by(
            is_published=True,
            is_active=True
        ).count()
        print(f"Total exams students can see: {student_visible}")

if __name__ == '__main__':
    main()
