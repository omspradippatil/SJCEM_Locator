# Fresh Database Design - No Relationships

## Complete Database Setup from Scratch

This is a simple database design with no foreign keys or relationships between tables. Each table is independent and standalone.

## Table 1: Students Table

Only students can register themselves. This table stores all student information.

```sql
-- Students table (students can sign up themselves)
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    du_number TEXT UNIQUE NOT NULL, -- e.g., DU1234029
    department TEXT NOT NULL,
    year TEXT NOT NULL, -- 1st Year, 2nd Year, 3rd Year, 4th Year
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add index for faster searches
CREATE INDEX idx_students_du_number ON students(du_number);
CREATE INDEX idx_students_department ON students(department);
```

## Table 2: Faculty Table

Only admin can add faculty members. Faculty cannot register themselves.

```sql
-- Faculty table (admin adds faculty manually)
CREATE TABLE faculty (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL, -- e.g., hemantb
    password TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL,
    designation TEXT, -- Professor, Associate Professor, Assistant Professor
    office_location TEXT,
    cabin_number TEXT,
    specialization TEXT,
    qualification TEXT,
    experience_years INTEGER,
    status TEXT DEFAULT 'Active', -- Active, Inactive
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for faster searches
CREATE INDEX idx_faculty_username ON faculty(username);
CREATE INDEX idx_faculty_department ON faculty(department);
```

## Table 3: HODs Table

Separate table for HODs (Head of Departments). Admin adds HODs manually.

```sql
-- HODs table (admin adds HODs manually)
CREATE TABLE hods (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL, -- e.g., sureshk
    password TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL, -- Which department they head
    office_location TEXT,
    cabin_number TEXT,
    qualification TEXT,
    experience_years INTEGER,
    status TEXT DEFAULT 'Active', -- Active, Inactive
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for faster searches
CREATE INDEX idx_hods_username ON hods(username);
CREATE INDEX idx_hods_department ON hods(department);
```

## Table 4: Timetable Table

Simple timetable without any relationships.

```sql
-- Timetable table (independent)
CREATE TABLE timetable (
    id SERIAL PRIMARY KEY,
    subject TEXT NOT NULL,
    faculty_name TEXT NOT NULL,
    department TEXT NOT NULL,
    year TEXT NOT NULL,
    day TEXT NOT NULL, -- Monday, Tuesday, etc.
    time_slot TEXT NOT NULL, -- 9:00-10:00
    room_number TEXT,
    floor TEXT,
    type TEXT DEFAULT 'Lecture', -- Lecture, Lab, Tutorial
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes
CREATE INDEX idx_timetable_department ON timetable(department);
CREATE INDEX idx_timetable_day ON timetable(day);
```

## Table 5: Campus Locations Table

Store all campus locations independently.

```sql
-- Campus locations table (independent)
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL, -- Room name or facility name
    type TEXT NOT NULL, -- Classroom, Lab, Office, Canteen, Library, etc.
    floor TEXT NOT NULL,
    building TEXT,
    room_number TEXT,
    description TEXT,
    capacity INTEGER,
    status TEXT DEFAULT 'Available', -- Available, Occupied, Maintenance
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes
CREATE INDEX idx_locations_type ON locations(type);
CREATE INDEX idx_locations_floor ON locations(floor);
```

## Sample Data for Testing

### Sample Students (only they can register):
```sql
INSERT INTO students (name, du_number, department, year, phone) VALUES
('Om Pradip Patil', 'DU1234029', 'CSE', '3rd Year', '9876543210'),
('Rahul Sharma', 'DU1234030', 'IT', '2nd Year', '9876543211'),
('Priya Singh', 'DU1234031', 'ECE', '1st Year', '9876543212'),
('Arjun Patel', 'DU1234032', 'MECH', '4th Year', '9876543213'),
('Sneha Gupta', 'DU1234033', 'CIVIL', '2nd Year', '9876543214');
```

### Sample Faculty (admin adds manually):
```sql
INSERT INTO faculty (name, username, password, email, phone, department, designation, office_location, cabin_number, specialization, qualification, experience_years) VALUES
('Hemant Bansal', 'hemantb', 'hemant@123', 'hemant.bansal@sjcem.edu', '9876543215', 'CSE', 'Professor', '3rd Floor', 'C-301', 'Data Structures', 'PhD Computer Science', 10),
('Raj Sharma', 'rajs', 'raj@123', 'raj.sharma@sjcem.edu', '9876543216', 'IT', 'Associate Professor', '2nd Floor', 'I-201', 'Network Security', 'MTech IT', 8),
('Priya Mehta', 'priyam', 'priya@123', 'priya.mehta@sjcem.edu', '9876543217', 'ECE', 'Assistant Professor', '1st Floor', 'E-101', 'Digital Electronics', 'MTech ECE', 5),
('Anil Kumar', 'anilk', 'anil@123', 'anil.kumar@sjcem.edu', '9876543218', 'MECH', 'Professor', 'Ground Floor', 'M-101', 'Thermodynamics', 'PhD Mechanical', 12),
('Sunita Verma', 'sunitav', 'sunita@123', 'sunita.verma@sjcem.edu', '9876543219', 'CIVIL', 'Associate Professor', 'Ground Floor', 'CV-102', 'Structural Engineering', 'MTech Civil', 9);
```

### Sample HODs (admin adds manually):
```sql
INSERT INTO hods (name, username, password, email, phone, department, office_location, cabin_number, qualification, experience_years) VALUES
('Dr. Suresh Kumar', 'sureshk', 'suresh@123', 'suresh.kumar@sjcem.edu', '9876543220', 'CSE', '3rd Floor', 'C-305', 'PhD AI/ML', 15),
('Dr. Anita Verma', 'anitav', 'anita@123', 'anita.verma@sjcem.edu', '9876543221', 'IT', '2nd Floor', 'I-205', 'PhD Database Systems', 12),
('Dr. Rakesh Jain', 'rakeshj', 'rakesh@123', 'rakesh.jain@sjcem.edu', '9876543222', 'ECE', '1st Floor', 'E-105', 'PhD Electronics', 14),
('Dr. Vijay Singh', 'vijays', 'vijay@123', 'vijay.singh@sjcem.edu', '9876543223', 'MECH', 'Ground Floor', 'M-105', 'PhD Mechanical', 16),
('Dr. Renu Sharma', 'renus', 'renu@123', 'renu.sharma@sjcem.edu', '9876543224', 'CIVIL', 'Ground Floor', 'CV-105', 'PhD Civil Engineering', 13);
```

### Sample Timetable:
```sql
INSERT INTO timetable (subject, faculty_name, department, year, day, time_slot, room_number, floor, type) VALUES
('Data Structures', 'Hemant Bansal', 'CSE', '2nd Year', 'Monday', '9:00-10:00', '201', '2nd Floor', 'Lecture'),
('Database Management', 'Anita Verma', 'IT', '3rd Year', 'Monday', '10:00-11:00', '301', '3rd Floor', 'Lecture'),
('Digital Electronics', 'Priya Mehta', 'ECE', '1st Year', 'Monday', '11:00-12:00', '101', '1st Floor', 'Lecture'),
('Thermodynamics', 'Anil Kumar', 'MECH', '2nd Year', 'Monday', '2:00-3:00', 'M-201', 'Ground Floor', 'Lecture'),
('Structural Analysis', 'Sunita Verma', 'CIVIL', '3rd Year', 'Monday', '3:00-4:00', 'CV-301', 'Ground Floor', 'Lecture');
```

### Sample Campus Locations:
```sql
INSERT INTO locations (name, type, floor, building, room_number, description, capacity) VALUES
('Computer Lab 1', 'Lab', '2nd Floor', 'Main Building', 'C-Lab-1', 'Programming Lab with 30 computers', 30),
('Electronics Lab', 'Lab', '1st Floor', 'Main Building', 'E-Lab-1', 'Electronics experiments lab', 25),
('Main Library', 'Library', '1st Floor', 'Library Building', 'LIB-101', 'Central library with study area', 100),
('Canteen', 'Canteen', 'Ground Floor', 'Main Building', 'CAN-01', 'Student dining area', 200),
('Principal Office', 'Office', '3rd Floor', 'Admin Building', 'ADM-301', 'Principal office', 1),
('Auditorium', 'Hall', 'Ground Floor', 'Main Building', 'AUD-01', 'Main auditorium for events', 500);
```

## How the Login System Works

### For Students:
- **Sign Up**: Students can register themselves using the app
- **Login**: Use DU Number only (e.g., "DU1234029") - no password needed
- **Storage**: Data stored in `students` table
- **Self-Service**: Complete autonomy for students

### For Faculty:
- **Sign Up**: NOT ALLOWED - Admin must add them manually
- **Login**: Username + password (e.g., "hemantb" + "hemant@123")
- **Storage**: Data stored in `faculty` table
- **Admin Control**: Only admin can create faculty accounts

### For HODs:
- **Sign Up**: NOT ALLOWED - Admin must add them manually  
- **Login**: Username + password (e.g., "sureshk" + "suresh@123")
- **Storage**: Data stored in `hods` table
- **Admin Control**: Only admin can create HOD accounts

### App Access Control:
- **Students**: Can download app and register immediately
- **Faculty/HOD**: Must contact admin to get access to app

## Authentication Logic

The app will check different tables based on login type:

1. **Student Login**: Check `students` table with `du_number`
2. **Faculty Login**: Check `faculty` table with `username` + `password`
3. **HOD Login**: Check `hods` table with `username` + `password`

## Security Features

1. **No Relationships**: Tables are independent - no cascade issues
2. **Simple Structure**: Easy to understand and maintain
3. **Admin Control**: Faculty/HOD access controlled by admin
4. **Student Freedom**: Students can self-register
5. **Clear Separation**: Different tables for different user types

## Database Setup Instructions

1. **Create all tables** using the SQL commands above
2. **Insert sample data** for testing
3. **No foreign keys** - each table is independent
4. **Admin adds faculty/HODs** manually using INSERT commands
5. **Students register** through the app interface