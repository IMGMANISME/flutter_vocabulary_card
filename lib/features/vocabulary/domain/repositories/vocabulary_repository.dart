import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/vocabulary_word.dart';

abstract class VocabularyRepository {
  /// Get all vocabulary words.
  Future<Either<Failure, List<VocabularyWord>>> getVocabularyList();

  /// Set learned status for a word.
  Future<Either<Failure, void>> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  });

  /// Stream of learned word IDs (real-time updates).
  Stream<Set<String>> getLearnedWordIdsStream();

  /// Get hide learned preference.
  bool getHideLearned();

  /// Save hide learned preference.
  Future<void> saveHideLearned(bool value);
}
