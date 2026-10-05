import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/models/vocabulary_model.dart';

void main() {
  test('every bundled word parses and round trips without losing its ID', () {
    final files = Directory('assets/data').listSync().whereType<File>().where(
      (file) => RegExp(r'/[A-Z]\.json$').hasMatch(file.path),
    );
    var count = 0;
    for (final file in files) {
      for (final entry in jsonDecode(file.readAsStringSync()) as List) {
        final model = VocabularyModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        expect(model.id, entry['id'].toString());
        expect(model.definition, isNotEmpty);
        expect(model.example, isNotEmpty);
        expect(VocabularyModel.fromJson(model.toJson()), model);
        count++;
      }
    }
    expect(count, 1550);
  });

  test('known remote senses receive reviews without changing document IDs', () {
    final reviews =
        jsonDecode(File('docs/vocabulary_reviews.json').readAsStringSync())
            as List;
    for (final review in reviews) {
      final remote = <String, dynamic>{
        'id': 'firestore-${review['word']}',
        'word': review['word'],
        'partOfSpeech': review['partOfSpeech'],
        'definition': review['originalDefinition'],
        'example': review['originalExample'],
      };
      final model = VocabularyModel.fromJson(remote);
      expect(model.id, remote['id']);
      expect(model.definition, review['replacement']['definition']);
      expect(model.example, review['replacement']['example']);
      expect(model.sourceUrl, startsWith('https://dictionary.cambridge.org/'));
      expect(model.usageNote, isNotEmpty);
    }
  });

  test('other senses and newer editorial changes are never overwritten', () {
    final model = VocabularyModel.fromJson({
      'id': 'approval',
      'word': 'sanction',
      'partOfSpeech': 'noun',
      'definition': 'Formal approval or permission.',
      'example': 'They sought official sanction for their proposal.',
    });
    expect(model.definition, 'Formal approval or permission.');
    expect(model.sourceUrl, isEmpty);
  });

  test('blank or wrongly typed learning content fails explicitly', () {
    final valid = <String, dynamic>{
      'id': '1',
      'word': 'sample',
      'partOfSpeech': 'noun',
      'definition': 'A small part used to examine the whole.',
      'example': 'They examined a sample of the material.',
    };
    for (final field in [
      'id',
      'word',
      'partOfSpeech',
      'definition',
      'example',
    ]) {
      expect(
        () => VocabularyModel.fromJson({...valid, field: '  '}),
        throwsFormatException,
      );
      expect(
        () => VocabularyModel.fromJson({...valid, field: null}),
        throwsFormatException,
      );
    }
    expect(
      () => VocabularyModel.fromJson({...valid, 'example': 42}),
      throwsFormatException,
    );
  });
}
