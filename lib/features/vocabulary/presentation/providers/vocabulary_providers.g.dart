// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'71e844248268b9e7bd5f5b6480fca9bacdf8e0b1';

@ProviderFor(firestore)
final firestoreProvider = FirestoreProvider._();

final class FirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  FirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'0e25e335c5657f593fc1baf3d9fd026e70bca7fa';

@ProviderFor(firebaseAuth)
final firebaseAuthProvider = FirebaseAuthProvider._();

final class FirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$firebaseAuthHash() => r'912368c3df3f72e4295bf7a8cda93b9c5749d923';

@ProviderFor(vocabularyLocalDataSource)
final vocabularyLocalDataSourceProvider = VocabularyLocalDataSourceProvider._();

final class VocabularyLocalDataSourceProvider
    extends
        $FunctionalProvider<
          VocabularyLocalDataSource,
          VocabularyLocalDataSource,
          VocabularyLocalDataSource
        >
    with $Provider<VocabularyLocalDataSource> {
  VocabularyLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabularyLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabularyLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<VocabularyLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VocabularyLocalDataSource create(Ref ref) {
    return vocabularyLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabularyLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabularyLocalDataSource>(value),
    );
  }
}

String _$vocabularyLocalDataSourceHash() =>
    r'a894b01ed7e69663ff0689ce3a6209448062db43';

@ProviderFor(vocabularyRemoteDataSource)
final vocabularyRemoteDataSourceProvider =
    VocabularyRemoteDataSourceProvider._();

final class VocabularyRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          VocabularyRemoteDataSource,
          VocabularyRemoteDataSource,
          VocabularyRemoteDataSource
        >
    with $Provider<VocabularyRemoteDataSource> {
  VocabularyRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabularyRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabularyRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<VocabularyRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VocabularyRemoteDataSource create(Ref ref) {
    return vocabularyRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabularyRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabularyRemoteDataSource>(value),
    );
  }
}

String _$vocabularyRemoteDataSourceHash() =>
    r'79d21225f5ba5ecda80644bcd404b527153570ee';

@ProviderFor(vocabularyRepository)
final vocabularyRepositoryProvider = VocabularyRepositoryProvider._();

final class VocabularyRepositoryProvider
    extends
        $FunctionalProvider<
          VocabularyRepository,
          VocabularyRepository,
          VocabularyRepository
        >
    with $Provider<VocabularyRepository> {
  VocabularyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabularyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabularyRepositoryHash();

  @$internal
  @override
  $ProviderElement<VocabularyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VocabularyRepository create(Ref ref) {
    return vocabularyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabularyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabularyRepository>(value),
    );
  }
}

String _$vocabularyRepositoryHash() =>
    r'afb5523cc036b405e4dd950cd67d152e1855795b';

@ProviderFor(getVocabularyListUseCase)
final getVocabularyListUseCaseProvider = GetVocabularyListUseCaseProvider._();

final class GetVocabularyListUseCaseProvider
    extends
        $FunctionalProvider<
          GetVocabularyListUseCase,
          GetVocabularyListUseCase,
          GetVocabularyListUseCase
        >
    with $Provider<GetVocabularyListUseCase> {
  GetVocabularyListUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getVocabularyListUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getVocabularyListUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetVocabularyListUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetVocabularyListUseCase create(Ref ref) {
    return getVocabularyListUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetVocabularyListUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetVocabularyListUseCase>(value),
    );
  }
}

String _$getVocabularyListUseCaseHash() =>
    r'e47233f2e5c2e654ce2617efc0cc1f71646572e6';

@ProviderFor(toggleLearnedStatusUseCase)
final toggleLearnedStatusUseCaseProvider =
    ToggleLearnedStatusUseCaseProvider._();

final class ToggleLearnedStatusUseCaseProvider
    extends
        $FunctionalProvider<
          ToggleLearnedStatusUseCase,
          ToggleLearnedStatusUseCase,
          ToggleLearnedStatusUseCase
        >
    with $Provider<ToggleLearnedStatusUseCase> {
  ToggleLearnedStatusUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toggleLearnedStatusUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toggleLearnedStatusUseCaseHash();

  @$internal
  @override
  $ProviderElement<ToggleLearnedStatusUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ToggleLearnedStatusUseCase create(Ref ref) {
    return toggleLearnedStatusUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleLearnedStatusUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleLearnedStatusUseCase>(value),
    );
  }
}

String _$toggleLearnedStatusUseCaseHash() =>
    r'108182212484d89aef10b8e33394f161568eacf2';

@ProviderFor(getLearnedStatusStreamUseCase)
final getLearnedStatusStreamUseCaseProvider =
    GetLearnedStatusStreamUseCaseProvider._();

final class GetLearnedStatusStreamUseCaseProvider
    extends
        $FunctionalProvider<
          GetLearnedStatusStreamUseCase,
          GetLearnedStatusStreamUseCase,
          GetLearnedStatusStreamUseCase
        >
    with $Provider<GetLearnedStatusStreamUseCase> {
  GetLearnedStatusStreamUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getLearnedStatusStreamUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getLearnedStatusStreamUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetLearnedStatusStreamUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetLearnedStatusStreamUseCase create(Ref ref) {
    return getLearnedStatusStreamUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetLearnedStatusStreamUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetLearnedStatusStreamUseCase>(
        value,
      ),
    );
  }
}

String _$getLearnedStatusStreamUseCaseHash() =>
    r'2022f8822413480438b52f3bb40c4959d8574f5d';

@ProviderFor(vocabularyList)
final vocabularyListProvider = VocabularyListProvider._();

final class VocabularyListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VocabularyWord>>,
          List<VocabularyWord>,
          FutureOr<List<VocabularyWord>>
        >
    with
        $FutureModifier<List<VocabularyWord>>,
        $FutureProvider<List<VocabularyWord>> {
  VocabularyListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabularyListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabularyListHash();

  @$internal
  @override
  $FutureProviderElement<List<VocabularyWord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VocabularyWord>> create(Ref ref) {
    return vocabularyList(ref);
  }
}

String _$vocabularyListHash() => r'4d79941a3dd69291278d15db8ded416a1a043247';

@ProviderFor(learnedWordIds)
final learnedWordIdsProvider = LearnedWordIdsProvider._();

final class LearnedWordIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  LearnedWordIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'learnedWordIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$learnedWordIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return learnedWordIds(ref);
  }
}

String _$learnedWordIdsHash() => r'5d92224c6c197d56a234f22de4062eabfe35ab57';
