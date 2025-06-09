// app/home/home_page.dart

import 'package:app/home/app_colors.dart';
import 'package:app/home/feeback_page.dart';
import 'package:app/home/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/kbbi/entry_list_page.dart';
import 'package:app/Currency_Converter/CurrencyConverterPage.dart';
import 'package:app/time_converter/time_converter_page.dart';
import 'package:app/jarak/location_tracker_page.dart';
import 'package:app/home/notification_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _username = '';

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _widgetOptions = <Widget>[
      _buildHomeContent(),
      const ProfilePage(),
      const FeedbackPage(),
    ];
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Pengguna';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selamat datang, $_username!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkBlue), // Changed text color
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Anda telah berhasil masuk dan berada di halaman utama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryDarkBlue), // Changed text color
            ),
            const SizedBox(height: 40),
            _buildFeatureButton(
              context,
              'Mulai Cari Kata KBBI',
              const EntryListPage(),
              AppColors.primaryTeal, // Button color from palette
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              'Konversi Mata Uang',
              const CurrencyConverterPage(),
              AppColors.accentOrange, // Button color from palette
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              'Konversi Waktu (WIB/WITA/WIT)',
              const TimeConverterPage(),
              AppColors.darkReddishBrown, // Button color from palette
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              'Lacak Lokasi & Hitung Jarak',
              const LocationTrackerPage(),
              AppColors.primaryDarkBlue, // Button color from palette
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              'Tampilkan Notifikasi',
              NotificationPage(),
              AppColors.primaryTeal, // Button color from palette
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create consistent styled buttons
  Widget _buildFeatureButton(BuildContext context, String text, Widget page, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color, // Dynamic background color
        foregroundColor: Colors.white, // White font for colored buttons
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige, // Scaffold background from palette
      appBar: AppBar(
        title: const Text(
          'KBBI App',
          style: TextStyle(color: Colors.white), // White font for AppBar title
        ),
        backgroundColor: AppColors.primaryDarkBlue, // AppBar color from palette
        iconTheme: const IconThemeData(color: Colors.white), // White icons for AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
            color: Colors.white, // White icon for logout
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Saran & Kesan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.accentOrange, // Selected item color from palette
        unselectedItemColor: Colors.white70, // Unselected item color
        backgroundColor: AppColors.primaryDarkBlue, // Bottom nav bar background from palette
        onTap: _onItemTapped,
      ),
    );
  }
}