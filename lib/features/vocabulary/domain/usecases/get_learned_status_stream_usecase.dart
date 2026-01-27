import '../repositories/vocabulary_repository.dart';

class GetLearnedStatusStreamUseCase {
  final VocabularyRepository _repository;

  GetLearnedStatusStreamUseCase(this._repository);

  Stream<Set<String>> call() {
    return _repository.getLearnedWordIdsStream();
  }
}
