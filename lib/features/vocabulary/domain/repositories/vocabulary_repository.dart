import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/vocabulary_word.dart';

abstract class VocabularyRepository {
  /// Get all vocabulary words. Falls back to the local cache when the network
  /// is unavailable.
  Future<Either<Failure, List<VocabularyWord>>> getVocabularyList();

  /// Last cached word list, readable synchronously so the first frame after a
  /// cold start already has content.
  List<VocabularyWord> getCachedVocabularyList();

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

  /// Position within the deck, restored on the next launch.
  int getStudyIndex();

  Future<void> saveStudyIndex(int index);

  /// Shuffle seed, or null for alphabetical order.
  int? getShuffleSeed();

  Future<void> saveShuffleSeed(int? seed);
}
