import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/vocabulary_local_data_source.dart';
import '../../data/datasources/vocabulary_remote_data_source.dart';
import '../../data/repositories/vocabulary_repository_impl.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../../domain/usecases/get_learned_status_stream_usecase.dart';
import '../../domain/usecases/get_vocabulary_list_usecase.dart';
import '../../domain/usecases/toggle_learned_status_usecase.dart';

part 'vocabulary_providers.g.dart';

// --- External Dependencies ---

@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider not initialized');
}

@riverpod
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

// --- Data Sources ---

@riverpod
VocabularyLocalDataSource vocabularyLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return VocabularyLocalDataSourceImpl(sharedPreferences: prefs);
}

@riverpod
VocabularyRemoteDataSource vocabularyRemoteDataSource(Ref ref) {
  return VocabularyRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}

// --- Repository ---

@riverpod
VocabularyRepository vocabularyRepository(Ref ref) {
  return VocabularyRepositoryImpl(
    remoteDataSource: ref.watch(vocabularyRemoteDataSourceProvider),
    localDataSource: ref.watch(vocabularyLocalDataSourceProvider),
  );
}

// --- UseCases ---

@riverpod
GetVocabularyListUseCase getVocabularyListUseCase(Ref ref) {
  return GetVocabularyListUseCase(ref.watch(vocabularyRepositoryProvider));
}

@riverpod
ToggleLearnedStatusUseCase toggleLearnedStatusUseCase(Ref ref) {
  return ToggleLearnedStatusUseCase(ref.watch(vocabularyRepositoryProvider));
}

@riverpod
GetLearnedStatusStreamUseCase getLearnedStatusStreamUseCase(Ref ref) {
  return GetLearnedStatusStreamUseCase(ref.watch(vocabularyRepositoryProvider));
}

// --- View Models / Status ---

@riverpod
Future<List<VocabularyWord>> vocabularyList(Ref ref) async {
  final useCase = ref.watch(getVocabularyListUseCaseProvider);
  final result = await useCase.call();
  return result.fold((failure) => throw failure, (list) => list);
}

@riverpod
Stream<Set<String>> learnedWordIds(Ref ref) {
  final useCase = ref.watch(getLearnedStatusStreamUseCaseProvider);
  return useCase.call();
}
