import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/vocabulary_word.dart';
import '../repositories/vocabulary_repository.dart';

class GetVocabularyListUseCase {
  final VocabularyRepository _repository;

  GetVocabularyListUseCase(this._repository);

  Future<Either<Failure, List<VocabularyWord>>> call() {
    return _repository.getVocabularyList();
  }
}
