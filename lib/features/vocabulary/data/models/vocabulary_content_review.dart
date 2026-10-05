part 'vocabulary_content_review.entries.dart';

/// Validates a record and applies only reviews of its exact, known sense.
/// Document IDs are preserved because learned status is keyed by those IDs.
Map<String, dynamic> prepareVocabularyJson(Map<String, dynamic> json) {
  final prepared = Map<String, dynamic>.from(json);
  final id = prepared['id'];
  if (id is int) {
    prepared['id'] = id.toString();
  }

  for (final field in ['id', 'word', 'partOfSpeech', 'definition', 'example']) {
    final value = prepared[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Vocabulary record has an invalid $field.');
    }
    prepared[field] = value.trim();
  }

  for (final field in ['chineseTranslation', 'usageNote', 'sourceUrl']) {
    final value = prepared[field];
    if (value != null && value is! String) {
      throw FormatException('Vocabulary record has an invalid $field.');
    }
    prepared[field] = (value as String?)?.trim() ?? '';
  }

  for (final review in _contentReviews) {
    if (prepared['word'].toLowerCase() != review['word'] ||
        prepared['partOfSpeech'] != review['partOfSpeech']) {
      continue;
    }
    final replacement = review['replacement'] as Map<String, String>;
    final knownDefinition =
        prepared['definition'] == review['originalDefinition'] ||
        prepared['definition'] == replacement['definition'];
    final knownExample =
        prepared['example'] == review['originalExample'] ||
        prepared['example'] == replacement['example'];
    if (knownDefinition && knownExample) {
      prepared.addAll(replacement);
    }
  }
  return prepared;
}
