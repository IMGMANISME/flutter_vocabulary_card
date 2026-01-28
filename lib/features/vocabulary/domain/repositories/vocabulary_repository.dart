import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/vocabulary_word.dart';

abstract class VocabularyRepository {
  /// Get all vocabulary words.
  Future<Either<Failure, List<VocabularyWord>>> getVocabularyList();

  /// Toggle learned status for a word.
  Future<Either<Failure, void>> toggleLearnedStatus(String wordId);

  /// Stream of learned word IDs (real-time updates).
  Stream<Set<String>> getLearnedWordIdsStream();

  /// Get hide learned preference.
  bool getHideLearned();

  /// Save hide learned preference.
  Future<void> saveHideLearned(bool value);
}
