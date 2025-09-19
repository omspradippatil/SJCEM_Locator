# Admin Management Guide

## Quick Database Setup

Copy and paste these commands in your Supabase SQL Editor to set up the complete database:

### Step 1: Create All Tables

```sql
-- Students table (students can register themselves)
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    du_number TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    year TEXT NOT NULL,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Faculty table (admin adds manually)
CREATE TABLE faculty (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL,
    designation TEXT,
    office_location TEXT,
    cabin_number TEXT,
    specialization TEXT,
    qualification TEXT,
    experience_years INTEGER,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- HODs table (admin adds manually)
CREATE TABLE hods (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL,
    office_location TEXT,
    cabin_number TEXT,
    qualification TEXT,
    experience_years INTEGER,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Timetable table
CREATE TABLE timetable (
    id SERIAL PRIMARY KEY,
    subject TEXT NOT NULL,
    faculty_name TEXT NOT NULL,
    department TEXT NOT NULL,
    year TEXT NOT NULL,
    day TEXT NOT NULL,
    time_slot TEXT NOT NULL,
    room_number TEXT,
    floor TEXT,
    type TEXT DEFAULT 'Lecture',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Campus locations table
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    floor TEXT NOT NULL,
    building TEXT,
    room_number TEXT,
    description TEXT,
    capacity INTEGER,
    status TEXT DEFAULT 'Available',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_students_du_number ON students(du_number);
CREATE INDEX idx_faculty_username ON faculty(username);
CREATE INDEX idx_hods_username ON hods(username);
CREATE INDEX idx_timetable_department ON timetable(department);
CREATE INDEX idx_locations_type ON locations(type);
```

### Step 2: Add Sample Data

```sql
-- Sample Students
INSERT INTO students (name, du_number, department, year, phone) VALUES
('Om Pradip Patil', 'DU1234029', 'CSE', '3rd Year', '9876543210'),
('Rahul Sharma', 'DU1234030', 'IT', '2nd Year', '9876543211'),
('Priya Singh', 'DU1234031', 'ECE', '1st Year', '9876543212');

-- Sample Faculty
INSERT INTO faculty (name, username, password, email, phone, department, designation, office_location, cabin_number, specialization, qualification, experience_years) VALUES
('Hemant Bansal', 'hemantb', 'hemant@123', 'hemant@sjcem.edu', '9876543215', 'CSE', 'Professor', '3rd Floor', 'C-301', 'Data Structures', 'PhD Computer Science', 10),
('Raj Sharma', 'rajs', 'raj@123', 'raj@sjcem.edu', '9876543216', 'IT', 'Associate Professor', '2nd Floor', 'I-201', 'Network Security', 'MTech IT', 8);

-- Sample HODs
INSERT INTO hods (name, username, password, email, phone, department, office_location, cabin_number, qualification, experience_years) VALUES
('Dr. Suresh Kumar', 'sureshk', 'suresh@123', 'suresh@sjcem.edu', '9876543220', 'CSE', '3rd Floor', 'C-305', 'PhD AI/ML', 15),
('Dr. Anita Verma', 'anitav', 'anita@123', 'anita@sjcem.edu', '9876543221', 'IT', '2nd Floor', 'I-205', 'PhD Database Systems', 12);
```

## Adding New Faculty Members

Use this template to add new faculty:

```sql
INSERT INTO faculty (name, username, password, email, phone, department, designation, office_location, cabin_number, specialization, qualification, experience_years) VALUES
('Faculty Name', 'username', 'password123', 'email@sjcem.edu', 'phone', 'Department', 'Designation', 'Office Location', 'Cabin', 'Specialization', 'Qualification', years);
```

## Adding New HODs

Use this template to add new HODs:

```sql
INSERT INTO hods (name, username, password, email, phone, department, office_location, cabin_number, qualification, experience_years) VALUES
('HOD Name', 'username', 'password123', 'email@sjcem.edu', 'phone', 'Department', 'Office Location', 'Cabin', 'Qualification', years);
```

## Quick Tests

After setup, test these logins:

### Student Login:
- DU Number: `DU1234029`
- No password needed

### Faculty Login:
- Username: `hemantb`
- Password: `hemant@123`

### HOD Login:
- Username: `sureshk`
- Password: `suresh@123`

## Important Notes

1. **No Relationships**: All tables are independent
2. **Students Self-Register**: They can sign up via the app
3. **Faculty/HOD Manual**: You must add them manually
4. **Simple Passwords**: Change them to secure ones in production
5. **Username Format**: firstname + first letter of lastname (e.g., hemantb)

## Managing Users

### View all students:
```sql
SELECT * FROM students ORDER BY created_at DESC;
```

### View all faculty:
```sql
SELECT * FROM faculty ORDER BY created_at DESC;
```

### Update faculty password:
```sql
UPDATE faculty SET password = 'new_password' WHERE username = 'hemantb';
```

### Remove faculty:
```sql
DELETE FROM faculty WHERE username = 'old_username';
```