import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/kbbi_entry.dart';
import '../services/database_service.dart';
import 'entry_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final List<KbbiEntry> _favorites = [];
  bool _isLoading = true;
  String _username = '';
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Pastikan username dimuat sebelum memuat favorit
    // _loadFavorites() akan dipanggil setelah _loadUsername() selesai
    // karena diawal kita cek _username.isEmpty
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
    // Panggil _loadFavorites setelah username dipastikan terisi
    if (_username.isNotEmpty) {
      await _loadFavorites();
    } else {
      // Handle case where username is empty (e.g., not logged in properly)
      setState(() {
        _isLoading = false; // Stop loading if no username
      });
      // Optionally, show a message or navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda perlu login untuk melihat favorit.')),
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    if (_username.isEmpty) return; // Kembali jika username kosong

    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _databaseService.getFavorites(_username);
      setState(() {
        _favorites.clear();
        _favorites.addAll(favorites);
      });
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(KbbiEntry entry) async {
    if (_username.isEmpty) return;

    try {
      await _databaseService.removeFavorite(entry.word, _username);
      // Reload favorites after removal
      await _loadFavorites();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        _username.isEmpty
                            ? 'Silakan login untuk menyimpan favorit.'
                            : 'Belum ada kata favorit, ${_username}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      if (_username.isEmpty) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Login Sekarang'),
                        ),
                      ]
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final entry = _favorites[index];
                    return Dismissible(
                      key: Key(entry.word),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removeFavorite(entry);
                        // Show a snackbar feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${entry.word} dihapus dari favorit')),
                        );
                      },
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EntryDetailPage(entry: entry),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.word,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                if (entry.arti != null && entry.arti!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      entry.arti![0].deskripsi,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}