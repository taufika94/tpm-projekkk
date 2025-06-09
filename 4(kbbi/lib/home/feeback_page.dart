// lib/feedback/feedback_page.dart
import 'package:app/home/app_colors.dart';
import 'package:flutter/material.dart';


class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige, // Scaffold background from palette
      appBar: AppBar(
        title: const Text(
          'Saran & Kesan Mata Kuliah',
          style: TextStyle(color: Colors.white), // White font for AppBar title
        ),
        backgroundColor: AppColors.primaryDarkBlue, // AppBar color from palette
        iconTheme: const IconThemeData(color: Colors.white), // White icons for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Berikan saran dan kesan Anda mengenai mata kuliah Teknologi dan Pemrograman Mobile:',
              style: TextStyle(fontSize: 16, color: AppColors.primaryDarkBlue), // Text color from palette
            ),
            const SizedBox(height: 10),
            Text(
              'Kesan saya mengenai mata kuliah Teknologi Pemrograman Mobile adalah seru!',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppColors.primaryTeal, // Text color from palette
                fontWeight: FontWeight.bold, // Added bold for emphasis
              ),
            ),
          ],
        ),
      ),
    );
  }
}