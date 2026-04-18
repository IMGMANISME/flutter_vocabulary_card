import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_vocabulary_card/features/vocabulary/data/datasources/vocabulary_local_data_source.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/datasources/vocabulary_remote_data_source.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';

class FakeVocabularyLocalDataSource implements VocabularyLocalDataSource {
  final Set<String> _ids;
  bool _hideLearned;
  int toggleCallCount = 0;

  final _idsController = StreamController<Set<String>>.broadcast();

  FakeVocabularyLocalDataSource({
    Set<String>? seededIds,
    bool hideLearned = false,
  }) : _ids = Set<String>.from(seededIds ?? <String>{}),
       _hideLearned = hideLearned;

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
    if (isLearned) {
      _ids.add(wordId);
    } else {
      _ids.remove(wordId);
    }
    _idsController.add(Set<String>.from(_ids));
  }

  @override
  Future<void> toggleLearnedStatus(String wordId) async {
    toggleCallCount += 1;

    if (_ids.contains(wordId)) {
      _ids.remove(wordId);
    } else {
      _ids.add(wordId);
    }

    _idsController.add(Set<String>.from(_ids));
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

  int toggleCallCount = 0;
  String? lastToggleUserId;
  String? lastToggleWordId;

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
    return const <VocabularyModel>[];
  }

  @override
  Stream<Set<String>> watchLearnedWordIds(String userId) async* {
    yield Set<String>.from(_remoteIds);
    yield* _remoteIdsController.stream;
  }

  @override
  Future<void> toggleLearnedStatus({
    required String userId,
    required String wordId,
  }) async {
    toggleCallCount += 1;
    lastToggleUserId = userId;
    lastToggleWordId = wordId;

    if (_remoteIds.contains(wordId)) {
      _remoteIds.remove(wordId);
    } else {
      _remoteIds.add(wordId);
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

    test('toggleLearnedStatus uses local datasource when logged out', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(seededUserId: null);

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      await repository.toggleLearnedStatus('word_1');

      expect(local.toggleCallCount, 1);
      expect(remote.toggleCallCount, 0);

      await local.dispose();
      await remote.dispose();
    });

    test('toggleLearnedStatus uses remote datasource when logged in', () async {
      final local = FakeVocabularyLocalDataSource();
      final remote = FakeVocabularyRemoteDataSource(seededUserId: 'user_1');

      final repository = VocabularyRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      await repository.toggleLearnedStatus('word_1');

      expect(local.toggleCallCount, 0);
      expect(remote.toggleCallCount, 1);
      expect(remote.lastToggleUserId, 'user_1');
      expect(remote.lastToggleWordId, 'word_1');

      await local.dispose();
      await remote.dispose();
    });
  });
}
