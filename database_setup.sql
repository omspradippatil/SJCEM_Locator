-- =====================================================
-- SJCEM Navigator Database Setup - Complete from Scratch
-- =====================================================
-- Drop existing tables if they exist (careful in production!)
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS faculty CASCADE;
DROP TABLE IF EXISTS hods CASCADE;
DROP TABLE IF EXISTS timetable CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS faculty_availability CASCADE;

-- =====================================================
-- Table 1: Students (Students can self-register)
-- =====================================================
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    du_number TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL DEFAULT 'CSE',
    year TEXT NOT NULL DEFAULT '1st Year',
    phone TEXT DEFAULT '',
    email TEXT DEFAULT '',
    profile_image_url TEXT DEFAULT '',
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Table 2: Faculty (Admin adds manually)
-- =====================================================
CREATE TABLE faculty (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    department TEXT NOT NULL DEFAULT 'CSE',
    designation TEXT DEFAULT 'Assistant Professor',
    office_location TEXT DEFAULT '',
    cabin_number TEXT DEFAULT '',
    specialization TEXT DEFAULT '',
    qualification TEXT DEFAULT '',
    experience_years INTEGER DEFAULT 0,
    profile_image_url TEXT DEFAULT '',
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Table 3: HODs (Admin adds manually)
-- =====================================================
CREATE TABLE hods (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    department TEXT NOT NULL DEFAULT 'CSE',
    office_location TEXT DEFAULT '',
    cabin_number TEXT DEFAULT '',
    qualification TEXT DEFAULT '',
    experience_years INTEGER DEFAULT 0,
    profile_image_url TEXT DEFAULT '',
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Table 4: Faculty Availability (For real-time tracking)
-- =====================================================
CREATE TABLE faculty_availability (
    id SERIAL PRIMARY KEY,
    faculty_username TEXT NOT NULL,
    current_location TEXT DEFAULT 'Office',
    is_available BOOLEAN DEFAULT true,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Table 5: Timetable (Independent)
-- =====================================================
CREATE TABLE timetable (
    id SERIAL PRIMARY KEY,
    subject TEXT NOT NULL DEFAULT '',
    faculty_name TEXT NOT NULL DEFAULT '',
    department TEXT NOT NULL DEFAULT 'CSE',
    year TEXT NOT NULL DEFAULT '1st Year',
    day TEXT NOT NULL DEFAULT 'Monday',
    time_slot TEXT NOT NULL DEFAULT '9:00-10:00',
    room_number TEXT DEFAULT '',
    floor TEXT DEFAULT 'Ground Floor',
    type TEXT DEFAULT 'Lecture',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Table 6: Campus Locations (Independent)
-- =====================================================
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    type TEXT NOT NULL DEFAULT 'Classroom',
    floor TEXT NOT NULL DEFAULT 'Ground Floor',
    building TEXT DEFAULT 'Main Building',
    room_number TEXT DEFAULT '',
    description TEXT DEFAULT '',
    capacity INTEGER DEFAULT 0,
    image_url TEXT DEFAULT '',
    status TEXT DEFAULT 'Available',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Create Indexes for Better Performance
-- =====================================================
CREATE INDEX idx_students_du_number ON students(du_number);
CREATE INDEX idx_students_department ON students(department);
CREATE INDEX idx_faculty_username ON faculty(username);
CREATE INDEX idx_faculty_department ON faculty(department);
CREATE INDEX idx_hods_username ON hods(username);
CREATE INDEX idx_hods_department ON hods(department);
CREATE INDEX idx_timetable_department ON timetable(department);
CREATE INDEX idx_timetable_day ON timetable(day);
CREATE INDEX idx_locations_type ON locations(type);
CREATE INDEX idx_locations_floor ON locations(floor);
CREATE INDEX idx_faculty_availability_username ON faculty_availability(faculty_username);

-- =====================================================
-- Insert Sample Data for Testing
-- =====================================================

-- Sample Students
INSERT INTO students (name, du_number, department, year, phone, email) VALUES
('Om Pradip Patil', 'DU1234029', 'CSE', '3rd Year', '9876543210', 'om@student.sjcem.edu'),
('Rahul Sharma', 'DU1234030', 'IT', '2nd Year', '9876543211', 'rahul@student.sjcem.edu'),
('Priya Singh', 'DU1234031', 'ECE', '1st Year', '9876543212', 'priya@student.sjcem.edu'),
('Arjun Patel', 'DU1234032', 'MECH', '4th Year', '9876543213', 'arjun@student.sjcem.edu'),
('Sneha Gupta', 'DU1234033', 'CIVIL', '2nd Year', '9876543214', 'sneha@student.sjcem.edu');

-- Sample Faculty
INSERT INTO faculty (name, username, password, email, phone, department, designation, office_location, cabin_number, specialization, qualification, experience_years) VALUES
('Hemant Bansal', 'hemantb', 'hemant@123', 'hemant.bansal@sjcem.edu', '9876543215', 'CSE', 'Professor', '3rd Floor', 'C-301', 'Data Structures', 'PhD Computer Science', 10),
('Raj Sharma', 'rajs', 'raj@123', 'raj.sharma@sjcem.edu', '9876543216', 'IT', 'Associate Professor', '2nd Floor', 'I-201', 'Network Security', 'MTech IT', 8),
('Priya Mehta', 'priyam', 'priya@123', 'priya.mehta@sjcem.edu', '9876543217', 'ECE', 'Assistant Professor', '1st Floor', 'E-101', 'Digital Electronics', 'MTech ECE', 5),
('Anil Kumar', 'anilk', 'anil@123', 'anil.kumar@sjcem.edu', '9876543218', 'MECH', 'Professor', 'Ground Floor', 'M-101', 'Thermodynamics', 'PhD Mechanical', 12),
('Sunita Verma', 'sunitav', 'sunita@123', 'sunita.verma@sjcem.edu', '9876543219', 'CIVIL', 'Associate Professor', 'Ground Floor', 'CV-102', 'Structural Engineering', 'MTech Civil', 9);

-- Sample HODs
INSERT INTO hods (name, username, password, email, phone, department, office_location, cabin_number, qualification, experience_years) VALUES
('Dr. Suresh Kumar', 'sureshk', 'suresh@123', 'suresh.kumar@sjcem.edu', '9876543220', 'CSE', '3rd Floor', 'C-305', 'PhD AI/ML', 15),
('Dr. Anita Verma', 'anitav', 'anita@123', 'anita.verma@sjcem.edu', '9876543221', 'IT', '2nd Floor', 'I-205', 'PhD Database Systems', 12),
('Dr. Rakesh Jain', 'rakeshj', 'rakesh@123', 'rakesh.jain@sjcem.edu', '9876543222', 'ECE', '1st Floor', 'E-105', 'PhD Electronics', 14),
('Dr. Vijay Singh', 'vijays', 'vijay@123', 'vijay.singh@sjcem.edu', '9876543223', 'MECH', 'Ground Floor', 'M-105', 'PhD Mechanical', 16),
('Dr. Renu Sharma', 'renus', 'renu@123', 'renu.sharma@sjcem.edu', '9876543224', 'CIVIL', 'Ground Floor', 'CV-105', 'PhD Civil Engineering', 13);

-- Faculty Availability
INSERT INTO faculty_availability (faculty_username, current_location, is_available) VALUES
('hemantb', 'C-301', true),
('rajs', 'I-201', true),
('priyam', 'E-101', false),
('anilk', 'M-101', true),
('sunitav', 'CV-102', true);

-- Sample Timetable
INSERT INTO timetable (subject, faculty_name, department, year, day, time_slot, room_number, floor, type) VALUES
('Data Structures', 'Hemant Bansal', 'CSE', '2nd Year', 'Monday', '9:00-10:00', '201', '2nd Floor', 'Lecture'),
('Database Management', 'Anita Verma', 'IT', '3rd Year', 'Monday', '10:00-11:00', '301', '3rd Floor', 'Lecture'),
('Digital Electronics', 'Priya Mehta', 'ECE', '1st Year', 'Monday', '11:00-12:00', '101', '1st Floor', 'Lecture'),
('Thermodynamics', 'Anil Kumar', 'MECH', '2nd Year', 'Monday', '2:00-3:00', 'M-201', 'Ground Floor', 'Lecture'),
('Structural Analysis', 'Sunita Verma', 'CIVIL', '3rd Year', 'Monday', '3:00-4:00', 'CV-301', 'Ground Floor', 'Lecture'),
('Algorithms', 'Hemant Bansal', 'CSE', '3rd Year', 'Tuesday', '9:00-10:00', '201', '2nd Floor', 'Lecture'),
('Operating Systems', 'Raj Sharma', 'IT', '2nd Year', 'Tuesday', '10:00-11:00', '202', '2nd Floor', 'Lecture'),
('Programming Lab', 'Hemant Bansal', 'CSE', '2nd Year', 'Wednesday', '2:00-5:00', 'C-Lab-1', '2nd Floor', 'Lab');

-- Sample Campus Locations
INSERT INTO locations (name, type, floor, building, room_number, description, capacity) VALUES
('Computer Lab 1', 'Lab', '2nd Floor', 'Main Building', 'C-Lab-1', 'Programming Lab with 30 computers', 30),
('Computer Lab 2', 'Lab', '2nd Floor', 'Main Building', 'C-Lab-2', 'Advanced programming and projects lab', 30),
('Electronics Lab', 'Lab', '1st Floor', 'Main Building', 'E-Lab-1', 'Electronics experiments lab', 25),
('Physics Lab', 'Lab', '1st Floor', 'Main Building', 'P-Lab-1', 'Physics practical lab', 25),
('Main Library', 'Library', '1st Floor', 'Library Building', 'LIB-101', 'Central library with study area', 100),
('Digital Library', 'Library', '2nd Floor', 'Library Building', 'LIB-201', 'Computer-based learning center', 50),
('Canteen', 'Canteen', 'Ground Floor', 'Main Building', 'CAN-01', 'Student dining area', 200),
('Cafeteria', 'Canteen', 'Ground Floor', 'Main Building', 'CAN-02', 'Quick snacks and beverages', 50),
('Principal Office', 'Office', '3rd Floor', 'Admin Building', 'ADM-301', 'Principal office', 1),
('CSE HOD Office', 'Office', '3rd Floor', 'Main Building', 'C-305', 'Computer Science Department Head', 1),
('IT HOD Office', 'Office', '2nd Floor', 'Main Building', 'I-205', 'Information Technology Department Head', 1),
('Auditorium', 'Hall', 'Ground Floor', 'Main Building', 'AUD-01', 'Main auditorium for events', 500),
('Seminar Hall 1', 'Hall', '2nd Floor', 'Main Building', 'SEM-201', 'Seminar and workshop hall', 100),
('Conference Room', 'Hall', '3rd Floor', 'Admin Building', 'CONF-301', 'Faculty meetings and conferences', 30),
('Classroom 201', 'Classroom', '2nd Floor', 'Main Building', '201', 'Regular classroom with projector', 60),
('Classroom 301', 'Classroom', '3rd Floor', 'Main Building', '301', 'Regular classroom with smart board', 60),
('Sports Ground', 'Sports', 'Ground Floor', 'Campus', 'SPORTS-01', 'Outdoor sports facilities', 200),
('Gymnasium', 'Sports', 'Ground Floor', 'Sports Complex', 'GYM-01', 'Indoor fitness center', 40);

-- =====================================================
-- Enable Row Level Security (Optional but Recommended)
-- =====================================================
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;
ALTER TABLE hods ENABLE ROW LEVEL SECURITY;
ALTER TABLE timetable ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculty_availability ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access (no authentication needed)
CREATE POLICY "Allow public read access to students" ON students FOR SELECT USING (true);
CREATE POLICY "Allow public read access to faculty" ON faculty FOR SELECT USING (true);
CREATE POLICY "Allow public read access to hods" ON hods FOR SELECT USING (true);
CREATE POLICY "Allow public read access to timetable" ON timetable FOR SELECT USING (true);
CREATE POLICY "Allow public read access to locations" ON locations FOR SELECT USING (true);
CREATE POLICY "Allow public read access to faculty_availability" ON faculty_availability FOR SELECT USING (true);

-- Allow insert for students (self-registration)
CREATE POLICY "Allow public insert to students" ON students FOR INSERT WITH CHECK (true);

-- =====================================================
-- Verification Queries
-- =====================================================
-- Uncomment to verify data after setup:
-- SELECT COUNT(*) as student_count FROM students;
-- SELECT COUNT(*) as faculty_count FROM faculty;
-- SELECT COUNT(*) as hod_count FROM hods;
-- SELECT COUNT(*) as timetable_count FROM timetable;
-- SELECT COUNT(*) as location_count FROM locations;
