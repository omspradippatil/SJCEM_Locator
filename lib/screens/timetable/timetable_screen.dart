import 'package:flutter/material.dart';
import '../../main.dart'; // To access supabase client

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final String _selectedDay = 'Today';
  String _userRole = 'Student'; // This will come from Supabase
  List<ClassSchedule> _todaySchedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      // Check if user is logged in
      if (!UserSession.isLoggedIn) {
        // Default to Student view for guests
        if (mounted) {
          setState(() {
            _userRole = 'Student';
            _loadTodaySchedule('CSE'); // Default department
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _userRole = UserSession.currentUserRole ?? 'Student';
          _loadTodaySchedule(UserSession.currentDepartment ?? 'CSE');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTodaySchedule(String department) async {
    try {
      final now = DateTime.now();
      final dayOfWeek = now.weekday;
      final dayNames = [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final today = dayNames[dayOfWeek];

      final response = await supabase
          .from('timetable')
          .select('*')
          .eq('department', department)
          .eq('day', today)
          .order('time_slot');

      final List<ClassSchedule> schedule = [];

      for (final cls in response) {
        final timeStr = cls['time_slot'] as String? ?? '';
        final endTime = _getEndTime(timeStr);
        final isCompleted = _isTimeCompleted(endTime);

        schedule.add(
          ClassSchedule(
            subject: cls['subject'] as String? ?? 'Unknown Subject',
            time: cls['time_slot'] as String? ?? 'Time TBD',
            faculty: cls['faculty_name'] as String? ?? 'TBD',
            room: cls['room_number'] as String? ?? 'TBD',
            floor: cls['floor'] as String? ?? 'TBD',
            type: cls['type'] as String? ?? 'Lecture',
            isCompleted: isCompleted,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _todaySchedule = schedule;
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
            content: Text('Error loading schedule: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to get end time from time string (e.g., "9:00 AM - 10:00 AM")
  String _getEndTime(String timeString) {
    try {
      return timeString.split(' - ')[1];
    } catch (e) {
      return '';
    }
  }

  // Helper method to check if a time has passed
  bool _isTimeCompleted(String timeStr) {
    try {
      final now = DateTime.now();
      final timeParts = timeStr.split(':');
      var hour = int.parse(timeParts[0]);
      final minuteSecond = timeParts[1].split(' ');
      final minute = int.parse(minuteSecond[0]);
      final isPM = minuteSecond[1].toUpperCase() == 'PM';

      if (isPM && hour < 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      final classEndTime = DateTime(now.year, now.month, now.day, hour, minute);
      return now.isAfter(classEndTime);
    } catch (e) {
      return false;
    }
  }

  // Rest of the code remains the same with minor adjustments for Supabase
  void _showEditClassDialog(ClassSchedule classSchedule) {
    if (_userRole != 'Faculty' && _userRole != 'HOD') return;

    showDialog(
      context: context,
      builder: (context) => EditClassDialog(
        classSchedule: classSchedule,
        onUpdate: (updatedClass) async {
          try {
            final userId = supabase.auth.currentUser?.id;
            if (userId == null) {
              // Handle case where user is not logged in
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'You must be logged in to perform this action',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            // Update or insert the class in Supabase
            if (classSchedule.subject.isEmpty) {
              // New class
              await supabase.from('timetable').insert({
                'subject': updatedClass.subject,
                'time': updatedClass.time,
                'faculty': updatedClass.faculty,
                'room': updatedClass.room,
                'floor': updatedClass.floor,
                'type': updatedClass.type,
                'created_by': userId,
              });
            } else {
              // Existing class - find and update it
              // For simplicity, we're using a combination of fields to identify the class
              await supabase
                  .from('timetable')
                  .update({
                    'subject': updatedClass.subject,
                    'time': updatedClass.time,
                    'faculty': updatedClass.faculty,
                    'room': updatedClass.room,
                    'floor': updatedClass.floor,
                    'type': updatedClass.type,
                  })
                  .eq('subject', classSchedule.subject)
                  .eq('time', classSchedule.time)
                  .eq('room', classSchedule.room);
            }

            // Reload the schedule
            final userData = await supabase
                .from('users')
                .select('department')
                .eq(
                  'id',
                  userId,
                ) // This is now safe as we checked userId != null
                .single();

            _loadTodaySchedule(userData['department']);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating class: ${e.toString()}'),
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
    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const Spacer(),
                    if (_userRole == 'Faculty')
                      IconButton(
                        onPressed: () {
                          // Add new class
                          _showEditClassDialog(
                            ClassSchedule(
                              subject: '',
                              time: '',
                              faculty: '',
                              room: '',
                              floor: '',
                              type: 'Lecture',
                              isCompleted: false,
                            ),
                          );
                        },
                        icon: Icon(Icons.add, color: Colors.blue.shade600),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Current time: $currentTime',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userRole,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todaySchedule.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No classes scheduled for today',
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
                    itemCount: _todaySchedule.length,
                    itemBuilder: (context, index) {
                      final classSchedule = _todaySchedule[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showEditClassDialog(classSchedule),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(
                                  width: 4,
                                  color: _getClassTypeColor(classSchedule.type),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        classSchedule.subject,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getClassTypeColor(
                                          classSchedule.type,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        classSchedule.type,
                                        style: TextStyle(
                                          color: _getClassTypeColor(
                                            classSchedule.type,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (classSchedule.isCompleted)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      classSchedule.time,
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      classSchedule.faculty,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${classSchedule.room}, ${classSchedule.floor}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_userRole != 'Student')
                                      IconButton(
                                        onPressed: () =>
                                            _showEditClassDialog(classSchedule),
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getClassTypeColor(String type) {
    switch (type) {
      case 'Lecture':
        return Colors.blue;
      case 'Lab':
        return Colors.green;
      case 'Tutorial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class ClassSchedule {
  String subject;
  String time;
  String faculty;
  String room;
  String floor;
  String type;
  bool isCompleted;

  ClassSchedule({
    required this.subject,
    required this.time,
    required this.faculty,
    required this.room,
    required this.floor,
    required this.type,
    required this.isCompleted,
  });
}

class EditClassDialog extends StatefulWidget {
  final ClassSchedule classSchedule;
  final Function(ClassSchedule) onUpdate;

  const EditClassDialog({
    super.key,
    required this.classSchedule,
    required this.onUpdate,
  });

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  late TextEditingController _subjectController;
  late TextEditingController _timeController;
  late TextEditingController _facultyController;
  late TextEditingController _roomController;
  late TextEditingController _floorController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: widget.classSchedule.subject,
    );
    _timeController = TextEditingController(text: widget.classSchedule.time);
    _facultyController = TextEditingController(
      text: widget.classSchedule.faculty,
    );
    _roomController = TextEditingController(text: widget.classSchedule.room);
    _floorController = TextEditingController(text: widget.classSchedule.floor);
    _selectedType = widget.classSchedule.type.isNotEmpty
        ? widget.classSchedule.type
        : 'Lecture';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _timeController.dispose();
    _facultyController.dispose();
    _roomController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _saveClass() {
    final updatedClass = ClassSchedule(
      subject: _subjectController.text,
      time: _timeController.text,
      faculty: _facultyController.text,
      room: _roomController.text,
      floor: _floorController.text,
      type: _selectedType,
      isCompleted: widget.classSchedule.isCompleted,
    );

    widget.onUpdate(updatedClass);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.classSchedule.subject.isEmpty ? 'Add Class' : 'Edit Class',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time (e.g., 9:00 AM - 10:00 AM)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _facultyController,
              decoration: const InputDecoration(
                labelText: 'Faculty',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _floorController,
              decoration: const InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: ['Lecture', 'Lab', 'Tutorial'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveClass, child: const Text('Save')),
      ],
    );
  }
}
