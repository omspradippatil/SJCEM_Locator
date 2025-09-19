import 'package:flutter/material.dart';
import '../../main.dart'; // To access supabase client

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _duNumberController = TextEditingController(); // For students
  final _usernameController = TextEditingController(); // For faculty
  final _passwordController = TextEditingController(); // For faculty only
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();

  String _selectedRole = 'Student';
  String _selectedDepartment = 'CSE';
  String _selectedYear = '1st Year';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;

  final List<String> _roles = [
    'Student',
    'Faculty',
    'HOD',
  ]; // All roles for login
  final List<String> _signUpRoles = ['Student']; // Only students can sign up
  final List<String> _departments = [
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'MECH',
    'CIVIL',
  ];
  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void dispose() {
    _duNumberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (_selectedRole == 'Student') {
          // For students, check DU number in students table
          final duNumber = _duNumberController.text.trim().toUpperCase();

          final studentData = await supabase
              .from('students')
              .select('*')
              .eq('du_number', duNumber)
              .maybeSingle();

          if (studentData == null) {
            setState(() {
              _errorMessage =
                  'DU number not found. Please contact administrator.';
              _isLoading = false;
            });
            return;
          }

          // Student found, navigate to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (_selectedRole == 'Faculty') {
          // For Faculty, check username and password in faculty table
          final username = _usernameController.text.trim().toLowerCase();
          final password = _passwordController.text;

          final facultyData = await supabase
              .from('faculty')
              .select('*')
              .eq('username', username)
              .eq('password', password)
              .maybeSingle();

          if (facultyData == null) {
            setState(() {
              _errorMessage = 'Invalid username or password for Faculty.';
              _isLoading = false;
            });
            return;
          }

          // Faculty login successful, navigate to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (_selectedRole == 'HOD') {
          // For HOD, check username and password in hods table
          final username = _usernameController.text.trim().toLowerCase();
          final password = _passwordController.text;

          final hodData = await supabase
              .from('hods')
              .select('*')
              .eq('username', username)
              .eq('password', password)
              .maybeSingle();

          if (hodData == null) {
            setState(() {
              _errorMessage = 'Invalid username or password for HOD.';
              _isLoading = false;
            });
            return;
          }

          // HOD login successful, navigate to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Sign-up is only for students
        // Faculty accounts must be manually created by admin

        Map<String, dynamic> studentData = {
          'name': _nameController.text.trim(),
          'du_number': _studentIdController.text.trim(),
          'department': _selectedDepartment,
          'year': _selectedYear,
          'phone': _phoneController.text.trim(),
        };

        await supabase.from('students').insert(studentData);

        // Success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Student account created successfully! You can now sign in with your DU number.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Switch back to sign in mode
          setState(() {
            _isSignUp = false;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // College Logo
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'SJCEM Navigator',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Campus Navigation Made Easy',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign in/up toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = false;
                                // Reset to Student when switching to login (all roles available)
                                if (!_roles.contains(_selectedRole)) {
                                  _selectedRole = 'Student';
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isSignUp
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade200,
                              foregroundColor: !_isSignUp
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              elevation: !_isSignUp ? 2 : 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Sign In'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = true;
                                // Force Student role for sign-up (only students can sign up)
                                _selectedRole = 'Student';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSignUp
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade200,
                              foregroundColor: _isSignUp
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              elevation: _isSignUp ? 2 : 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Sign Up'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Error message if any
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Form Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSignUp ? 'Create Account' : 'Login as:',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),

                            // Role Selection
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              items: (_isSignUp ? _signUpRoles : _roles).map((
                                role,
                              ) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Sign Up specific fields
                            if (_isSignUp) ...[
                              // Name Field
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Student/Faculty ID Field
                              TextFormField(
                                controller: _studentIdController,
                                decoration: InputDecoration(
                                  labelText: _selectedRole == 'Student'
                                      ? 'Student ID'
                                      : 'Faculty ID',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.badge),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Department Selection
                              DropdownButtonFormField<String>(
                                initialValue: _selectedDepartment,
                                decoration: const InputDecoration(
                                  labelText: 'Department',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.business),
                                ),
                                items: _departments.map((dept) {
                                  return DropdownMenuItem(
                                    value: dept,
                                    child: Text(dept),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Year Selection (only for students)
                              if (_selectedRole == 'Student')
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedYear,
                                  decoration: const InputDecoration(
                                    labelText: 'Year',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.school),
                                  ),
                                  items: _years.map((year) {
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text(year),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedYear = value!;
                                    });
                                  },
                                ),
                              if (_selectedRole == 'Student')
                                const SizedBox(height: 16),

                              // Phone Field
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Login Fields based on role
                            if (!_isSignUp) ...[
                              if (_selectedRole == 'Student') ...[
                                // DU Number field for students
                                TextFormField(
                                  controller: _duNumberController,
                                  decoration: const InputDecoration(
                                    labelText: 'DU Number (e.g., DU1234029)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your DU number';
                                    }
                                    if (!RegExp(
                                      r'^DU\d{7}$',
                                    ).hasMatch(value.toUpperCase())) {
                                      return 'Please enter a valid DU number (e.g., DU1234029)';
                                    }
                                    return null;
                                  },
                                ),
                              ] else ...[
                                // Username field for faculty/HOD
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Username (e.g., hemantb)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password field for faculty/HOD
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],

                            const SizedBox(height: 24),

                            // Sign In/Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : (_isSignUp ? _signUp : _signIn),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      )
                                    : Text(
                                        _isSignUp
                                            ? 'Create Account'
                                            : 'Sign In',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Admin for Faculty (instead of forgot password)
                    if (!_isSignUp && _selectedRole != 'Student')
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Need Help?'),
                              content: const Text(
                                'For password reset or any issues, please contact the administrator.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'Need Help?',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
