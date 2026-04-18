import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/datasources/vocabulary_local_data_source.dart';
import '../data/datasources/vocabulary_remote_data_source.dart';
import '../data/repositories/vocabulary_repository_impl.dart';
import '../domain/repositories/vocabulary_repository.dart';
import '../domain/usecases/get_learned_status_stream_usecase.dart';
import '../domain/usecases/get_vocabulary_list_usecase.dart';
import '../domain/usecases/toggle_learned_status_usecase.dart';

final vocabularyLocalDataSourceProvider = Provider<VocabularyLocalDataSource>((
  ref,
) {
  return VocabularyLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final vocabularyRemoteDataSourceProvider = Provider<VocabularyRemoteDataSource>(
  (ref) {
    return VocabularyRemoteDataSourceImpl(
      firestore: ref.watch(firestoreProvider),
      auth: ref.watch(firebaseAuthProvider),
    );
  },
);

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepositoryImpl(
    remoteDataSource: ref.watch(vocabularyRemoteDataSourceProvider),
    localDataSource: ref.watch(vocabularyLocalDataSourceProvider),
  );
});

final getVocabularyListUseCaseProvider = Provider<GetVocabularyListUseCase>((
  ref,
) {
  return GetVocabularyListUseCase(ref.watch(vocabularyRepositoryProvider));
});

final toggleLearnedStatusUseCaseProvider = Provider<ToggleLearnedStatusUseCase>(
  (ref) {
    return ToggleLearnedStatusUseCase(ref.watch(vocabularyRepositoryProvider));
  },
);

final getLearnedStatusStreamUseCaseProvider =
    Provider<GetLearnedStatusStreamUseCase>((ref) {
      return GetLearnedStatusStreamUseCase(
        ref.watch(vocabularyRepositoryProvider),
      );
    });
