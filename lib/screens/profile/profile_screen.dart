import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userRole = '';
  String _userName = '';
  String _userDepartment = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userYear = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      setState(() {
        _userRole = prefs.getString('user_role') ?? '';
        _userName = prefs.getString('user_name') ?? '';
        _userDepartment = prefs.getString('user_department') ?? '';
      });

      if (userId != null && _userRole != 'Guest') {
        final response =
            await supabase.from('users').select().eq('id', userId).single();

        setState(() {
          _userName = response['name'] ?? '';
          _userEmail = response['email'] ?? '';
          _userPhone = response['phone'] ?? '';
          _userDepartment = response['department'] ?? '';
          _userYear = response['year'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showAddFacultyDialog() {
    if (_userRole != 'HOD' && _userRole != 'Faculty') return;

    showDialog(
      context: context,
      builder: (context) => AddFacultyDialog(
        userDepartment: _userDepartment,
        userRole: _userRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade600,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName.isNotEmpty ? _userName : 'Guest User',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userRole,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Details
            if (_userRole != 'Guest') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.email, 'Email', _userEmail),
                      _buildInfoRow(Icons.phone, 'Phone', _userPhone),
                      _buildInfoRow(
                          Icons.business, 'Department', _userDepartment),
                      if (_userRole == 'Student')
                        _buildInfoRow(Icons.school, 'Year', _userYear),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Admin Actions (for HOD and Faculty)
            if (_userRole == 'HOD' || _userRole == 'Faculty') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Actions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('Add Faculty'),
                        subtitle: Text(
                            'Add new faculty to $_userDepartment department'),
                        onTap: _showAddFacultyDialog,
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Manage Timetable'),
                        subtitle: const Text('Edit class schedules'),
                        onTap: () {
                          Navigator.pushNamed(context, '/timetable');
                        },
                      ),
                      if (_userRole == 'HOD')
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings),
                          title: const Text('Department Management'),
                          subtitle: const Text('Manage department settings'),
                          onTap: () {
                            // Navigate to department management
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFacultyDialog extends StatefulWidget {
  final String userDepartment;
  final String userRole;

  const AddFacultyDialog({
    super.key,
    required this.userDepartment,
    required this.userRole,
  });

  @override
  State<AddFacultyDialog> createState() => _AddFacultyDialogState();
}

class _AddFacultyDialogState extends State<AddFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'Faculty';
  String _selectedDepartment = '';
  bool _isLoading = false;

  final List<String> _roles = ['Faculty'];
  final List<String> _departments = [
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.userDepartment;
    if (widget.userRole == 'HOD') {
      _roles.add('HOD');
    }
  }

  Future<void> _addFaculty() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String userId =
            'FC${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        await supabase.from('users').insert({
          'name': _nameController.text.trim(),
          'user_id': userId,
          'email': _emailController.text.trim(),
          'role': _selectedRole,
          'department': _selectedDepartment,
          'phone': _phoneController.text.trim(),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faculty added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Faculty'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                items: _departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                onChanged: widget.userRole == 'HOD'
                    ? (value) {
                        setState(() {
                          _selectedDepartment = value!;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addFaculty,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Faculty'),
        ),
      ],
    );
  }
}

class UserProfile {
  final String name;
  final String id;
  final String email;
  final String department;
  final String year;
  final String role;
  final String phone;
  final String profileImage;

  UserProfile({
    required this.name,
    required this.id,
    required this.email,
    required this.department,
    required this.year,
    required this.role,
    required this.phone,
    required this.profileImage,
  });
}

class EditProfileDialog extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdate;

  const EditProfileDialog({
    super.key,
    required this.userProfile,
    required this.onUpdate,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedProfile = UserProfile(
      name: _nameController.text,
      id: widget.userProfile.id,
      email: _emailController.text,
      department: widget.userProfile.department,
      year: widget.userProfile.year,
      role: widget.userProfile.role,
      phone: _phoneController.text,
      profileImage: widget.userProfile.profileImage,
    );

    widget.onUpdate(updatedProfile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveProfile, child: const Text('Save')),
      ],
    );
  }
}
