// lib/profile/profile_page.dart
import 'package:app/home/app_colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige, // Warna latar belakang dari palet
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white), // Warna teks putih untuk judul AppBar
        ),
        backgroundColor: AppColors.primaryDarkBlue, // Warna AppBar dari palet
        iconTheme: const IconThemeData(color: Colors.white), // Warna ikon AppBar putih
      ),
      body: Center(
        child: SingleChildScrollView( // Tambahkan SingleChildScrollView agar bisa discroll jika konten melebihi layar
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 60, // Perbesar sedikit radius agar gambar lebih menonjol
                backgroundColor: AppColors.primaryTeal, // Warna latar belakang default CircleAvatar
                // Ganti dengan AssetImage jika gambar lokal, atau NetworkImage untuk URL
                // Pastikan path gambar 'assets/taufika_kasuh.jpg' sudah benar dan dideklarasikan di pubspec.yaml
                backgroundImage: const AssetImage('assets/taufika_kasuh.jpg'),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading profile image: $exception');
                  // Anda bisa menambahkan logika fallback di sini, misalnya:
                  // Jika gambar tidak berhasil dimuat, Anda bisa menampilkan ikon default
                  // Caranya:
                  // Jika ini StatefulWidget, Anda bisa set state isImageError = true
                  // Lalu di build, jika isImageError, tampilkan child: Icon(Icons.person)
                },
                // Untuk menampilkan fallback icon jika gambar tidak tersedia atau gagal dimuat
                child: Image.asset(
                  'assets/taufika_kasuh.jpg', // Coba muat gambar
                  fit: BoxFit.cover,
                  width: 120, // Sesuaikan dengan radius * 2
                  height: 120, // Sesuaikan dengan radius * 2
                  errorBuilder: (context, error, stackTrace) {
                    // Ini akan ditampilkan jika AssetImage gagal dimuat
                    return Icon(
                      Icons.person,
                      size: 60, // Sesuaikan dengan radius
                      color: AppColors.lightBeige, // Warna ikon fallback
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Taufika Retno Wulan',
                style: TextStyle(
                  fontSize: 24, // Perbesar ukuran font
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue, // Warna teks dari palet
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '123220196',
                style: TextStyle(
                  fontSize: 18, // Perbesar ukuran font
                  color: AppColors.darkReddishBrown, // Warna teks dari palet
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'IF - C',
                style: TextStyle(
                  fontSize: 18, // Perbesar ukuran font
                  color: AppColors.darkReddishBrown, // Warna teks dari palet
                ),
              ),
              const SizedBox(height: 30), 
      
            ],
          ),
        ),
      ),
    );
  }
}