# Faculty Management Guide

## Adding Faculty Members Manually

Since faculty members cannot sign up themselves, you'll need to add them manually to the `faculty` table in your Supabase database.

### Method 1: Using Supabase SQL Editor

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Use this template to add new faculty:

```sql
INSERT INTO faculty (
    name, 
    username, 
    password, 
    email, 
    phone, 
    department, 
    designation, 
    role, 
    office_location, 
    cabin_number, 
    specialization, 
    qualification, 
    experience_years
) VALUES (
    'Faculty Full Name',
    'username',     -- e.g., 'hemantb' for Hemant Bansal
    'password123',  -- Set a default password
    'email@sjcem.edu',
    '9876543210',
    'CSE',          -- Department: CSE, IT, ECE, EEE, MECH, CIVIL
    'Professor',    -- Designation: Professor, Associate Professor, Assistant Professor
    'Faculty',      -- Role: Faculty or HOD
    '3rd Floor',    -- Office location
    'C-301',        -- Cabin number
    'Data Structures & Algorithms',  -- Specialization
    'PhD in Computer Science',       -- Qualification
    10              -- Years of experience
);
```

### Method 2: Bulk Import via CSV

Create a CSV file with faculty data and import it using Supabase's table editor.

### Username Generation Rules

For consistency, generate usernames using this format:
- First name + first letter of last name (all lowercase)
- Examples:
  - "Hemant Bansal" → "hemantb"
  - "Dr. Suresh Kumar" → "sureshk"
  - "Priya Mehta" → "priyam"

### Sample Faculty Data

Here are some examples you can copy-paste:

```sql
-- HODs
INSERT INTO faculty (name, username, password, email, phone, department, designation, role, office_location, cabin_number, specialization, qualification, experience_years) VALUES
('Dr. Suresh Kumar', 'sureshk', 'hod@123', 'suresh.kumar@sjcem.edu', '9876543215', 'CSE', 'HOD', 'HOD', '3rd Floor', 'C-305', 'Machine Learning', 'PhD in AI/ML', 15),
('Dr. Anita Verma', 'anitav', 'hod@123', 'anita.verma@sjcem.edu', '9876543217', 'IT', 'HOD', 'HOD', '2nd Floor', 'I-205', 'Database Management', 'PhD in Computer Applications', 12);

-- Regular Faculty
INSERT INTO faculty (name, username, password, email, phone, department, designation, role, office_location, cabin_number, specialization, qualification, experience_years) VALUES
('Hemant Bansal', 'hemantb', 'faculty@123', 'hemant.bansal@sjcem.edu', '9876543213', 'CSE', 'Professor', 'Faculty', '3rd Floor', 'C-301', 'Data Structures & Algorithms', 'PhD in Computer Science', 10),
('Raj Sharma', 'rajs', 'faculty@123', 'raj.sharma@sjcem.edu', '9876543214', 'IT', 'Associate Professor', 'Faculty', '2nd Floor', 'I-201', 'Network Security', 'MTech in IT', 8),
('Priya Mehta', 'priyam', 'faculty@123', 'priya.mehta@sjcem.edu', '9876543216', 'ECE', 'Assistant Professor', 'Faculty', '1st Floor', 'E-101', 'Digital Electronics', 'MTech in ECE', 5);
```

## Password Security

⚠️ **Important**: In production, you should:
1. Use strong, unique passwords for each faculty member
2. Hash passwords using bcrypt or similar
3. Force faculty to change passwords on first login
4. Implement password reset functionality

## Testing Faculty Login

After adding faculty members, test their login with:
- Username: `hemantb`
- Password: `faculty@123`
- Role: `Faculty`

## Managing Faculty

To update faculty information:
```sql
UPDATE faculty 
SET password = 'new_password', availability_status = 'Available'
WHERE username = 'hemantb';
```

To remove faculty:
```sql
DELETE FROM faculty WHERE username = 'old_username';
```