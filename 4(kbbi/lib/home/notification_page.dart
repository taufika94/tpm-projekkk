import 'package:app/home/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key}); // Added const constructor

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getStringList('notifications') ?? [];
    });
  }

  Future<void> _clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    setState(() {
      _notifications = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige, // Scaffold background from palette
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.white), // White font for AppBar title
        ),
        backgroundColor: AppColors.primaryDarkBlue, // AppBar color from palette
        iconTheme: const IconThemeData(color: Colors.white), // White icons for AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearNotifications,
            color: Colors.white, // White icon for delete button
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Text(
                'Tidak ada notifikasi.',
                style: TextStyle(color: AppColors.primaryDarkBlue, fontSize: 16), // Text color from palette
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return Card( // Use Card for a better visual separation of notifications
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 2.0,
                  color: AppColors.lightBeige, // Card background color
                  child: ListTile(
                    title: Text(
                      _notifications[index],
                      style: TextStyle(color: AppColors.primaryDarkBlue), // Text color from palette
                    ),
                    // You can add more styling or content to the ListTile if needed
                  ),
                );
              },
            ),
    );
  }
}