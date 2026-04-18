import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/vocabulary_word.dart';

part 'vocabulary_model.g.dart';

@JsonSerializable()
class VocabularyModel extends VocabularyWord {
  const VocabularyModel({
    required super.id,
    required super.word,
    required super.partOfSpeech,
    required super.definition,
    required super.example,
    required super.chineseTranslation,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) =>
      _$VocabularyModelFromJson(json);

  Map<String, dynamic> toJson() => _$VocabularyModelToJson(this);

  factory VocabularyModel.fromEntity(VocabularyWord entity) {
    return VocabularyModel(
      id: entity.id,
      word: entity.word,
      partOfSpeech: entity.partOfSpeech,
      definition: entity.definition,
      example: entity.example,
      chineseTranslation: entity.chineseTranslation,
    );
  }
}
