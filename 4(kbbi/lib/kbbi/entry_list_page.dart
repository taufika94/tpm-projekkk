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
          _errorMessage = "Gagal mencari kata: ${e.toString()}";
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kamus Besar Bahasa Indonesia'),
        // Tambahkan tombol back ke HomePage
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement( // Gunakan pushReplacement untuk kembali ke HomePage
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            // Alternatif: Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPopularEntries,
          ),
          // --- TAMBAHKAN POPUPMENUBUTTON UNTUK LOGOUT ---
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
          // --- AKHIR TAMBAHAN POPUPMENUBUTTON ---
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kata dalam KBBI...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchEntries('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
    // ... (kode _buildBody sama seperti sebelumnya) ...
    if (_isLoading && _entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data kamus...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
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
            const Icon(Icons.book, size: 60, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Tidak ada hasil ditemukan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Coba kata kunci lain atau muat ulang data',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPopularEntries,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPopularEntries,
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
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          Navigator.pushNamed(
             context,
             '/kbbi_detail', // <--- Nama rute baru untuk detail page
             arguments: entry,
          ).then((_) {
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
                  color: Colors.blue,
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
                      color: Colors.grey[600],
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
                              style: const TextStyle(fontSize: 16),
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