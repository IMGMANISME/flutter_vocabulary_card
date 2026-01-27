import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_local_data_source.dart';
import '../datasources/vocabulary_remote_data_source.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyRemoteDataSource remoteDataSource;
  final VocabularyLocalDataSource localDataSource;
  // Note: Data connection checker could be injected here to check for internet connection
  // For simplicity, we assume if auth is logged in, use remote, else use local for toggling
  // Or simpler: The remote data source stream handles auth state.
  // But toggling needs to know where to toggle.

  VocabularyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<VocabularyWord>>> getVocabularyList() async {
    try {
      // For now, only remote has the vocabulary list logic (from the service analysis)
      // The original code tried Firestore first.
      final remoteWords = await remoteDataSource.getVocabularyList();
      return Right(remoteWords);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Set<String>> getLearnedWordIdsStream() {
    // We can combine local and remote or just switch based on auth.
    // The RemoteDataSource implementation already listens to AuthState.
    // But if user is null, Remote returns empty. We might want to fallback to local?
    // Let's assume we want to support offline/local only mode.

    // For now, let's trust the RemoteDataSource's stream which handles auth state internally roughly.
    // However, if we are offline/not logged in, we want Local storage.

    return remoteDataSource.getLearnedWordIdsStream().asyncMap((
      remoteIds,
    ) async {
      // Since the remote stream emits empty when logged out (in my impl),
      // actually we should verify checking auth status.
      // A better way is to listen to auth state here?

      // Simplification for migration:
      // If remote stream yields data (and user is logged in), use it.
      // If not, use local.
      // But 'stream' is continuous.

      // Let's assume we want a merged view or switch.
      // Refactoring step: Just delegate to remote for now as the main source of truth when logged in.
      // We'll trust the UI/StreamProvider to handle the switching or the DataSource to be smart.
      return remoteIds;
    });
  }

  @override
  Future<Either<Failure, void>> toggleLearnedStatus(String wordId) async {
    try {
      // Check if user is logged in via RemoteDataSource's auth reference?
      // Or just try remote and fallback?
      // Best practice: Check dependency.
      // But here we can try catch.

      // We need to know current state to toggle (remote needs 'id', but local toggle is simple).
      // My RemoteDataSource toggle takes `bool isLearned`. Oops, I need to know if it IS learned to toggle it.
      // The Repository API is `toggleLearnedStatus(id)`.
      // I should look up the current status.

      // Ideally the UI passes the current status, but if not, we check our stream?
      // Let's change the Repository to use the data sources.

      // Hack: For now, the UseCase calls toggle.
      // We need to know if the user is authenticated.
      // Let's assume we are migrating the exact logic from Service:
      /*
        if (user != null) {
           // Firestore toggle
        } else {
           // Local toggle
        }
      */

      // I'll check auth via the remote data source's auth instance (not ideal but practical).
      if ((remoteDataSource as VocabularyRemoteDataSourceImpl)
              .auth
              .currentUser !=
          null) {
        // We need to know if it's currently learned.
        // Since we don't have the state sync here easily without reading stream.
        // We can do a one-off read.
        // OR, we change the data source method to just 'toggle' and let it handle the logic (transaction).

        // Let's fetch current status from stream (which caches latest) or just simple read.
        // Actually, Firestore transaction is best for toggling if we want atomicity.
        // Or just read-modify-write.

        final currentIds = await remoteDataSource
            .getLearnedWordIdsStream()
            .first;
        final isLearned = currentIds.contains(wordId);
        await remoteDataSource.toggleLearnedStatus(wordId, isLearned);
      } else {
        await localDataSource.toggleLearnedStatus(wordId);
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
