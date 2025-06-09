import 'package:hive/hive.dart';

part 'kbbi_entry.g.dart';

@HiveType(typeId: 0) // Ubah typeId KbbiEntry menjadi 0
class KbbiEntry {
  @HiveField(0)
  final String word;
  
  @HiveField(1)
  final String? type;
  
  @HiveField(2)
  final String? lema;
  
  @HiveField(3)
  final List<Arti>? arti;
  
  @HiveField(4)
  final String? tesaurusLink;

  KbbiEntry({
    required this.word,
    this.type,
    this.lema,
    this.arti,
    this.tesaurusLink,
  });

  factory KbbiEntry.fromJson(Map<String, dynamic> json) {
    // ... (kode dari KbbiEntry Anda)
    return KbbiEntry(
      word: json['word'] ?? '',
      type: json['type'],
      lema: json['lema'],
      arti: json['arti'] != null
          ? (json['arti'] as List).map((e) => Arti.fromJson(e)).toList()
          : null,
      tesaurusLink: json['tesaurusLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'type': type,
      'lema': lema,
      'arti': arti?.map((e) => e.toJson()).toList(),
      'tesaurusLink': tesaurusLink,
    };
  }
}

@HiveType(typeId: 1) // Biarkan typeId Arti menjadi 1 (atau ubah ke angka lain yang unik dan berbeda dari 0)
class Arti {
  @HiveField(0)
  final String deskripsi;

  Arti({required this.deskripsi});

  factory Arti.fromJson(Map<String, dynamic> json) {
    return Arti(
      deskripsi: json['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deskripsi': deskripsi,
    };
  }
}