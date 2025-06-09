import 'dart:convert';
import 'package:http/http.dart' as http;
import '../kbbi/database/kbbi_entry.dart';

class ApiService {
  static const String _baseUrl =
  'http://192.168.0.100:3001'; // Ensure this is correct
  static const Duration _timeoutDuration = Duration(seconds: 100000);

  // Search entries
  static Future<List<KbbiEntry>> searchEntries(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/kbbi/search/$encodedQuery'), // Corrected URL
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          if (data['data'] is List) {
            return data['data']
                .map<KbbiEntry>((json) => KbbiEntry.fromJson(json))
                .toList();
          } else {
            return [KbbiEntry.fromJson(data['data'])];
          }
        } else {
          throw Exception(data['message'] ?? 'Data tidak ditemukan');
        }
      } else {
        throw _handleError(response.statusCode, response.body);
      }
    } catch (e) {
      print('Error in searchEntries: $e');
      throw _handleNetworkError(e);
    }
  }

  // Get popular entries (mock)
  static Future<List<KbbiEntry>> getPopularEntries() async {
    try {
      // This is just an example; you can replace it with actual API calls if needed
      final popularWords = [
        'kerja',
        'makan',
        'minum',
        'jalan',
        'baca',
        'tulis',
        'lihat',
      ];
      List<KbbiEntry> results = [];

      for (var word in popularWords) {
        final response = await searchEntries(word);
        results.addAll(response);
      }

      return results;
    } catch (e) {
      print('Error in getPopularEntries: $e');
      throw _handleNetworkError(e);
    }
  }

  // Error handling
  static Exception _handleError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return Exception('Permintaan tidak valid: $responseBody');
      case 401:
        return Exception('Akses tidak diizinkan');
      case 403:
        return Exception('Dilarang mengakses');
      case 404:
        return Exception('Data tidak ditemukan');
      case 500:
        return Exception('Kesalahan server');
      case 502:
        return Exception('Gateway tidak valid');
      case 503:
        return Exception('Layanan tidak tersedia');
      default:
        return Exception('Error HTTP $statusCode: $responseBody');
    }
  }

  static Exception _handleNetworkError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return Exception('Permintaan timeout. Periksa koneksi internet Anda.');
    } else if (error.toString().contains('SocketException')) {
      return Exception('Tidak ada koneksi internet.');
    } else if (error.toString().contains('FormatException')) {
      return Exception('Format data tidak valid dari server.');
    } else if (error is Exception) {
      return error;
    } else {
      return Exception('Error jaringan tidak diketahui: ${error.toString()}');
    }
  }
}
