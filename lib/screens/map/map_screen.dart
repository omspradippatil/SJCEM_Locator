import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  double _currentHeading = 0.0;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;

  // SJCEM Campus coordinates (approximate)
  final LatLng _campusCenter = const LatLng(19.0760, 72.8777);

  final List<Marker> _buildingMarkers = [];
  final List<Marker> _facultyMarkers = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _createBuildingMarkers();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 17.0);
    } else {
      _mapController.move(_campusCenter, 16.0);
    }
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Permission.location.request();
    if (permission.isDenied) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Use a logging framework instead of print in production
      debugPrint('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    setState(() {
      _isTracking = true;
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update every 1 meter
      ),
    ).listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentHeading = position.heading;
      });

      // Auto-center map on user location
      _mapController.move(_currentLocation!, _mapController.camera.zoom);
    });
  }

  void _stopLocationTracking() {
    setState(() {
      _isTracking = false;
    });
    _positionStream?.cancel();
  }

  void _createBuildingMarkers() {
    // Sample building locations on SJCEM campus
    final buildings = [
      {
        'name': 'Main Building',
        'lat': 19.0760,
        'lng': 72.8777,
        'type': 'administrative'
      },
      {
        'name': 'CSE Department',
        'lat': 19.0765,
        'lng': 72.8780,
        'type': 'academic'
      },
      {
        'name': 'IT Department',
        'lat': 19.0762,
        'lng': 72.8785,
        'type': 'academic'
      },
      {
        'name': 'ECE Department',
        'lat': 19.0758,
        'lng': 72.8775,
        'type': 'academic'
      },
      {'name': 'Library', 'lat': 19.0755, 'lng': 72.8782, 'type': 'facility'},
      {'name': 'Canteen', 'lat': 19.0768, 'lng': 72.8772, 'type': 'facility'},
      {
        'name': 'Auditorium',
        'lat': 19.0752,
        'lng': 72.8778,
        'type': 'facility'
      },
      {
        'name': 'Sports Complex',
        'lat': 19.0770,
        'lng': 72.8785,
        'type': 'facility'
      },
    ];

    for (final building in buildings) {
      _buildingMarkers.add(
        Marker(
          point: LatLng(building['lat'] as double, building['lng'] as double),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showBuildingInfo(building),
            child: Container(
              decoration: BoxDecoration(
                color: _getBuildingColor(building['type'] as String),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getBuildingIcon(building['type'] as String),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }
  }

  Color _getBuildingColor(String type) {
    switch (type) {
      case 'academic':
        return Colors.blue;
      case 'administrative':
        return Colors.red;
      case 'facility':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getBuildingIcon(String type) {
    switch (type) {
      case 'academic':
        return Icons.school;
      case 'administrative':
        return Icons.business;
      case 'facility':
        return Icons.place;
      default:
        return Icons.location_on;
    }
  }

  void _showBuildingInfo(Map<String, dynamic> building) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(building['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type: ${building['type']}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToLocation(
                  LatLng(building['lat'] as double, building['lng'] as double),
                );
              },
              child: const Text('Navigate Here'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToLocation(LatLng destination) {
    _mapController.move(destination, 18.0);

    // Show navigation path (simplified)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Navigating to ${destination.latitude.toStringAsFixed(4)}, ${destination.longitude.toStringAsFixed(4)}',
        ),
        action: SnackBarAction(
          label: 'Stop',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _campusCenter,
              initialZoom: 16.0,
              minZoom: 10.0,
              maxZoom: 20.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sjcem.navigator',
              ),
              MarkerLayer(markers: _buildingMarkers),
              MarkerLayer(markers: _facultyMarkers),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 30,
                      height: 30,
                      child: Transform.rotate(
                        angle: _currentHeading * (math.pi / 180),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Control Panel
          Positioned(
            top: 50,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "location",
                  mini: true,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "tracking",
                  mini: true,
                  backgroundColor: _isTracking ? Colors.red : Colors.blue,
                  onPressed: _isTracking
                      ? _stopLocationTracking
                      : _startLocationTracking,
                  child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                ),
              ],
            ),
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 16,
            right: 80,
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search buildings, rooms...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          // Implement search functionality
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Building Legend
          Positioned(
            bottom: 100,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Legend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.blue, Icons.school, 'Academic'),
                    _buildLegendItem(
                        Colors.red, Icons.business, 'Administrative'),
                    _buildLegendItem(Colors.green, Icons.place, 'Facilities'),
                    _buildLegendItem(
                        Colors.red, Icons.navigation, 'Your Location'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 10),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
