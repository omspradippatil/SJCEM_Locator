import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  String _currentFloor = 'Ground';
  bool _isNavigating = false;
  late AnimationController _pulseController;
  late AnimationController _pathController;

  final List<String> _floors = ['Ground', '1st', '2nd', '3rd', '4th'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  void _navigateToRoom(String roomName) {
    setState(() {
      _isNavigating = true;
    });
    _pathController.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $roomName...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Floor Selection
          Container(
            height: 60,
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _floors.map((floor) {
                final isSelected = floor == _currentFloor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentFloor = floor;
                      _isNavigating = false;
                    });
                    _pathController.reset();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade600
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      floor,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Map Area
          Expanded(
            child: Stack(
              children: [
                // Map Background
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade200, Colors.grey.shade100],
                    ),
                  ),
                  child: CustomPaint(
                    painter: FloorPlanPainter(
                      floor: _currentFloor,
                      isNavigating: _isNavigating,
                      pathAnimation: _pathController,
                    ),
                  ),
                ),

                // You Are Here Indicator
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.3,
                  top: MediaQuery.of(context).size.height * 0.4,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.3),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // You Are Here Label
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.15,
                  top: MediaQuery.of(context).size.height * 0.45,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'You are here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Room Labels (Interactive)
                _buildRoomLabels(),
              ],
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRoom('Library'),
                        icon: const Icon(Icons.library_books),
                        label: const Text('Library'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRoom('Canteen'),
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Canteen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRoom('Principal Office'),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Principal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRoom('Washroom'),
                        icon: const Icon(Icons.wc),
                        label: const Text('Washroom'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomLabels() {
    final rooms = _getRoomsForFloor(_currentFloor);

    return Stack(
      children: rooms.map((room) {
        return Positioned(
          left: room.x,
          top: room.y,
          child: GestureDetector(
            onTap: () => _navigateToRoom(room.name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                room.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<RoomData> _getRoomsForFloor(String floor) {
    switch (floor) {
      case 'Ground':
        return [
          RoomData('101', 100, 150),
          RoomData('102', 200, 150),
          RoomData('Library', 150, 250),
          RoomData('Canteen', 250, 300),
        ];
      case '1st':
        return [
          RoomData('201', 100, 150),
          RoomData('202', 200, 150),
          RoomData('Lab-1', 150, 250),
          RoomData('Lab-2', 250, 200),
        ];
      case '2nd':
        return [
          RoomData('301', 100, 150),
          RoomData('302', 200, 150),
          RoomData('Computer Lab', 150, 250),
          RoomData('Electronics Lab', 250, 200),
        ];
      case '3rd':
        return [
          RoomData('401', 100, 150),
          RoomData('402', 200, 150),
          RoomData('Principal Office', 150, 250),
          RoomData('HOD Office', 250, 200),
        ];
      case '4th':
        return [
          RoomData('501', 100, 150),
          RoomData('502', 200, 150),
          RoomData('Conference Room', 150, 250),
          RoomData('Staff Room', 250, 200),
        ];
      default:
        return [];
    }
  }
}

class RoomData {
  final String name;
  final double x;
  final double y;

  RoomData(this.name, this.x, this.y);
}

class FloorPlanPainter extends CustomPainter {
  final String floor;
  final bool isNavigating;
  final AnimationController pathAnimation;

  FloorPlanPainter({
    required this.floor,
    required this.isNavigating,
    required this.pathAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw basic floor plan outline
    final rect = Rect.fromLTWH(50, 100, size.width - 100, size.height - 200);
    canvas.drawRect(rect, paint);

    // Draw rooms
    final roomPaint = Paint()
      ..color = Colors.blue.shade100
      ..style = PaintingStyle.fill;

    final roomStroke = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw sample rooms
    final rooms = [
      Rect.fromLTWH(80, 130, 80, 60),
      Rect.fromLTWH(180, 130, 80, 60),
      Rect.fromLTWH(280, 130, 80, 60),
      Rect.fromLTWH(130, 220, 100, 80),
      Rect.fromLTWH(250, 220, 100, 80),
    ];

    for (final room in rooms) {
      canvas.drawRect(room, roomPaint);
      canvas.drawRect(room, roomStroke);
    }

    // Draw navigation path if navigating
    if (isNavigating) {
      final pathPaint = Paint()
        ..color = Colors.green.shade600
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(size.width * 0.3, size.height * 0.4);
      path.lineTo(size.width * 0.5, size.height * 0.4);
      path.lineTo(size.width * 0.5, size.height * 0.6);
      path.lineTo(size.width * 0.7, size.height * 0.6);

      final pathMetrics = path.computeMetrics();
      final pathMetric = pathMetrics.first;
      final extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * pathAnimation.value,
      );

      canvas.drawPath(extractPath, pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
