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

  // Define your custom colors here
  static const Color primaryDarkBlue = Color(0xFF1F3240);
  static const Color accentTeal = Color(0xFF3B7B8C);
  static const Color backgroundLightCream = Color(0xFFF2EDDC);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color textBrown = Color(0xFF7F3E2C);


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
      // Set the background color of the scaffold
      backgroundColor: backgroundLightCream,
      appBar: AppBar(
        title: Text(
          widget.entry.word,
          style: const TextStyle(color: backgroundLightCream), // Title text color
        ),
        backgroundColor: primaryDarkBlue, // AppBar background color
        iconTheme: const IconThemeData(color: backgroundLightCream), // Back icon color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop all routes until reaching the route with name '/kbbi_list'
            // This ensures returning to EntryListPage, regardless of where EntryDetailPage was called from.
            Navigator.pop(context, ModalRoute.withName('/kbbi_list'));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.bookmark : Icons.bookmark_border, // Changed icon to bookmark for save/unsave semantic
              color: _isFavorite ? accentOrange : backgroundLightCream, // Orange when favorited, light cream when not
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
            color: backgroundLightCream, // Notification icon color
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
                    color: textBrown, // Changed text color
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (widget.entry.lema != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Lema: ${widget.entry.lema!}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: primaryDarkBlue, // Changed text color
                    fontWeight: FontWeight.bold, // Make Lema stand out a bit
                  ),
                ),
              ),
            const Divider(color: accentTeal, thickness: 1.5), // Divider color and thickness
            const Text(
              'Arti:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDarkBlue, // Changed text color
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: textBrown, // Changed text color
                            ),
                          ),
                        ))
                    .toList(),
              ),
            if (widget.entry.tesaurusLink != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () {
                    // Open thesaurus link in browser - (You'll need to implement this with url_launcher package)
                    // Example: _launchUrl(widget.entry.tesaurusLink!);
                  },
                  child: Text(
                    'Lihat tesaurus: ${widget.entry.tesaurusLink!}',
                    style: const TextStyle(
                      color: accentTeal, // Changed link color
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

  // Example for _launchUrl function (requires url_launcher package)
  // Future<void> _launchUrl(String url) async {
  //   if (!await launchUrl(Uri.parse(url))) {
  //     _showSnackBar('Could not launch $url');
  //   }
  // }
}