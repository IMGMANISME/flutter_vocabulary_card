import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/vocabulary_repository.dart';

class SetLearnedStatusUseCase {
  final VocabularyRepository _repository;

  SetLearnedStatusUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String wordId,
    required bool isLearned,
  }) {
    return _repository.setLearnedStatus(wordId: wordId, isLearned: isLearned);
  }
}
