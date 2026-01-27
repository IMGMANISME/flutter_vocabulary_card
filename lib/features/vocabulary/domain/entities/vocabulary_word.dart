import 'package:equatable/equatable.dart';

class VocabularyWord extends Equatable {
  final String id;
  final String word;
  final String partOfSpeech;
  final String definition;
  final String example;
  final String chineseTranslation;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.chineseTranslation,
  });

  @override
  List<Object?> get props => [
    id,
    word,
    partOfSpeech,
    definition,
    example,
    chineseTranslation,
  ];
}
