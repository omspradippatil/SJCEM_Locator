import 'package:flutter/material.dart';

class FacultyScreen extends StatefulWidget {
  const FacultyScreen({super.key});

  @override
  State<FacultyScreen> createState() => _FacultyScreenState();
}

class _FacultyScreenState extends State<FacultyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Faculty> _facultyList = [];
  List<Faculty> _filteredFacultyList = [];

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
    _filteredFacultyList = _facultyList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFacultyData() {
    _facultyList = [
      Faculty(
        name: 'Dr. Rajesh Kumar',
        subject: 'Computer Science',
        department: 'CSE',
        currentLocation: 'Room 301, 3rd Floor',
        isAvailable: true,
        profileImage: 'assets/images/faculty1.jpg',
        phoneNumber: '+91 9876543210',
        email: 'rajesh.kumar@sjcem.ac.in',
      ),
      Faculty(
        name: 'Prof. Priya Sharma',
        subject: 'Mathematics',
        department: 'Applied Sciences',
        currentLocation: 'Room 205, 2nd Floor',
        isAvailable: true,
        profileImage: 'assets/images/faculty2.jpg',
        phoneNumber: '+91 9876543211',
        email: 'priya.sharma@sjcem.ac.in',
      ),
      Faculty(
        name: 'Dr. Amit Patel',
        subject: 'Electronics',
        department: 'ECE',
        currentLocation: 'Lab 4, 2nd Floor',
        isAvailable: false,
        profileImage: 'assets/images/faculty3.jpg',
        phoneNumber: '+91 9876543212',
        email: 'amit.patel@sjcem.ac.in',
      ),
      Faculty(
        name: 'Prof. Neha Gupta',
        subject: 'Mechanical Engineering',
        department: 'MECH',
        currentLocation: 'Workshop, Ground Floor',
        isAvailable: true,
        profileImage: 'assets/images/faculty4.jpg',
        phoneNumber: '+91 9876543213',
        email: 'neha.gupta@sjcem.ac.in',
      ),
      Faculty(
        name: 'Dr. Suresh Reddy',
        subject: 'Civil Engineering',
        department: 'CIVIL',
        currentLocation: 'Room 401, 4th Floor',
        isAvailable: true,
        profileImage: 'assets/images/faculty5.jpg',
        phoneNumber: '+91 9876543214',
        email: 'suresh.reddy@sjcem.ac.in',
      ),
      Faculty(
        name: 'Prof. Kavya Singh',
        subject: 'English',
        department: 'Applied Sciences',
        currentLocation: 'Room 102, 1st Floor',
        isAvailable: false,
        profileImage: 'assets/images/faculty6.jpg',
        phoneNumber: '+91 9876543215',
        email: 'kavya.singh@sjcem.ac.in',
      ),
    ];
    _filteredFacultyList = _facultyList;
  }

  void _filterFaculty(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFacultyList = _facultyList;
      } else {
        _filteredFacultyList = _facultyList
            .where(
              (faculty) =>
                  faculty.name.toLowerCase().contains(query.toLowerCase()) ||
                  faculty.subject.toLowerCase().contains(query.toLowerCase()) ||
                  faculty.department.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void _showFacultyDetails(Faculty faculty) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FacultyDetailsSheet(faculty: faculty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterFaculty,
                  decoration: InputDecoration(
                    hintText: 'Find Faculty by Name, Subject, or Department',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredFacultyList.length} faculty members found',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Faculty List
          Expanded(
            child: _filteredFacultyList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No faculty found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFacultyList.length,
                    itemBuilder: (context, index) {
                      final faculty = _filteredFacultyList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade100,
                            child: faculty.profileImage.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.blue.shade600,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.blue.shade600,
                                  ),
                          ),
                          title: Text(
                            faculty.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                faculty.subject,
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      faculty.currentLocation,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: faculty.isAvailable
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      faculty.isAvailable
                                          ? 'Available'
                                          : 'Busy',
                                      style: TextStyle(
                                        color: faculty.isAvailable
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () =>
                                        _showFacultyDetails(faculty),
                                    icon: Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _showFacultyDetails(faculty),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class Faculty {
  final String name;
  final String subject;
  final String department;
  final String currentLocation;
  final bool isAvailable;
  final String profileImage;
  final String phoneNumber;
  final String email;

  Faculty({
    required this.name,
    required this.subject,
    required this.department,
    required this.currentLocation,
    required this.isAvailable,
    required this.profileImage,
    required this.phoneNumber,
    required this.email,
  });
}

class FacultyDetailsSheet extends StatelessWidget {
  final Faculty faculty;

  const FacultyDetailsSheet({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Profile Section
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 50, color: Colors.blue.shade600),
          ),
          const SizedBox(height: 16),

          Text(
            faculty.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Text(
            faculty.subject,
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Details
          _buildDetailRow(Icons.business, 'Department', faculty.department),
          _buildDetailRow(
            Icons.location_on,
            'Current Location',
            faculty.currentLocation,
          ),
          _buildDetailRow(Icons.phone, 'Phone', faculty.phoneNumber),
          _buildDetailRow(Icons.email, 'Email', faculty.email),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to map with faculty location
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Showing ${faculty.name}\'s location on map',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Show on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle contact action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${faculty.name}...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
