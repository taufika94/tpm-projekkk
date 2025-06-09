// main.dart atau kbbi_app.dart (sesuaikan nama file Anda)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import semua halaman yang dibutuhkan
import 'package:app/auth/auth_page.dart';
import 'package:app/auth/register_page.dart';
import 'package:app/home/home_page.dart';
import 'package:app/kbbi/entry_list_page.dart';
import 'package:app/kbbi/entry_detail_page.dart';
import 'package:app/kbbi/favorites_pages.dart';
import 'package:app/kbbi/database/kbbi_entry.dart';
import 'package:app/Currency_Converter/CurrencyConverterPage.dart';
import 'package:app/time_converter/time_converter_page.dart';
import 'package:app/jarak/location_tracker_page.dart'; // Jangan lupa import ini jika digunakan di routes

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive (database lokal)
  await Hive.initFlutter();
  Hive.registerAdapter(KbbiEntryAdapter());
  Hive.registerAdapter(ArtiAdapter());

  runApp(const KbbiApp());
}

class KbbiApp extends StatefulWidget {
  const KbbiApp({super.key});

  @override
  State<KbbiApp> createState() => _KbbiAppState();
}

class _KbbiAppState extends State<KbbiApp> {
  // Gunakan FutureBuilder untuk menangani status loading asinkron
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Mengembalikan true jika token ada dan tidak kosong, menandakan sudah login
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading screen saat memeriksa status login
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Memuat sesi...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Tangani jika ada error saat memuat sesi
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          // Setelah status login diketahui
          final bool isLoggedIn = snapshot.data ?? false; // Ambil hasil dari Future

          return MaterialApp(
            title: 'KBBI App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            // Tentukan halaman awal berdasarkan status login
            home: isLoggedIn ? const HomePage() : const AuthPage(),
            routes: {
              '/login': (context) => const AuthPage(),
              '/register': (context) => const RegisterPage(),
              '/home': (context) => const HomePage(),
              '/kbbi_list': (context) => const EntryListPage(),
              '/favorites': (context) => const FavoritesPage(),
              '/currency_converter': (context) => const CurrencyConverterPage(),
              '/time_converter': (context) => const TimeConverterPage(),
              // Tambahkan rute untuk LocationTrackerPage
              '/location_tracker': (context) => const LocationTrackerPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/kbbi_detail') {
                final entry = settings.arguments as KbbiEntry;
                return MaterialPageRoute(
                  builder: (context) => EntryDetailPage(entry: entry),
                );
              }
              return null;
            },
          );
        }
      },
    );
  }
}