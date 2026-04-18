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

final vocabularyListProvider = FutureProvider<List<VocabularyWord>>((
  ref,
) async {
  final useCase = ref.watch(getVocabularyListUseCaseProvider);
  final result = await useCase.call();

  return result.fold((failure) => throw VocabularyLoadException(failure), (
    list,
  ) {
    return list;
  });
});

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
