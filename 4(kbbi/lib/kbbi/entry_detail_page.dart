import 'package:app/home/notification_page.dart';
import 'package:app/kbbi/database/kbbi_entry.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import 'entry_list_page.dart'; // <--- Tambahkan ini untuk mengimpor EntryListPage

class EntryDetailPage extends StatefulWidget {
  final KbbiEntry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  bool _isFavorite = false;
  late DatabaseService _databaseService;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUsername();
    await _checkIfFavorite();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _checkIfFavorite() async {
    if (_username.isEmpty) return;

    try {
      final favorites = await _databaseService.getFavorites(_username);
      setState(() {
        _isFavorite = favorites.any((entry) => entry.word == widget.entry.word);
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      _showSnackBar('Gagal memeriksa status favorit.');
    }
  }

  Future<void> _toggleFavorite() async {
  if (_username.isEmpty) {
    _showSnackBar('Anda harus login untuk menambahkan favorit.');
    return;
  }

  setState(() {
    _isFavorite = !_isFavorite;
  });

  try {
    if (_isFavorite) {
      await _databaseService.addFavorite(widget.entry, _username);
      String message = '${widget.entry.word} berhasil disimpan!';
      _showSnackBar(message);
      await _saveNotification(message); // Simpan notifikasi
    } else {
      await _databaseService.removeFavorite(widget.entry.word, _username);
      String message = '${widget.entry.word} berhasil dihapus dari daftar simpan.';
      _showSnackBar(message);
      await _saveNotification(message); // Simpan notifikasi
    }
  } catch (e) {
    print('Error toggling favorite: $e');
    _showSnackBar('Gagal menyimpan: ${e.toString()}');
    setState(() {
      _isFavorite = !_isFavorite; // Kembalikan status ke sebelumnya jika gagal
    });
  }
}

Future<void> _saveNotification(String message) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> notifications = prefs.getStringList('notifications') ?? [];
  notifications.add(message);
  await prefs.setStringList('notifications', notifications);
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.word),
        leading: IconButton( // <--- Tambahkan IconButton ini untuk tombol back
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop semua rute hingga mencapai rute dengan nama '/entry_list'
            // Ini akan memastikan kembali ke EntryListPage, tidak peduli dari mana EntryDetailPage dipanggil.
            Navigator.pop(context, ModalRoute.withName('/kbbi_list'));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.save : Icons.save,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.entry.type != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Jenis: ${widget.entry.type!}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (widget.entry.lema != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Lema: ${widget.entry.lema!}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const Divider(),
            const Text(
              'Arti:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.entry.arti != null && widget.entry.arti!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.entry.arti!
                    .map((meaning) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '- ${meaning.deskripsi}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
              ),
            if (widget.entry.tesaurusLink != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () {
                    // Open thesaurus link in browser
                  },
                  child: Text(
                    'Lihat tesaurus: ${widget.entry.tesaurusLink!}',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}