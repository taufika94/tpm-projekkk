// lib/profile/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              // Pastikan path ini ('assets/taufika_kasuh.jpg')
              // cocok dengan lokasi file dan deklarasi di pubspec.yaml
              backgroundImage: const AssetImage('assets/taufika_kasuh.jpg'),
              onBackgroundImageError: (exception, stackTrace) {
                // Callback ini adalah 'void', jadi tidak bisa mengembalikan widget.
                // Ini hanya untuk logging atau efek samping lainnya.
                debugPrint('Error loading image: $exception');
                // Hapus baris 'return' ini karena menyebabkan error:
                // return const Text('Gambar gagal dimuat');
              },
              // Jika Anda ingin menampilkan sesuatu di dalam CircleAvatar
              // ketika gambar tidak ada atau gagal dimuat, Anda bisa menggunakan
              // properti 'child' dari CircleAvatar, yang akan tertutup jika
              // 'backgroundImage' berhasil dimuat.
              // Contoh:
              // child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Taufika Retno Wulan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '123220196',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'IF - C',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}