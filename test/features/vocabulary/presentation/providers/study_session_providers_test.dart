import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_vocabulary_card/features/vocabulary/domain/entities/vocabulary_word.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/presentation/providers/study_session_providers.dart';

VocabularyWord _word(String id, String word) {
  return VocabularyWord(
    id: id,
    word: word,
    partOfSpeech: 'noun',
    definition: 'definition for $word',
    example: 'example for $word',
    chineseTranslation: '翻譯',
  );
}

void main() {
  group('buildStudySessionState', () {
    test('filters learned words when hideLearned is enabled', () {
      final state = buildStudySessionState(
        allWords: [_word('1', 'Apple'), _word('2', 'Banana')],
        learnedWordIds: {'1'},
        hideLearned: true,
        requestedIndex: 0,
      );

      expect(state.words.map((word) => word.id).toList(), ['2']);
      expect(state.currentWord?.id, '2');
      expect(state.availableLetters, ['B']);
      expect(state.letterIndexMap['B'], 0);
    });

    test('clamps out-of-range index to the last available card', () {
      final state = buildStudySessionState(
        allWords: [_word('1', 'Apple'), _word('2', 'Banana')],
        learnedWordIds: const {},
        hideLearned: false,
        requestedIndex: 100,
      );

      expect(state.currentIndex, 1);
      expect(state.currentWord?.id, '2');
      expect(state.displayPosition, 2);
      expect(state.totalCount, 2);
    });
  });
}
