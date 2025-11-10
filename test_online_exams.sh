#!/bin/bash

# Quick test script for Online Exam System

echo "🧪 Testing Online Exam System API"
echo "=================================="
echo ""

BASE_URL="http://localhost:8001"

echo "📝 Test 1: Create Online Exam (Teacher)"
curl -X POST $BASE_URL/api/online-exams \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Physics Chapter 1 - Motion Test",
    "description": "Test your knowledge on motion and forces",
    "class_name": "Class 10",
    "book_name": "Physics",
    "chapter_name": "Chapter 1: Motion",
    "duration": 30,
    "total_questions": 5,
    "pass_percentage": 40,
    "allow_retake": true
  }'

echo -e "\n\n"

echo "📝 Test 2: Add Question 1"
curl -X POST $BASE_URL/api/online-exams/1/questions \
  -H "Content-Type: application/json" \
  -d '{
    "question_text": "What is Newton'\''s First Law of Motion?",
    "option_a": "Force equals mass times acceleration",
    "option_b": "An object at rest stays at rest unless acted upon by an external force",
    "option_c": "For every action there is an equal and opposite reaction",
    "option_d": "Energy cannot be created or destroyed",
    "correct_answer": "B",
    "explanation": "Newton'\''s First Law states that an object at rest will remain at rest, and an object in motion will remain in motion at constant velocity, unless acted upon by an external force."
  }'

echo -e "\n\n"

echo "📝 Test 3: Add Question 2"
curl -X POST $BASE_URL/api/online-exams/1/questions \
  -H "Content-Type: application/json" \
  -d '{
    "question_text": "What is the SI unit of force?",
    "option_a": "Joule",
    "option_b": "Watt",
    "option_c": "Newton",
    "option_d": "Pascal",
    "correct_answer": "C",
    "explanation": "The SI unit of force is Newton (N), named after Sir Isaac Newton. 1 Newton = 1 kg·m/s²"
  }'

echo -e "\n\n"

echo "📝 Test 4: Get All Exams"
curl -X GET $BASE_URL/api/online-exams

echo -e "\n\n"

echo "✅ Test Complete!"
echo ""
echo "Next steps:"
echo "1. Complete adding 3 more questions"
echo "2. Publish the exam: PUT /api/online-exams/1 {\"is_published\": true}"
echo "3. Student can start exam: POST /api/online-exams/1/start"
echo "4. Submit answers and see results"
