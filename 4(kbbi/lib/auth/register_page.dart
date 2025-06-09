import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Untuk mengontrol visibilitas password
  bool _isConfirmPasswordVisible = false; // Untuk mengontrol visibilitas konfirmasi password

  final String _baseUrl = 'http://localhost:3001'; // Sesuaikan dengan URL server Node.js Anda

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Password tidak cocok!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Pendaftaran berhasil! Silakan masuk.');
        if (mounted) {
          Navigator.pop(context); // Kembali ke halaman login
        }
      } else {
        final errorData = json.decode(response.body);
        _showSnackBar(errorData['message'] ?? 'Pendaftaran gagal. Silakan coba lagi.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
      print('Register Error: $e'); // Untuk debugging
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
    const Color colorFFF4E9 = Color(0xFFFFF4E9); // Putih gading

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
                      Icons.person_add_alt_1, // Icon disesuaikan untuk register
                      size: 100,
                      color: Colors.white, // Teks dan ikon putih
                    ),
                    const SizedBox(height: 10),
                    // Nama Aplikasi
                    const Text(
                      'Buat Akun',
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
                      'Bergabunglah dengan Indonesia Pintar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Teks putih
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Card untuk form register
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
                                hintText: 'Masukkan username yang diinginkan',
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
                                hintText: 'Buat password Anda',
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
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password',
                                hintText: 'Ulangi password Anda',
                                prefixIcon: const Icon(Icons.lock_reset, color: Colors.black54), // Ikon hitam
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black54, // Ikon hitam
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                                  return 'Konfirmasi password Anda';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password tidak cocok';
                                }
                                return null;
                              },
                              style: const TextStyle(color: Colors.black), // Input teks hitam
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
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
                                        'DAFTAR',
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
                            // Tombol Kembali ke Login
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Kembali ke halaman login
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87, // Teks tombol hitam
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              child: const Text(
                                'Sudah punya akun? Masuk di sini',
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

// CustomPainter untuk membuat pola garis-garis miring (sama seperti AuthPage)
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
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! StripePainter ||
        oldDelegate.stripeColor != stripeColor ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.spacing != spacing;
  }
}