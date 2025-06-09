import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'database/kbbi_entry.dart';
import 'entry_detail_page.dart';
import 'package:app/home/home_page.dart'; // Import HomePage untuk navigasi kembali

class EntryListPage extends StatefulWidget {
  const EntryListPage({super.key});

  @override
  State<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends State<EntryListPage> {
  final List<KbbiEntry> _entries = [];
  bool _isLoading = true;
  String _username = 'Pengguna'; // Default username
  String _errorMessage = '';
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  // Define your custom colors here
  static const Color primaryDarkBlue = Color(0xFF1F3240);
  static const Color accentTeal = Color(0xFF3B7B8C);
  static const Color backgroundLightCream = Color(0xFFF2EDDC);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color textBrown = Color(0xFF7F3E2C);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadUsername(), _loadPopularEntries()]);
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _username = prefs.getString('username') ?? 'Pengguna'; // Ambil username yang disimpan
      });
    } catch (e) {
      print('Error loading username in EntryListPage: $e');
    }
  }

  Future<void> _loadPopularEntries() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _hasError = false;
      });
    }

    try {
      // Anda mungkin ingin menambahkan otentikasi ke ApiService.getPopularEntries() jika endpoint ini dilindungi
      final data = await ApiService.getPopularEntries();
      if (mounted) {
        setState(() {
          _entries.clear();
          _entries.addAll(data);
          _hasError = false;
        });
      }
    } catch (e) {
      print('Error loading entries: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data: ${e.toString()}";
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchEntries(String query) async {
    if (query.isEmpty) {
      await _loadPopularEntries();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _hasError = false;
      });
    }

    try {
      // Anda mungkin ingin menambahkan otentikasi ke ApiService.searchEntries() jika endpoint ini dilindungi
      final data = await ApiService.searchEntries(query);
      if (mounted) {
        setState(() {
          _entries.clear();
          _entries.addAll(data);
          _hasError = false;
        });
      }
    } catch (e) {
      print('Error searching entries: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "Tidak ada kata yang ditemukan. Coba kata kunci lain atau periksa koneksi Anda.";
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- TAMBAHKAN METODE LOGOUT INI ---
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token
    await prefs.remove('username'); // Hapus username

    if (mounted) {
      // Kembali ke halaman login setelah logout.
      // Gunakan pushReplacementNamed agar tidak bisa kembali ke halaman sebelumnya.
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  // --- AKHIR TAMBAHAN METODE LOGOUT ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLightCream, // Set background color
      appBar: AppBar(
        title: const Text(
          'Kamus Bahasa', // Simpler title
          style: TextStyle(color: backgroundLightCream), // Title text color
        ),
        backgroundColor: primaryDarkBlue, // AppBar background color
        iconTheme: const IconThemeData(color: backgroundLightCream), // Icon colors
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pushReplacement untuk kembali ke HomePage dan menghapus riwayat
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark), // Changed to bookmark for consistency
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            color: backgroundLightCream, // Icon color
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPopularEntries,
            color: backgroundLightCream, // Icon color
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: backgroundLightCream), // Hamburger icon color
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text(
                    'Logout',
                    style: TextStyle(color: primaryDarkBlue), // Text color for popup item
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              cursorColor: accentTeal, // Cursor color
              decoration: InputDecoration(
                hintText: 'Cari kata...', // Simpler hint text
                hintStyle: TextStyle(color: textBrown.withOpacity(0.7)), // Hint text color
                prefixIcon: const Icon(Icons.search, color: accentTeal), // Icon color
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: textBrown), // Icon color
                  onPressed: () {
                    _searchController.clear();
                    _searchEntries('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // More rounded corners
                  borderSide: BorderSide.none, // No explicit border line
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: accentTeal, width: 1.5), // Teal border when enabled
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: accentOrange, width: 2.0), // Orange border when focused
                ),
                filled: true,
                fillColor: backgroundLightCream, // Fill color for TextField
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0), // Adjust padding
              ),
              style: TextStyle(color: primaryDarkBlue), // Input text color
              onSubmitted: (value) {
                _searchEntries(value);
              },
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: accentTeal), // Progress indicator color
            const SizedBox(height: 16),
            Text(
              'Memuat data kamus...',
              style: TextStyle(color: primaryDarkBlue), // Text color
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: textBrown, size: 60), // Error icon color
            const SizedBox(height: 20),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkBlue), // Text color
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textBrown), // Text color
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isEmpty) {
                  _loadPopularEntries();
                } else {
                  _searchEntries(_searchController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange, // Button background color
                foregroundColor: backgroundLightCream, // Button text/icon color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded button
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 60, color: accentTeal), // Icon color
            const SizedBox(height: 20),
            Text(
              'Tidak ada hasil ditemukan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkBlue), // Text color
            ),
            const SizedBox(height: 10),
            Text(
              'Coba kata kunci lain atau muat ulang data',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textBrown), // Text color
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPopularEntries,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal, // Button background color
                foregroundColor: backgroundLightCream, // Button text/icon color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded button
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPopularEntries,
      color: accentOrange, // Refresh indicator color
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return _buildEntryCard(entry);
        },
      ),
    );
  }

  Widget _buildEntryCard(KbbiEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4, // Increased elevation for a slightly more lifted look
      color: backgroundLightCream, // Card background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for cards
        side: const BorderSide(color: accentTeal, width: 0.5), // Subtle border
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12), // Match card border radius
        onTap: () {
          Navigator.pushNamed(
            context,
            '/kbbi_detail', // <--- Nama rute baru untuk detail page
            arguments: entry,
          ).then((_) {
            // Optional: You can do something here when returning from detail page
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.word,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryDarkBlue, // Changed text color
                ),
              ),
              const SizedBox(height: 8),
              if (entry.type != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '(${entry.type!})',
                    style: TextStyle(
                      fontSize: 14,
                      color: textBrown, // Changed text color
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (entry.arti != null && entry.arti!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.arti!
                      .map((meaning) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '- ${meaning.deskripsi}',
                              style: const TextStyle(fontSize: 16, color: primaryDarkBlue), // Changed text color
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}