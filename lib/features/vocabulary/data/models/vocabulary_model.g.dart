// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocabularyModel _$VocabularyModelFromJson(Map<String, dynamic> json) =>
    VocabularyModel(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      example: json['example'] as String? ?? '',
      chineseTranslation: json['chineseTranslation'] as String? ?? '',
    );

Map<String, dynamic> _$VocabularyModelToJson(VocabularyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'partOfSpeech': instance.partOfSpeech,
      'definition': instance.definition,
      'example': instance.example,
      'chineseTranslation': instance.chineseTranslation,
    };
