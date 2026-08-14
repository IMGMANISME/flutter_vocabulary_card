import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/vocabulary_dependencies.dart';
import '../../domain/entities/vocabulary_word.dart';
import 'vocabulary_providers.dart';

class StudySessionState {
  final List<VocabularyWord> words;
  final VocabularyWord? currentWord;
  final int currentIndex;
  final List<String> availableLetters;
  final Map<String, int> letterIndexMap;
  final Set<String> learnedWordIds;

  const StudySessionState({
    required this.words,
    required this.currentWord,
    required this.currentIndex,
    required this.availableLetters,
    required this.letterIndexMap,
    required this.learnedWordIds,
  });

  factory StudySessionState.empty({required Set<String> learnedWordIds}) {
    return StudySessionState(
      words: const [],
      currentWord: null,
      currentIndex: 0,
      availableLetters: const [],
      letterIndexMap: const {},
      learnedWordIds: learnedWordIds,
    );
  }

  bool get hasWords => words.isNotEmpty;

  int get totalCount => words.length;

  int get displayPosition => hasWords ? currentIndex + 1 : 0;

  double get progress => hasWords ? displayPosition / totalCount : 0;

  bool get isAtStart => !hasWords || currentIndex == 0;

  bool get isAtEnd => !hasWords || currentIndex >= totalCount - 1;

  bool get isCurrentWordLearned {
    final word = currentWord;
    if (word == null) {
      return false;
    }

    return learnedWordIds.contains(word.id);
  }
}

/// Persisted so a relaunch resumes on the word the reader left off at.
class StudyIndexController extends Notifier<int> {
  @override
  int build() {
    return ref.watch(vocabularyRepositoryProvider).getStudyIndex();
  }

  void reset() {
    _moveTo(0);
  }

  void next({required int currentIndex, required int totalCount}) {
    if (totalCount <= 0) {
      _moveTo(0);
      return;
    }

    if (currentIndex < totalCount - 1) {
      _moveTo(currentIndex + 1);
    }
  }

  void previous(int currentIndex) {
    if (currentIndex > 0) {
      _moveTo(currentIndex - 1);
    }
  }

  void jumpTo(int index) {
    if (index < 0) {
      return;
    }

    _moveTo(index);
  }

  void _moveTo(int index) {
    state = index;
    // Fire and forget: the write is a local preference, and blocking the tap
    // on it would put a frame of lag between the press and the next card.
    unawaited(ref.read(vocabularyRepositoryProvider).saveStudyIndex(index));
  }
}

final studyIndexProvider = NotifierProvider<StudyIndexController, int>(
  StudyIndexController.new,
);

/// Null means alphabetical order. A non-null value seeds the shuffle, so the
/// order survives rebuilds — marking a word learned or toggling [hideLearned]
/// must not silently reshuffle the deck under the reader. The seed is stored
/// locally too, so the same holds across a relaunch.
class ShuffleSeedController extends Notifier<int?> {
  @override
  int? build() {
    return ref.watch(vocabularyRepositoryProvider).getShuffleSeed();
  }

  void shuffle() {
    _apply(DateTime.now().microsecondsSinceEpoch);
  }

  void restoreOrder() {
    _apply(null);
  }

  void _apply(int? seed) {
    state = seed;
    unawaited(ref.read(vocabularyRepositoryProvider).saveShuffleSeed(seed));
  }
}

final shuffleSeedProvider = NotifierProvider<ShuffleSeedController, int?>(
  ShuffleSeedController.new,
);

final studySessionProvider = Provider<StudySessionState>((ref) {
  final requestedIndex = ref.watch(studyIndexProvider);
  final hideLearned = ref.watch(hideLearnedProvider);
  final shuffleSeed = ref.watch(shuffleSeedProvider);

  final allWords =
      ref.watch(vocabularyListProvider).value ?? const <VocabularyWord>[];
  final learnedWordIds =
      ref.watch(learnedWordIdsProvider).value ?? const <String>{};

  return buildStudySessionState(
    allWords: allWords,
    learnedWordIds: learnedWordIds,
    hideLearned: hideLearned,
    requestedIndex: requestedIndex,
    shuffleSeed: shuffleSeed,
  );
});

StudySessionState buildStudySessionState({
  required List<VocabularyWord> allWords,
  required Set<String> learnedWordIds,
  required bool hideLearned,
  required int requestedIndex,
  int? shuffleSeed,
}) {
  final filteredWords = hideLearned
      ? allWords.where((word) => !learnedWordIds.contains(word.id)).toList()
      : List<VocabularyWord>.from(allWords);

  if (filteredWords.isEmpty) {
    return StudySessionState.empty(learnedWordIds: learnedWordIds);
  }

  if (shuffleSeed != null) {
    filteredWords.shuffle(Random(shuffleSeed));
  }

  final clampedIndex = requestedIndex.clamp(0, filteredWords.length - 1);
  final letterIndexMap = <String, int>{};

  for (var index = 0; index < filteredWords.length; index++) {
    final word = filteredWords[index].word;
    if (word.isEmpty) {
      continue;
    }

    final letter = word[0].toUpperCase();
    letterIndexMap.putIfAbsent(letter, () => index);
  }

  final availableLetters = letterIndexMap.keys.toList()..sort();

  return StudySessionState(
    words: UnmodifiableListView(filteredWords),
    currentWord: filteredWords[clampedIndex],
    currentIndex: clampedIndex,
    availableLetters: UnmodifiableListView(availableLetters),
    letterIndexMap: UnmodifiableMapView(letterIndexMap),
    learnedWordIds: UnmodifiableSetView(learnedWordIds),
  );
}
