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

    test('keeps alphabetical order when no shuffle seed is given', () {
      final state = buildStudySessionState(
        allWords: _deck,
        learnedWordIds: const {},
        hideLearned: false,
        requestedIndex: 0,
      );

      expect(state.words.map((word) => word.id).toList(), [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
      ]);
    });

    test('shuffle seed reorders the deck without losing or duplicating', () {
      final state = buildStudySessionState(
        allWords: _deck,
        learnedWordIds: const {},
        hideLearned: false,
        requestedIndex: 0,
        shuffleSeed: 42,
      );

      final ids = state.words.map((word) => word.id).toList();
      expect(ids, isNot(['1', '2', '3', '4', '5', '6', '7', '8']));
      expect(ids.toSet(), _deck.map((word) => word.id).toSet());
      expect(ids.length, _deck.length);
    });

    /// The order has to survive rebuilds: marking a word learned or toggling
    /// hideLearned rebuilds this state, and a fresh shuffle each time would
    /// move the deck under the reader.
    test('same seed produces the same order', () {
      List<String> orderFor(int seed) {
        return buildStudySessionState(
          allWords: _deck,
          learnedWordIds: const {},
          hideLearned: false,
          requestedIndex: 0,
          shuffleSeed: seed,
        ).words.map((word) => word.id).toList();
      }

      expect(orderFor(7), orderFor(7));
      expect(orderFor(7), isNot(orderFor(8)));
    });

    test('shuffle still filters learned words', () {
      final state = buildStudySessionState(
        allWords: _deck,
        learnedWordIds: {'1', '2', '3'},
        hideLearned: true,
        requestedIndex: 0,
        shuffleSeed: 42,
      );

      expect(state.words.length, 5);
      expect(
        state.words.map((word) => word.id),
        isNot(contains(anyOf('1', '2', '3'))),
      );
    });

    test('letter jump targets stay consistent with the shuffled order', () {
      final state = buildStudySessionState(
        allWords: _deck,
        learnedWordIds: const {},
        hideLearned: false,
        requestedIndex: 0,
        shuffleSeed: 42,
      );

      for (final letter in state.availableLetters) {
        final index = state.letterIndexMap[letter]!;
        expect(state.words[index].word.toUpperCase(), startsWith(letter));
      }
    });
  });
}

final _deck = [
  _word('1', 'Apple'),
  _word('2', 'Banana'),
  _word('3', 'Cherry'),
  _word('4', 'Date'),
  _word('5', 'Elder'),
  _word('6', 'Fig'),
  _word('7', 'Grape'),
  _word('8', 'Honey'),
];
