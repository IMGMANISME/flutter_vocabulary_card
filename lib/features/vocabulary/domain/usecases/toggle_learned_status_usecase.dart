import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/vocabulary_repository.dart';

class ToggleLearnedStatusUseCase {
  final VocabularyRepository _repository;

  ToggleLearnedStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(String wordId) {
    return _repository.toggleLearnedStatus(wordId);
  }
}
