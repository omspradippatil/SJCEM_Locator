import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedDay = 'Today';
  String _userRole = 'Student'; // This would come from authentication
  List<ClassSchedule> _todaySchedule = [];

  @override
  void initState() {
    super.initState();
    _loadTodaySchedule();
  }

  void _loadTodaySchedule() {
    // Mock data for today's schedule
    _todaySchedule = [
      ClassSchedule(
        subject: 'Data Structures',
        time: '9:00 AM - 10:00 AM',
        faculty: 'Dr. Rajesh Kumar',
        room: 'Room 301',
        floor: '3rd Floor',
        type: 'Lecture',
        isCompleted: true,
      ),
      ClassSchedule(
        subject: 'Mathematics',
        time: '10:15 AM - 11:15 AM',
        faculty: 'Prof. Priya Sharma',
        room: 'Room 205',
        floor: '2nd Floor',
        type: 'Lecture',
        isCompleted: true,
      ),
      ClassSchedule(
        subject: 'Computer Networks',
        time: '11:30 AM - 12:30 PM',
        faculty: 'Dr. Amit Patel',
        room: 'Lab 4',
        floor: '2nd Floor',
        type: 'Lab',
        isCompleted: false,
      ),
      ClassSchedule(
        subject: 'Software Engineering',
        time: '2:00 PM - 3:00 PM',
        faculty: 'Prof. Neha Gupta',
        room: 'Room 302',
        floor: '3rd Floor',
        type: 'Lecture',
        isCompleted: false,
      ),
      ClassSchedule(
        subject: 'Database Management',
        time: '3:15 PM - 4:15 PM',
        faculty: 'Dr. Suresh Reddy',
        room: 'Lab 2',
        floor: '2nd Floor',
        type: 'Lab',
        isCompleted: false,
      ),
    ];
  }

  void _showEditClassDialog(ClassSchedule classSchedule) {
    if (_userRole != 'Faculty') return;

    showDialog(
      context: context,
      builder: (context) => EditClassDialog(
        classSchedule: classSchedule,
        onUpdate: (updatedClass) {
          setState(() {
            final index = _todaySchedule.indexOf(classSchedule);
            if (index != -1) {
              _todaySchedule[index] = updatedClass;
            }
          });
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
            child: _todaySchedule.isEmpty
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
              value: _selectedType,
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
