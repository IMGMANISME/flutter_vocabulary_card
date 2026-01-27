class VocabularyWord {
  final String id;
  final String word;
  final String partOfSpeech;
  final String definition;
  final String example;
  final String chineseTranslation;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.chineseTranslation,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id']?.toString() ?? '',
      word: json['word'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      chineseTranslation: json['chineseTranslation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'example': example,
      'chineseTranslation': chineseTranslation,
    };
  }
}
