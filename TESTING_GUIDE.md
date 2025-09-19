# Testing the New Login System

## Overview
The login system has been updated to support your requirements:
- **Students**: Login with DU number only (no password)
- **Faculty/HOD**: Login with username + password

## Testing Instructions

### 1. Database Setup First
Before testing, run the SQL commands from `DATABASE_MIGRATION.md` in your Supabase project.

### 2. Testing Student Login

**Steps:**
1. Open the app
2. Select "Student" as role
3. Enter DU number: `DU1234029`
4. Click "Sign In"

**Expected Result:**
- System checks if DU number exists in database with role 'Student'
- If found, user is logged in and redirected to home screen
- If not found, error message: "DU number not found. Please contact administrator."

### 3. Testing Faculty Login

**Steps:**
1. Open the app
2. Select "Faculty" as role
3. Enter username: `hemantb`
4. Enter password: `faculty123`
5. Click "Sign In"

**Expected Result:**
- System checks username and password against database
- If correct, user is logged in and redirected to home screen
- If wrong, appropriate error message shown

### 4. Testing HOD Login

**Steps:**
1. Open the app
2. Select "HOD" as role
3. Enter username: `sureshk`
4. Enter password: `hod123`
5. Click "Sign In"

**Expected Result:**
- Same as faculty login but with HOD permissions

## Key Features

### UI Changes:
- **Student Login**: Only shows DU Number field
- **Faculty/HOD Login**: Shows Username and Password fields
- No email field for anyone
- Smart validation for DU number format (DU followed by 7 digits)

### Sign Up Changes:
- Students: No password field in sign up
- Faculty: Password field available in sign up
- Auto-generates username for faculty based on name

### Security:
- Students authenticate by DU number existence in database
- Faculty authenticate by username/password combination
- No Supabase Auth required - simplified database-only authentication

## Example Users to Add to Database

```sql
-- Students (no password needed)
INSERT INTO users (name, user_id, department, year, role, phone) VALUES
('Om Pradip Patil', 'DU1234029', 'CSE', '3rd Year', 'Student', '9876543210');

-- Faculty (with username and password)
INSERT INTO users (name, username, password, department, role, phone) VALUES
('Hemant Bansal', 'hemantb', 'faculty123', 'CSE', 'Faculty', '9876543213');
```

## Next Steps

1. ✅ Login UI updated
2. ✅ Authentication logic updated  
3. ✅ Database schema documented
4. 🔲 Test with real database
5. 🔲 Add sample users to database
6. 🔲 Production password hashing