import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../di/vocabulary_dependencies.dart';
import '../../domain/entities/vocabulary_word.dart';

class VocabularyLoadException implements Exception {
  final Failure failure;

  const VocabularyLoadException(this.failure);

  @override
  String toString() {
    return failure.message;
  }
}

class VocabularyListController extends AsyncNotifier<List<VocabularyWord>> {
  @override
  FutureOr<List<VocabularyWord>> build() {
    final cached = ref.watch(vocabularyRepositoryProvider)
        .getCachedVocabularyList();

    if (cached.isEmpty) {
      return _fetch();
    }

    // The cached deck is returned synchronously, so a relaunch skips the
    // loading spinner entirely. The network copy replaces it once it lands,
    // and an offline launch simply keeps the cached one.
    Future.microtask(refresh);
    return cached;
  }

  Future<void> refresh() async {
    final result = await ref.read(getVocabularyListUseCaseProvider).call();

    if (!ref.mounted) {
      return;
    }

    result.match((_) {}, (words) => state = AsyncData(words));
  }

  Future<List<VocabularyWord>> _fetch() async {
    final result = await ref.read(getVocabularyListUseCaseProvider).call();

    return result.fold(
      (failure) => throw VocabularyLoadException(failure),
      (list) => list,
    );
  }
}

final vocabularyListProvider =
    AsyncNotifierProvider<VocabularyListController, List<VocabularyWord>>(
      VocabularyListController.new,
    );

final learnedWordIdsProvider = StreamProvider<Set<String>>((ref) {
  final useCase = ref.watch(getLearnedStatusStreamUseCaseProvider);
  return useCase.call();
});

class HideLearnedController extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(vocabularyRepositoryProvider).getHideLearned();
  }

  Future<void> toggle() async {
    state = !state;
    await ref.read(vocabularyRepositoryProvider).saveHideLearned(state);
  }
}

final hideLearnedProvider = NotifierProvider<HideLearnedController, bool>(
  HideLearnedController.new,
);
