import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import for StreamSubscription

import 'package:sensors_plus/sensors_plus.dart'; // Import sensors_plus

import 'quiz_manager.dart'; // Pastikan quiz_manager.dart ada di lokasi yang sama

class LocationTrackerPage extends StatefulWidget {
  const LocationTrackerPage({super.key});

  @override
  State<LocationTrackerPage> createState() => _LocationTrackerPageState();
}

class _LocationTrackerPageState extends State<LocationTrackerPage> {
  String _currentLocationMessage = 'Mencari lokasi Anda...';
  Position? _currentPosition;
  final TextEditingController _destinationController = TextEditingController();
  String _distanceMessage = '';
  LatLng? _destinationLatLng;
  List<LatLng> _routePolyline = [];
  final MapController _mapController = MapController();
  bool _pickingDestinationFromMap = false;
  bool _isLoadingRoute = false;

  // Quiz related variables
  late QuizManager _quizManager;
  bool _quizMode = false;
  String _quizQuestion = '';
  LatLng? _quizDestinationLatLng;
  String _quizResult = '';

  // Sensor related variables
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  StreamSubscription? _compassSubscription;
  // StreamSubscription? _barometerSubscription; // For Android/iOS (if available)

  double _accelerometerX = 0.0, _accelerometerY = 0.0, _accelerometerZ = 0.0;
  double _gyroscopeX = 0.0, _gyroscopeY = 0.0, _gyroscopeZ = 0.0;
  double? _compassHeading; // In degrees, relative to true north
  // double? _pressureHPa; // In hectopascal (hPa)

  String _sensorMessage = 'Menunggu data sensor...';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _quizManager = QuizManager(
      quizLocations: [
        {'name': 'Monumen Nasional', 'lat': -6.175392, 'lon': 106.827153},
        {'name': 'Candi Borobudur', 'lat': -7.6076, 'lon': 110.2038},
        {'name': 'Gunung Bromo', 'lat': -7.9424, 'lon': 112.9537},
        {'name': 'Danau Toba', 'lat': 2.6841, 'lon': 98.6659},
        {'name': 'Pulau Komodo', 'lat': -8.5668, 'lon': 119.4975},
      ],
      showSnackBar: _showSnackBar,
    );
    _initSensorListeners(); // Initialize sensor listeners
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _quizManager.dispose();
    _cancelSensorListeners(); // Cancel sensor listeners
    super.dispose();
  }

  // --- Fungsi-fungsi Pembantu ---

  void _initSensorListeners() {
    // Akselerometer
    _accelerometerSubscription = accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _accelerometerX = event.x;
          _accelerometerY = event.y;
          _accelerometerZ = event.z;
          _updateSensorMessage();
        });
      }
    }, onError: (e) {
      print("Accelerometer error: $e");
      if (mounted) {
        setState(() {
          _sensorMessage = "Akselerometer tidak tersedia atau error.";
        });
      }
    }, cancelOnError: true);

    // Giroskop
    _gyroscopeSubscription = gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroscopeX = event.x;
          _gyroscopeY = event.y;
          _gyroscopeZ = event.z;
          _updateSensorMessage();
        });
      }
    }, onError: (e) {
      print("Gyroscope error: $e");
      if (mounted) {
        setState(() {
          _sensorMessage = "Giroskop tidak tersedia atau error.";
        });
      }
    }, cancelOnError: true);

    // Magnetometer (Kompas)
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          _compassHeading = event.heading;
          _updateSensorMessage();
        });
      }
    }, onError: (e) {
      print("Compass error: $e");
      if (mounted) {
        setState(() {
          _sensorMessage = "Kompas tidak tersedia atau error.";
        });
      }
    });

    // Barometer (Pressure & Altitude) - Uncomment if you want to use it and have the sensor
    // _barometerSubscription = barometerEventStream().listen((BarometerEvent event) {
    //   if (mounted) {
    //     setState(() {
    //       _pressureHPa = event.pressure;
    //       _updateSensorMessage();
    //     });
    //   }
    // }, onError: (e) {
    //   print("Barometer error: $e");
    //   if (mounted) {
    //     setState(() {
    //       _sensorMessage = "Barometer tidak tersedia atau error.";
    //     });
    //   }
    // });
  }

  void _cancelSensorListeners() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _compassSubscription?.cancel();
    // _barometerSubscription?.cancel(); // Uncomment if used
  }

  void _updateSensorMessage() {
    String accel = 'Aksel: X:${_accelerometerX.toStringAsFixed(2)}, Y:${_accelerometerY.toStringAsFixed(2)}, Z:${_accelerometerZ.toStringAsFixed(2)}';
    String gyro = 'Giro: X:${_gyroscopeX.toStringAsFixed(2)}, Y:${_gyroscopeY.toStringAsFixed(2)}, Z:${_gyroscopeZ.toStringAsFixed(2)}';
    String compass = _compassHeading != null ? 'Kompas: ${_compassHeading!.toStringAsFixed(0)}°' : 'Kompas: N/A';
    String altitude = _currentPosition?.altitude != null ? 'Alt: ${_currentPosition!.altitude.toStringAsFixed(1)}m' : 'Alt: N/A';
    // String pressure = _pressureHPa != null ? 'Tekanan: ${_pressureHPa!.toStringAsFixed(1)}hPa' : 'Tekanan: N/A';

    setState(() {
      _sensorMessage = '$accel\n$gyro\n$compass\n$altitude'; // Add pressure if used: \n$pressure';
    });
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _currentLocationMessage = 'Izin lokasi ditolak.';
            _currentPosition = null;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _currentLocationMessage =
              'Izin lokasi ditolak secara permanen. Mohon berikan izin di pengaturan aplikasi.';
          _currentPosition = null;
        });
      }
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _currentLocationMessage = 'Mencari lokasi Anda...';
      _currentPosition = null;
      _routePolyline.clear();
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentLocationMessage =
              'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
          _updateSensorMessage(); // Update sensor message with new altitude
        });
        _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
          _currentPosition = null;
        });
      }
      print('Error getting location: $e');
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng latlng) async {
    if (_pickingDestinationFromMap) {
      setState(() {
        _destinationLatLng = latlng;
        _pickingDestinationFromMap = false;
        _routePolyline.clear();
      });
      _showSnackBar('Lokasi tujuan dipilih dari peta!');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _calculateStraightLineDistance() async {
    if (_currentPosition == null) {
      _showSnackBar('Mohon dapatkan lokasi Anda saat ini terlebih dahulu.');
      return;
    }

    if (_destinationLatLng == null && _destinationController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan alamat tujuan atau pilih di peta.');
      return;
    }

    setState(() {
      _distanceMessage = 'Menghitung jarak garis lurus...';
      _routePolyline.clear();
    });

    try {
      if (_destinationLatLng == null) {
        List<Location> locations = await locationFromAddress(_destinationController.text.trim());
        if (locations.isNotEmpty) {
          _destinationLatLng = LatLng(locations[0].latitude, locations[0].longitude);
        } else {
          if (mounted) {
            setState(() {
              _distanceMessage = 'Alamat tujuan tidak ditemukan.';
            });
          }
          return;
        }
      }

      final distance = const Distance();
      double meters = distance(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _destinationLatLng!,
      );

      double km = meters / 1000;

      if (mounted) {
        setState(() {
          _distanceMessage =
              'Jarak Garis Lurus: ${km.toStringAsFixed(2)} km\n'
              '(Tujuan Lat: ${_destinationLatLng!.latitude.toStringAsFixed(6)}, Long: ${_destinationLatLng!.longitude.toStringAsFixed(6)})';
          _mapController.move(
            LatLng(
              (_currentPosition!.latitude + _destinationLatLng!.latitude) / 2,
              (_currentPosition!.longitude + _destinationLatLng!.longitude) / 2,
            ),
            _mapController.camera.zoom > 10 ? 10.0 : _mapController.camera.zoom,
          );
        });
      }
    } catch (e) {
      print('Error calculating straight line distance: $e');
      if (mounted) {
        setState(() {
          _distanceMessage = 'Gagal menghitung jarak garis lurus: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _calculateActualRoute() async {
    if (_currentPosition == null) {
      _showSnackBar('Mohon dapatkan lokasi Anda saat ini terlebih dahulu.');
      return;
    }

    if (_destinationLatLng == null && _destinationController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan alamat tujuan atau pilih di peta.');
      return;
    }

    setState(() {
      _distanceMessage = 'Menghitung jarak rute dan waktu tempuh...';
      _isLoadingRoute = true;
      _routePolyline.clear();
    });

    try {
      if (_destinationLatLng == null) {
        List<Location> locations = await locationFromAddress(_destinationController.text.trim());
        if (locations.isNotEmpty) {
          _destinationLatLng = LatLng(locations[0].latitude, locations[0].longitude);
        } else {
          if (mounted) {
            setState(() {
              _distanceMessage = 'Alamat tujuan tidak ditemukan untuk rute.';
              _isLoadingRoute = false;
            });
          }
          return;
        }
      }

      final startLat = _currentPosition!.latitude;
      final startLon = _currentPosition!.longitude;
      final endLat = _destinationLatLng!.latitude;
      final endLon = _destinationLatLng!.longitude;

      final url = Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final double routeDistanceMeters = data['routes'][0]['distance'];
          final double routeDurationSeconds = data['routes'][0]['duration'];
          final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

          final double routeDistanceKm = routeDistanceMeters / 1000;
          final int hours = (routeDurationSeconds / 3600).floor();
          final int minutes = ((routeDurationSeconds % 3600) / 60).floor();

          List<LatLng> decodedPolyline = [];
          for (var coord in coordinates) {
            decodedPolyline.add(LatLng(coord[1], coord[0]));
          }

          if (mounted) {
            setState(() {
              _distanceMessage =
                  'Jarak Rute: ${routeDistanceKm.toStringAsFixed(2)} km\n'
                  'Estimasi Waktu: ${hours > 0 ? '${hours} jam ' : ''}${minutes} menit\n'
                  '(Tujuan Lat: ${_destinationLatLng!.latitude.toStringAsFixed(6)}, Long: ${_destinationLatLng!.longitude.toStringAsFixed(6)})';
              _routePolyline = decodedPolyline;
              _isLoadingRoute = false;

              if (_currentPosition != null && _destinationLatLng != null) {
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: LatLngBounds(
                      LatLng(startLat, startLon),
                      LatLng(endLat, endLon),
                    ),
                    padding: const EdgeInsets.all(50),
                  ),
                );
              }
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _distanceMessage = 'Tidak dapat menemukan rute ke tujuan.';
              _isLoadingRoute = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _distanceMessage = 'Gagal mengambil data rute: ${response.statusCode}. Silakan coba lagi.';
            _isLoadingRoute = false;
          });
        }
      }
    } catch (e) {
      print('Error calculating route distance: $e');
      if (mounted) {
        setState(() {
          _distanceMessage = 'Terjadi kesalahan saat menghitung rute: ${e.toString()}';
          _isLoadingRoute = false;
        });
      }
    }
  }

  void _startQuiz() {
    if (_currentPosition == null) {
      _showSnackBar('Mohon dapatkan lokasi Anda saat ini terlebih dahulu sebelum memulai kuis.');
      return;
    }

    setState(() {
      _quizMode = true;
      _quizResult = '';
      _quizManager.resetQuizState();
      _routePolyline.clear();

      final newQuizState = _quizManager.startNewQuiz(_currentPosition!);
      _quizQuestion = newQuizState['question'];
      _quizDestinationLatLng = newQuizState['destinationLatLng'];
      _destinationController.text = newQuizState['destinationName'];

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            _quizDestinationLatLng!,
          ),
          padding: const EdgeInsets.all(50),
        ),
      );
    });
    _showSnackBar('Kuis dimulai! Tebak jaraknya.');
  }

  void _submitQuizAnswer() {
    final result = _quizManager.submitAnswer();
    setState(() {
      _quizResult = result.message;
      print('Hasil Kuis: $_quizResult'); // Debugging
      _quizMode = false;
      _destinationLatLng = null;
      _destinationController.clear();
    });
  }

  void _cancelQuiz() {
    setState(() {
      _quizMode = false;
      _quizQuestion = '';
      _quizDestinationLatLng = null;
      _quizResult = '';
      _destinationController.clear();
      _destinationLatLng = null;
      _routePolyline.clear();
      _distanceMessage = '';
      _quizManager.resetQuizState();
    });
    _showSnackBar('Kuis dibatalkan.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelacak Lokasi & Jarak'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent], // Subtle gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 8, // Add a subtle shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Rounded bottom corners for app bar
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2, // Memberikan 2/3 ruang untuk peta
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(-7.7000, 110.6000), // Default to Central Java
                initialZoom: 10.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: _handleMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app', // Ensure this is appropriate
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () =>
                          launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    )
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(
                            _currentPosition!.latitude, _currentPosition!.longitude),
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 45,
                        ),
                      ),
                    if (_destinationLatLng != null && !_quizMode)
                      Marker(
                        point: _destinationLatLng!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 45,
                        ),
                      ),
                    if (_quizMode && _quizDestinationLatLng != null)
                      Marker(
                        point: _quizDestinationLatLng!,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.help_outline, // Changed icon for quiz destination
                          color: Colors.orange,
                          size: 45,
                        ),
                      ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePolyline,
                      strokeWidth: 5.0,
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bagian di bawah ini akan di-scroll
          Expanded(
            flex: 3, // Memberikan 3/5 ruang untuk konten yang bisa di-scroll
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Location & Sensor Data Card
                  Card(
                    elevation: 6, // Slightly more elevation
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // More rounded
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0), // More padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Anda Saat Ini:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _currentPosition == null
                              ? const Center(child: CircularProgressIndicator())
                              : Text(
                                  _currentLocationMessage,
                                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                                ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.my_location),
                              label: const Text('Perbarui Lokasi Saya'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent.shade700, // Darker shade of blue
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14), // Larger padding
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // More rounded
                                elevation: 5, // Button elevation
                              ),
                            ),
                          ),
                          const Divider(height: 40, thickness: 1.5, color: Colors.grey), // Thicker divider
                          const Text(
                            'Data Sensor:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _sensorMessage,
                            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quiz Feature Card
                  Card(
                    elevation: 6, // Slightly more elevation
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // More rounded
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0), // More padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fitur Kuis Lokasi:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!_quizMode)
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _startQuiz,
                                icon: const Icon(Icons.quiz),
                                label: const Text('Mulai Kuis Jarak'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.shade700, // Darker orange
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14), // Larger padding
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // More rounded
                                  elevation: 5,
                                ),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _quizQuestion,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black87),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _quizManager.quizAnswerController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Masukkan perkiraan jarak (km)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.deepOrange.shade300), // Border color hint
                                    ),
                                    enabledBorder: OutlineInputBorder( // Custom enabled border
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.deepOrange.shade300, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder( // Custom focused border
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.deepOrange.shade700, width: 2.0),
                                    ),
                                    prefixIcon: const Icon(Icons.numbers, color: Colors.deepOrange),
                                    filled: true,
                                    fillColor: Colors.deepOrange.shade50, // Light fill color
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _submitQuizAnswer,
                                        icon: const Icon(Icons.check),
                                        label: const Text('Jawab'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade700, // Darker green
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _cancelQuiz,
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Batal Kuis'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey.shade400, // Softer grey
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _quizResult,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    color: _quizResult.contains('Selamat') ? Colors.green.shade700 : Colors.red.shade700, // Dynamic color based on result
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Calculate Distance Card (only visible when not in quiz mode)
                  if (!_quizMode)
                    Card(
                      elevation: 6, // Slightly more elevation
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // More rounded
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // More padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hitung Jarak ke Lokasi Lain:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _destinationController,
                              decoration: InputDecoration(
                                labelText: _pickingDestinationFromMap
                                    ? 'Ketuk di peta untuk memilih tujuan...'
                                    : 'Masukkan Alamat Tujuan (contoh: Monas, Jakarta)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.blue.shade300), // Border color hint
                                ),
                                enabledBorder: OutlineInputBorder( // Custom enabled border
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.blue.shade300, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder( // Custom focused border
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
                                ),
                                prefixIcon: const Icon(Icons.location_on, color: Colors.blue), // Icon for input
                                filled: true,
                                fillColor: Colors.blue.shade50, // Light fill color
                                suffixIcon: _pickingDestinationFromMap
                                    ? IconButton(
                                        icon: const Icon(Icons.cancel),
                                        onPressed: () {
                                          setState(() {
                                            _pickingDestinationFromMap = false;
                                          });
                                          _showSnackBar('Pemilihan tujuan dari peta dibatalkan.');
                                        },
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickingDestinationFromMap
                                        ? null // Disable if currently picking
                                        : () {
                                            setState(() {
                                              _pickingDestinationFromMap = true;
                                              _showSnackBar('Ketuk di peta untuk memilih tujuan.');
                                            });
                                          },
                                    icon: const Icon(Icons.map),
                                    label: const Text('Pilih dari Peta'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo.shade700, // Deep indigo
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoadingRoute ? null : _calculateStraightLineDistance,
                                    icon: const Icon(Icons.straighten),
                                    label: const Text('Jarak Garis Lurus'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade700, // Vibrant orange
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _isLoadingRoute ? null : _calculateActualRoute,
                              icon: _isLoadingRoute
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.alt_route),
                              label: Text(_isLoadingRoute ? 'Menghitung Rute...' : 'Hitung Rute Sebenarnya'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700, // Rich purple
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _distanceMessage,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black87),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}