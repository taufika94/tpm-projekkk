import 'package:hive/hive.dart';
import '../kbbi/database/kbbi_entry.dart';

class DatabaseService {
  static const String boxName = 'favoritesBox';

  Future<void> addFavorite(KbbiEntry entry, String username) async {
    final box = await Hive.openBox<KbbiEntry>(boxName);
    await box.put('${username}_${entry.word}', entry);
  }

  Future<List<KbbiEntry>> getFavorites(String username) async {
    final box = await Hive.openBox<KbbiEntry>(boxName);
    return box.keys
        .where((key) => key.startsWith('${username}_'))
        .map((key) => box.get(key))
        .whereType<KbbiEntry>()
        .toList();
  }

  Future<void> removeFavorite(String word, String username) async {
    final box = await Hive.openBox<KbbiEntry>(boxName);
    await box.delete('${username}_$word');
  }

  Future<void> clearFavorites() async {
    final box = await Hive.openBox<KbbiEntry>(boxName);
    await box.clear();
  }
}