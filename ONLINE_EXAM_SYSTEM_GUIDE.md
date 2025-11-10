# Online Exam System - Complete Guide

## ✅ System Overview

The online exam system allows teachers to create MCQ (Multiple Choice Question) exams with automatic grading and instant results for students.

---

## 👨‍🏫 For Teachers

### Step 1: Create an Exam

1. Login to teacher dashboard (Phone: 01800000000, Password: teacher123)
2. Click on **"Online Exam"** in the menu
3. Click **"Create Online Exam"** button
4. Fill in exam details:
   - **Exam Title**: e.g., "Physics Chapter 1 Test"
   - **Class Name**: e.g., "Class 10"
   - **Book Name**: e.g., "Physics Book 1"
   - **Chapter Name**: e.g., "Motion"
   - **Duration**: How many minutes (e.g., 30 minutes)
   - **Total Questions**: How many questions (max 40) - e.g., 20
   - **Pass Percentage**: e.g., 40%
   - **Allow Retake**: Check if students can retake

5. Click **"Create Exam"**

### Step 2: Add Questions (Auto-Generated Forms)

After creating the exam, the system will:
- **Automatically create** question forms based on the number you selected
- Example: If you selected 20 questions, 20 empty question forms appear
- You just need to **fill them in**!

For each question, fill in:
- **Question Text**: The question itself
- **Option A, B, C, D**: Four answer choices
- **Correct Answer**: Select A, B, C, or D
- **Points**: How many points (default 1)
- **Explanation** (optional): Why this answer is correct

### Step 3: Save and Publish

1. After filling all questions, click **"Save All & Publish"**
2. System will:
   - Save all your questions
   - Automatically **publish** the exam
   - Students can now see and take it!

### Managing Exams

From the exam list, you can:
- **👁️ Publish/Unpublish**: Eye icon - make exam visible/hidden to students
- **📝 Manage Questions**: List icon - edit questions
- **✏️ Edit**: Edit exam details
- **🗑️ Delete**: Delete entire exam

---

## 👨‍🎓 For Students

### Taking an Exam

1. Login to student dashboard
2. Click **"Online Exam"** in the menu
3. You will see all **published exams**
4. Each exam card shows:
   - Exam title, class, book, chapter
   - Duration (how long you have)
   - Total questions
   - Pass percentage
   - Your previous attempts (if any)
   - Your best score (if taken before)

5. Click **"Start Exam"** or **"Take Again"**

### During the Exam

- Timer counts down automatically
- Click on A, B, C, or D to select your answer
- Answers are saved automatically
- Bottom shows: "X of Y answered"
- You can change answers anytime before submitting

### Submitting

- Click **"Submit Exam"** when done
- OR wait - exam **auto-submits** when time expires
- You'll see results immediately!

### Results Screen

Shows:
- Your percentage score (e.g., 85%)
- Pass/Fail status
- Number of correct answers
- Total questions
- Time taken
- Whether it was auto-submitted

---

## 🔧 Technical Features

### Teacher Features
✅ Create unlimited exams
✅ Auto-generate question templates (up to 40 questions)
✅ Bulk save all questions at once
✅ Publish/unpublish exams
✅ Edit and delete exams
✅ Track question count per exam

### Student Features
✅ View all published exams
✅ See exam details before starting
✅ Timer with countdown
✅ Auto-save answers
✅ Auto-submit on time expiry
✅ Instant results
✅ Retake capability (if allowed)
✅ Track best score and attempts

### Security & Validation
✅ Only published exams visible to students
✅ Questions must have all 4 options filled
✅ Timer cannot be paused
✅ Answers saved in database
✅ Auto-submit prevents cheating

---

## 📊 Database Structure

### Tables Used
- `online_exams` - Exam metadata
- `online_questions` - MCQ questions
- `online_exam_attempts` - Student attempt records
- `online_student_answers` - Individual answers

---

## 🎯 Example Workflow

**Teacher Creates Exam:**
1. Create "Physics Mid-term" for Class 10
2. Set 20 questions, 30 minutes, 40% pass
3. System auto-creates 20 empty question forms
4. Teacher fills Question 1: "What is velocity?" with 4 options
5. Teacher fills Questions 2-20
6. Click "Save All & Publish"
7. Exam is now live!

**Student Takes Exam:**
1. Student sees "Physics Mid-term" card
2. Clicks "Start Exam"
3. Timer starts: 30:00
4. Answers 20 questions
5. Clicks "Submit Exam"
6. Gets 85% score - PASSED! 🎉
7. Can retake if allowed

---

## 🚀 Quick Tips

### For Teachers
- Create draft exam first, publish after reviewing questions
- Use meaningful titles (include class, subject, chapter)
- Set realistic time limits (1-2 minutes per question)
- Add explanations to help students learn
- Unpublish exam after deadline

### For Students
- Read all options carefully
- Manage your time (check timer)
- Review answers before submitting
- Don't refresh page during exam
- Take allowed retakes to improve

---

## 📱 Access Points

**Teacher Dashboard:**
- Menu: Online Exam → Create/Manage exams

**Student Dashboard:**
- Menu: Online Exam → View and take exams

---

## 🆘 Troubleshooting

**Problem:** Can't see Online Exam menu
**Solution:** Hard refresh browser (Ctrl+Shift+R)

**Problem:** Questions not saving
**Solution:** Fill all required fields (question text + all 4 options)

**Problem:** Students can't see exam
**Solution:** Make sure exam is Published (green badge)

**Problem:** Timer not working
**Solution:** Refresh page and restart exam

---

## ✨ Summary

The system is designed to be **simple and automatic**:
1. Teacher selects number of questions (e.g., 20)
2. System creates 20 empty forms
3. Teacher fills and saves
4. Students take and get instant results!

**No complex workflows, just fill and publish!** 🎓
