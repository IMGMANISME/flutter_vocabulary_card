import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_local_data_source.dart';
import '../datasources/vocabulary_remote_data_source.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyRemoteDataSource remoteDataSource;
  final VocabularyLocalDataSource localDataSource;

  VocabularyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<VocabularyWord>>> getVocabularyList() async {
    try {
      final remoteWords = await remoteDataSource.getVocabularyList();
      await localDataSource.cacheVocabularyList(remoteWords);
      return Right(remoteWords);
    } on ServerException catch (error) {
      return _cachedListOr(ServerFailure(error.message));
    } catch (error) {
      return _cachedListOr(ServerFailure(error.toString()));
    }
  }

  /// Offline is only an error when there is nothing cached to show.
  Either<Failure, List<VocabularyWord>> _cachedListOr(Failure failure) {
    final cached = localDataSource.getCachedVocabularyList();

    if (cached.isEmpty) {
      return Left(failure);
    }

    return Right(cached);
  }

  @override
  List<VocabularyWord> getCachedVocabularyList() {
    return localDataSource.getCachedVocabularyList();
  }

  @override
  Stream<Set<String>> getLearnedWordIdsStream() {
    return remoteDataSource
        .userIdChanges()
        .switchMap((userId) {
          if (userId == null) {
            return localDataSource.getLearnedWordIdsStream();
          }

          final stream = remoteDataSource
              .watchLearnedWordIds(userId)
              .doOnData(
                (ids) => localDataSource.cacheRemoteLearnedIds(userId, ids),
              );

          final mirrored = localDataSource.getCachedRemoteLearnedIds(userId);

          // The mirror goes out first so the buttons are already correct on
          // the frame the deck appears, instead of flashing "not learned"
          // until Firestore answers. An empty mirror carries no information,
          // and prepending it would cause the very flash it exists to avoid.
          if (mirrored.isEmpty) {
            return stream;
          }

          return stream.startWith(mirrored);
        })
        .distinct(_sameSet);
  }

  bool _sameSet(Set<String> previous, Set<String> next) {
    if (identical(previous, next)) {
      return true;
    }

    if (previous.length != next.length) {
      return false;
    }

    for (final value in previous) {
      if (!next.contains(value)) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<Either<Failure, void>> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  }) async {
    try {
      final userId = remoteDataSource.currentUserId;

      if (userId == null) {
        await localDataSource.setLearnedStatus(
          wordId: wordId,
          isLearned: isLearned,
        );
      } else {
        await remoteDataSource.setLearnedStatus(
          userId: userId,
          wordId: wordId,
          isLearned: isLearned,
        );
      }

      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  bool getHideLearned() {
    return localDataSource.getHideLearned();
  }

  @override
  Future<void> saveHideLearned(bool value) async {
    await localDataSource.cacheHideLearned(value);
  }

  @override
  int getStudyIndex() {
    return localDataSource.getStudyIndex();
  }

  @override
  Future<void> saveStudyIndex(int index) async {
    await localDataSource.cacheStudyIndex(index);
  }

  @override
  int? getShuffleSeed() {
    return localDataSource.getShuffleSeed();
  }

  @override
  Future<void> saveShuffleSeed(int? seed) async {
    await localDataSource.cacheShuffleSeed(seed);
  }
}
