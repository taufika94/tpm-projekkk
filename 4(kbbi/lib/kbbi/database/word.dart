class Word {
  final String word;
  final String type;
  final String meaning;

  Word({required this.word, required this.type, required this.meaning});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      type: json['type'],
      meaning: json['arti'][0]['deskripsi'],
    );
  }
}