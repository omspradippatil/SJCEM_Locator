import 'package:flutter/material.dart';
import '../../main.dart'; // To access supabase client

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      if (!UserSession.isLoggedIn) {
        // Show login prompt
        if (mounted) {
          _showLoginRequired();
        }
        return;
      }

      final role = UserSession.currentUserRole;
      final userId = UserSession.currentUserId;

      if (userId == null || role == null) {
        if (mounted) {
          _showLoginRequired();
        }
        return;
      }

      Map<String, dynamic>? userData;

      if (role == 'Student') {
        userData = await supabase
            .from('students')
            .select('*')
            .eq('du_number', userId)
            .maybeSingle();
      } else if (role == 'Faculty') {
        userData = await supabase
            .from('faculty')
            .select('*')
            .eq('username', userId)
            .maybeSingle();
      } else if (role == 'HOD') {
        userData = await supabase
            .from('hods')
            .select('*')
            .eq('username', userId)
            .maybeSingle();
      }

      if (userData == null) {
        if (mounted) {
          _showLoginRequired();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _userProfile = UserProfile(
            name: (userData?['name'] as String?) ?? 'Unknown',
            id: userId,
            email: (userData?['email'] as String?) ?? 'N/A',
            department: (userData?['department'] as String?) ?? 'N/A',
            year: role == 'Student'
                ? ((userData?['year'] as String?) ?? 'N/A')
                : '',
            role: role,
            phone: (userData?['phone'] as String?) ?? 'N/A',
            profileImage: (userData?['profile_image_url'] as String?) ?? '',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoginRequired() {
    setState(() {
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to view your profile.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UserSession.clearSession();
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    if (_userProfile == null) return;

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        userProfile: _userProfile!,
        onUpdate: (updatedProfile) async {
          try {
            final role = UserSession.currentUserRole;
            final userId = UserSession.currentUserId;
            
            if (userId == null || role == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must be logged in to update your profile'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            // Update in the appropriate table based on role
            if (role == 'Student') {
              await supabase
                  .from('students')
                  .update({
                    'name': updatedProfile.name,
                    'email': updatedProfile.email,
                    'phone': updatedProfile.phone,
                  })
                  .eq('du_number', userId);
            } else if (role == 'Faculty') {
              await supabase
                  .from('faculty')
                  .update({
                    'name': updatedProfile.name,
                    'email': updatedProfile.email,
                    'phone': updatedProfile.phone,
                  })
                  .eq('username', userId);
            } else if (role == 'HOD') {
              await supabase
                  .from('hods')
                  .update({
                    'name': updatedProfile.name,
                    'email': updatedProfile.email,
                    'phone': updatedProfile.phone,
                  })
                  .eq('username', userId);
            }

            if (mounted) {
              setState(() {
                _userProfile = updatedProfile;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating profile: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading profile'),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: _userProfile!.profileImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(55),
                                child: Image.network(
                                  _userProfile!.profileImage,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Colors.blue.shade100,
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            // Handle profile picture upload to Supabase storage
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile picture upload feature coming soon',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and ID
                  Text(
                    _userProfile!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile!.id,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _userProfile!.role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Information Cards
                  _buildInfoCard('Personal Information', [
                    _buildInfoRow(Icons.email, 'Email', _userProfile!.email),
                    _buildInfoRow(Icons.phone, 'Phone', _userProfile!.phone),
                    _buildInfoRow(
                      Icons.business,
                      'Department',
                      _userProfile!.department,
                    ),
                    if (_userProfile!.role == 'Student')
                      _buildInfoRow(Icons.school, 'Year', _userProfile!.year),
                  ]),

                  const SizedBox(height: 16),

                  _buildInfoCard('Quick Actions', [
                    _buildActionRow(
                      Icons.notifications,
                      'Notifications',
                      'Manage your notification preferences',
                      () {
                        // Handle notifications
                      },
                    ),
                    _buildActionRow(
                      Icons.help,
                      'Help & Support',
                      'Get help or contact support',
                      () {
                        // Handle help
                      },
                    ),
                    _buildActionRow(
                      Icons.info,
                      'About',
                      'App version and information',
                      () {
                        _showAboutDialog();
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'SJCEM Navigator',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.school,
        size: 50,
        color: Colors.blue.shade600,
      ),
      children: [
        const Text('College Campus Navigation App'),
        const SizedBox(height: 8),
        const Text('Developed for SJCEM College'),
        const Text('© 2024 All rights reserved'),
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
