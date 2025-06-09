// lib/feedback/feedback_page.dart
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget { // Mengubah menjadi StatelessWidget karena tidak ada state yang berubah
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Kesan Mata Kuliah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Berikan saran dan kesan Anda mengenai mata kuliah Teknologi dan Pemrograman Mobile:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Mengganti TextField dengan Text widget biasa
            const Text(
              'Kesan saya mengenai mata kuliah Teknologi Pemrograman Mobile adalah seru!',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.blueGrey),
            ),
            // SizedBox dan ElevatedButton tidak lagi diperlukan karena tidak ada input
            // Jika Anda ingin mempertahankan ruang kosong, SizedBox bisa tetap ada
            // const SizedBox(height: 20),
            // ElevatedButton tidak ada lagi
          ],
        ),
      ),
    );
  }
}