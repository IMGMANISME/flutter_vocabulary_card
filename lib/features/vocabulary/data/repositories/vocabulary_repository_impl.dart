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
      return Right(remoteWords);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Stream<Set<String>> getLearnedWordIdsStream() {
    return remoteDataSource
        .userIdChanges()
        .switchMap((userId) {
          if (userId == null) {
            return localDataSource.getLearnedWordIdsStream();
          }

          return remoteDataSource.watchLearnedWordIds(userId);
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
}
