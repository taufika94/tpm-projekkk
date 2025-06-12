import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Untuk mengontrol visibilitas password

  final String _baseUrl = 'https://be-rest-928661779459.us-central1.run.app'; // Sesuaikan dengan URL server Node.js Anda

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', _usernameController.text);

        if (mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      } else {
        final errorData = json.decode(response.body);
        _showSnackBar(errorData['message'] ?? 'Login gagal. Silakan coba lagi.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
      print('Login Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna dari palet yang Anda berikan
    const Color color8D6B94 = Color(0xFF8D6B94); // Ungu keabuan
    const Color colorB185A7 = Color(0xFFB185A7); // Ungu muda
    const Color colorC3A29E = Color(0xFFC3A29E); // Coklat kemerahan muda
    // const Color colorE8DBC5 = Color(0xFFE8DBC5); // Krem - digunakan untuk fillFormBackground
    const Color colorFFF4E9 = Color(0xFFFFF4E9); // Putih gading - digunakan untuk fillFormBackground

    // Warna untuk latar belakang form input
    const Color fillFormBackgroundColor = colorFFF4E9;

    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Gradien
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color8D6B94,
                  colorB185A7,
                ],
              ),
            ),
          ),
          // CustomPaint untuk Pattern (Garis-garis Miring)
          CustomPaint(
            painter: StripePainter(
              stripeColor: Colors.white.withOpacity(0.1), // Warna garis-garis, transparan agar tidak terlalu dominan
              stripeWidth: 2.0, // Ketebalan garis
              spacing: 20.0, // Jarak antar garis
            ),
            child: Container(), // Child kosong untuk mengisi ruang
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Aplikasi
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 100,
                      color: Colors.white, // Teks dan ikon putih
                    ),
                    const SizedBox(height: 10),
                    // Nama Aplikasi
                    const Text(
                      'Indonesia Pintar',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Teks putih
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black26,
                            offset: Offset(3.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Temukan makna kata-kata Indonesia',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Teks putih
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Card untuk form login
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'Masukkan username Anda',
                                prefixIcon: const Icon(Icons.person, color: Colors.black54), // Ikon hitam
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: fillFormBackgroundColor, // Warna dari palet
                                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                labelStyle: const TextStyle(color: Colors.black87), // Label hitam
                                hintStyle: const TextStyle(color: Colors.black45), // Hint hitam
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username tidak boleh kosong';
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black), // Input teks hitam
                            ),
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Masukkan password Anda',
                                prefixIcon: const Icon(Icons.lock, color: Colors.black54), // Ikon hitam
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black54, // Ikon hitam
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: fillFormBackgroundColor, // Warna dari palet
                                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                labelStyle: const TextStyle(color: Colors.black87), // Label hitam
                                hintStyle: const TextStyle(color: Colors.black45), // Hint hitam
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black), // Input teks hitam
                            ),
                            const SizedBox(height: 40),

                            // Tombol Login
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorC3A29E, // Warna tombol dari palet
                                  foregroundColor: Colors.black, // Teks tombol hitam
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  shadowColor: colorC3A29E.withOpacity(0.4),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.black, // Indikator loading hitam
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'MASUK',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                          color: Colors.black, // Teks tombol hitam
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Tombol Daftar
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87, // Teks tombol hitam
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              child: const Text(
                                'Belum punya akun? Daftar di sini',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black, // Teks tombol hitam
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter untuk membuat pola garis-garis miring
class StripePainter extends CustomPainter {
  final Color stripeColor;
  final double stripeWidth;
  final double spacing;

  StripePainter({
    required this.stripeColor,
    required this.stripeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke; // Menggunakan stroke untuk garis

    // Menggambar garis-garis miring dari kiri bawah ke kanan atas
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint hanya jika properti painter berubah
    return oldDelegate is! StripePainter ||
        oldDelegate.stripeColor != stripeColor ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.spacing != spacing;
  }
}