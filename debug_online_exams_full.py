#!/usr/bin/env python3
"""
Debug script for Online Exams - Full diagnostic
Checks:
- Exam records with published/active status
- Question counts per exam
- Student attempt data
- Field consistency
"""
import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from models import db, OnlineExam, OnlineQuestion, OnlineExamAttempt, User, UserRole

def main():
    app = create_app('production')
    
    with app.app_context():
        print("=" * 80)
        print("ONLINE EXAMS DIAGNOSTIC")
        print("=" * 80)
        
        # 1. Check all exams
        print("\n1. ALL ONLINE EXAMS:")
        print("-" * 80)
        exams = OnlineExam.query.order_by(OnlineExam.created_at.desc()).all()
        print(f"Total exams in database: {len(exams)}\n")
        
        for exam in exams:
            questions_count = OnlineQuestion.query.filter_by(exam_id=exam.id).count()
            print(f"ID: {exam.id}")
            print(f"  Title: {exam.title}")
            print(f"  Class: {exam.class_name}, Book: {exam.book_name}, Chapter: {exam.chapter_name}")
            print(f"  Duration: {exam.duration} min, Total Questions: {exam.total_questions}")
            print(f"  Pass %: {exam.pass_percentage}, Allow Retake: {exam.allow_retake}")
            print(f"  🔴 is_published: {exam.is_published}")
            print(f"  🔴 is_active: {exam.is_active}")
            print(f"  Questions saved: {questions_count}/{exam.total_questions}")
            print(f"  Created: {exam.created_at}")
            print()
        
        # 2. Published & Active exams (what students should see)
        print("\n2. PUBLISHED & ACTIVE EXAMS (Student View):")
        print("-" * 80)
        student_exams = OnlineExam.query.filter_by(
            is_published=True, 
            is_active=True
        ).order_by(OnlineExam.created_at.desc()).all()
        
        print(f"Published & Active exams: {len(student_exams)}\n")
        
        if len(student_exams) == 0:
            print("❌ NO EXAMS ARE BOTH PUBLISHED AND ACTIVE!")
            print("   Students will see empty list.")
            print("\nTo fix:")
            print("  1. Use teacher dashboard to toggle publish")
            print("  2. Or use SQL update:")
            print("     UPDATE online_exams SET is_published=1, is_active=1 WHERE id=EXAM_ID;")
        else:
            for exam in student_exams:
                questions_count = OnlineQuestion.query.filter_by(exam_id=exam.id).count()
                print(f"✅ ID {exam.id}: {exam.title} ({questions_count} questions)")
        
        # 3. Check students
        print("\n\n3. STUDENT ACCOUNTS:")
        print("-" * 80)
        students = User.query.filter_by(role=UserRole.STUDENT).limit(5).all()
        print(f"Sample students (first 5): {len(students)}\n")
        for student in students:
            print(f"  ID: {student.id}, Name: {student.first_name} {student.last_name}, Phone: {student.phone}")
        
        # 4. Check attempts
        print("\n\n4. EXAM ATTEMPTS:")
        print("-" * 80)
        attempts = OnlineExamAttempt.query.limit(10).all()
        print(f"Total attempts (sample 10): {len(attempts)}\n")
        for attempt in attempts:
            print(f"  Attempt ID: {attempt.id}, Exam: {attempt.exam_id}, Student: {attempt.student_id}")
            print(f"    Started: {attempt.started_at}, Submitted: {attempt.is_submitted}")
            if attempt.is_submitted:
                print(f"    Score: {attempt.score}/{attempt.total_marks} ({attempt.percentage}%)")
        
        # 5. Quick fix suggestion
        print("\n\n5. QUICK FIX:")
        print("-" * 80)
        unpublished = OnlineExam.query.filter(
            (OnlineExam.is_published == False) | (OnlineExam.is_active == False)
        ).all()
        
        if unpublished:
            print(f"Found {len(unpublished)} exam(s) that need publishing:\n")
            for exam in unpublished:
                questions_count = OnlineQuestion.query.filter_by(exam_id=exam.id).count()
                print(f"  Exam ID {exam.id}: {exam.title}")
                print(f"    has {questions_count} questions, is_published={exam.is_published}, is_active={exam.is_active}")
                
                if questions_count >= exam.total_questions:
                    print(f"    ✅ Ready to publish (has all questions)")
                else:
                    print(f"    ⚠️  Needs {exam.total_questions - questions_count} more question(s)")
            
            print("\nTo auto-publish all ready exams, run:")
            print("  python3 publish_ready_exams.py")
        
        print("\n" + "=" * 80)
        print("DIAGNOSIS COMPLETE")
        print("=" * 80)

if __name__ == '__main__':
    main()
