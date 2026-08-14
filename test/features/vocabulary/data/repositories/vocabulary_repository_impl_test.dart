import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_vocabulary_card/core/errors/exceptions.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/datasources/vocabulary_local_data_source.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/datasources/vocabulary_remote_data_source.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';

class FakeVocabularyLocalDataSource implements VocabularyLocalDataSource {
  final Set<String> _ids;
  bool _hideLearned;
  int setCallCount = 0;
  String? lastSetWordId;
  bool? lastSetIsLearned;

  List<VocabularyModel> cachedList;
  final Map<String, Set<String>> remoteMirror;
  int studyIndex;
  int? shuffleSeed;

  final _idsController = StreamController<Set<String>>.broadcast();

  FakeVocabularyLocalDataSource({
    Set<String>? seededIds,
    bool hideLearned = false,
    List<VocabularyModel>? seededList,
    Map<String, Set<String>>? seededRemoteMirror,
    this.studyIndex = 0,
    this.shuffleSeed,
  }) : _ids = Set<String>.from(seededIds ?? <String>{}),
       _hideLearned = hideLearned,
       cachedList = seededList ?? const <VocabularyModel>[],
       remoteMirror = seededRemoteMirror ?? <String, Set<String>>{};

  @override
  Future<Set<String>> getLearnedWordIds() async => Set<String>.from(_ids);

  @override
  Stream<Set<String>> getLearnedWordIdsStream() async* {
    yield Set<String>.from(_ids);
    yield* _idsController.stream;
  }

  @override
  Future<void> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  }) async {
    setCallCount += 1;
    lastSetWordId = wordId;
    lastSetIsLearned = isLearned;

    if (isLearned) {
      _ids.add(wordId);
    } else {
      _ids.remove(wordId);
    }
    _idsController.add(Set<String>.from(_ids));
  }

  @override
  List<VocabularyModel> getCachedVocabularyList() => cachedList;

  @override
  Future<void> cacheVocabularyList(List<VocabularyModel> words) async {
    cachedList = List<VocabularyModel>.from(words);
  }

  @override
  Set<String> getCachedRemoteLearnedIds(String userId) {
    return Set<String>.from(remoteMirror[userId] ?? <String>{});
  }

  @override
  Future<void> cacheRemoteLearnedIds(String userId, Set<String> ids) async {
    remoteMirror[userId] = Set<String>.from(ids);
  }

  @override
  int getStudyIndex() => studyIndex;

  @override
  Future<void> cacheStudyIndex(int index) async {
    studyIndex = index;
  }

  @override
  int? getShuffleSeed() => shuffleSeed;

  @override
  Future<void> cacheShuffleSeed(int? seed) async {
    shuffleSeed = seed;
  }

  @override
  bool getHideLearned() => _hideLearned;

  @override
  Future<void> cacheHideLearned(bool value) async {
    _hideLearned = value;
  }

  Future<void> dispose() async {
    await _idsController.close();
  }
}

class FakeVocabularyRemoteDataSource implements VocabularyRemoteDataSource {
  String? _currentUserId;
  Set<String> _remoteIds;

  List<VocabularyModel> remoteList = const <VocabularyModel>[];
  bool failVocabularyList = false;

  int setCallCount = 0;
  String? lastSetUserId;
  String? lastSetWordId;
  bool? lastSetIsLearned;

  final _userIdController = StreamController<String?>.broadcast();
  final _remoteIdsController = StreamController<Set<String>>.broadcast();

  FakeVocabularyRemoteDataSource({
    String? seededUserId,
    Set<String>? seededRemoteIds,
  }) : _currentUserId = seededUserId,
       _remoteIds = Set<String>.from(seededRemoteIds ?? <String>{});

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<String?> userIdChanges() async* {
    yield _currentUserId;
    yield* _userIdController.stream;
  }

  @override
  Future<List<VocabularyModel>> getVocabularyList() async {
    if (failVocabularyList) {
      throw ServerException('offline');
    }

    return remoteList;
  }

  @override
  Stream<Set<String>> watchLearnedWordIds(String userId) async* {
    yield Set<String>.from(_remoteIds);
    yield* _remoteIdsController.stream;
  }

  @override
  Future<void> setLearnedStatus({
    required String userId,
    required String wordId,
    required bool isLearned,
  }) async {
    setCallCount += 1;
    lastSetUserId = userId;
    lastSetWordId = wordId;
    lastSetIsLearned = isLearned;

    if (isLearned) {
      _remoteIds.add(wordId);
    } else {
      _remoteIds.remove(wordId);
    }

    _remoteIdsController.add(Set<String>.from(_remoteIds));
  }

  void emitUserId(String? userId) {
    _currentUserId = userId;
    _userIdController.add(userId);
  }

  void emitRemoteIds(Set<String> ids) {
    _remoteIds = Set<String>.from(ids);
    _remoteIdsController.add(Set<String>.from(_remoteIds));
  }

  Future<void> dispose() async {
    await _userIdController.close();
    await _remoteIdsController.close();
  }
}

void main() {
  group('VocabularyRepositoryImpl', () {
    test('uses local stream when user is logged out', () async {
      final local = FakeVocabularyLocalDataSource(seededIds: {'local_word'});
      final remote = FakeVocabularyRemoteDataSource(seededUserId: null);

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      await expectLater(
        repository.getLearnedWordIdsStream(),
        emitsInOrder([
          {'local_word'},
        ]),
      );

      await local.dispose();
      await remote.dispose();
    });

    test('switches to remote stream after login', () async {
      final local = FakeVocabularyLocalDataSource(seededIds: {'local_word'});
      final remote = FakeVocabularyRemoteDataSource(
        seededUserId: null,
        seededRemoteIds: {'remote_word'},
      );

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final expectation = expectLater(
        repository.getLearnedWordIdsStream(),
        emitsInOrder([
          {'local_word'},
          {'remote_word'},
        ]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      remote.emitUserId('user_1');
      await expectation;

      await local.dispose();
      await remote.dispose();
    });

    test('setLearnedStatus uses local datasource when logged out', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(seededUserId: null);

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      await repository.setLearnedStatus(wordId: 'word_1', isLearned: true);

      expect(local.setCallCount, 1);
      expect(local.lastSetWordId, 'word_1');
      expect(local.lastSetIsLearned, true);
      expect(remote.setCallCount, 0);

      await local.dispose();
      await remote.dispose();
    });

    test('setLearnedStatus uses remote datasource when logged in', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(seededUserId: 'user_1');

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      await repository.setLearnedStatus(wordId: 'word_1', isLearned: true);

      expect(local.setCallCount, 0);
      expect(remote.setCallCount, 1);
      expect(remote.lastSetUserId, 'user_1');
      expect(remote.lastSetWordId, 'word_1');
      expect(remote.lastSetIsLearned, true);

      await local.dispose();
      await remote.dispose();
    });
    test('caches the fetched word list', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(seededUserId: null)
        ..remoteList = [_word('word_1')];

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.getVocabularyList();

      expect(result.isRight(), isTrue);
      expect(local.cachedList.single.id, 'word_1');

      await local.dispose();
      await remote.dispose();
    });

    test('falls back to the cached list when the fetch fails', () async {
      final local = FakeVocabularyLocalDataSource(
        seededList: [_word('cached_word')],
      );
      final remote = FakeVocabularyRemoteDataSource(seededUserId: null)
        ..failVocabularyList = true;

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.getVocabularyList();

      expect(
        result.getOrElse((_) => const []).single.id,
        'cached_word',
      );

      await local.dispose();
      await remote.dispose();
    });

    test('fails when the fetch fails and nothing is cached', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(seededUserId: null)
        ..failVocabularyList = true;

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final result = await repository.getVocabularyList();

      expect(result.isLeft(), isTrue);

      await local.dispose();
      await remote.dispose();
    });

    test('emits the mirrored ids before the remote stream answers', () async {
      final local = FakeVocabularyLocalDataSource(
        seededRemoteMirror: {
          'user_1': {'mirrored_word'},
        },
      );
      final remote = FakeVocabularyRemoteDataSource(
        seededUserId: 'user_1',
        seededRemoteIds: {'remote_word'},
      );

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      await expectLater(
        repository.getLearnedWordIdsStream(),
        emitsInOrder([
          {'mirrored_word'},
          {'remote_word'},
        ]),
      );

      await local.dispose();
      await remote.dispose();
    });

    test('mirrors remote ids into the local cache', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(
        seededUserId: 'user_1',
        seededRemoteIds: {'remote_word'},
      );

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final subscription = repository.getLearnedWordIdsStream().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(local.remoteMirror['user_1'], {'remote_word'});

      await subscription.cancel();
      await local.dispose();
      await remote.dispose();
    });
  });
}

VocabularyModel _word(String id) {
  return VocabularyModel(
    id: id,
    word: id,
    partOfSpeech: 'noun',
    definition: 'definition',
    example: 'example',
    chineseTranslation: 'translation',
  );
}
