import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/vocabulary_model.dart';

abstract class VocabularyLocalDataSource {
  Future<Set<String>> getLearnedWordIds();

  Stream<Set<String>> getLearnedWordIdsStream();

  Future<void> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  });

  /// Last known word list, so a cold start paints before the network answers
  /// — and still paints when it never does.
  List<VocabularyModel> getCachedVocabularyList();

  Future<void> cacheVocabularyList(List<VocabularyModel> words);

  /// Mirror of the signed-in user's learned set, kept per user so switching
  /// accounts never shows the previous one's progress.
  Set<String> getCachedRemoteLearnedIds(String userId);

  Future<void> cacheRemoteLearnedIds(String userId, Set<String> ids);

  int getStudyIndex();

  Future<void> cacheStudyIndex(int index);

  int? getShuffleSeed();

  Future<void> cacheShuffleSeed(int? seed);

  bool getHideLearned();

  Future<void> cacheHideLearned(bool value);
}

class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _learnedWordsKey = 'learned_words';
  static const String _hideLearnedKey = 'hide_learned';
  static const String _vocabularyListKey = 'vocabulary_list';
  static const String _remoteLearnedWordsPrefix = 'learned_words_remote_';
  static const String _studyIndexKey = 'study_index';
  static const String _shuffleSeedKey = 'shuffle_seed';

  final BehaviorSubject<Set<String>> _learnedIdsSubject =
      BehaviorSubject<Set<String>>.seeded(<String>{});

  VocabularyLocalDataSourceImpl({required this.sharedPreferences}) {
    _learnedIdsSubject.add(_readLearnedWordIds());
  }

  Set<String> _readLearnedWordIds() {
    final storedIds = sharedPreferences.getStringList(_learnedWordsKey);
    return storedIds?.toSet() ?? <String>{};
  }

  @override
  Future<Set<String>> getLearnedWordIds() async {
    try {
      return _readLearnedWordIds();
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Stream<Set<String>> getLearnedWordIdsStream() {
    return _learnedIdsSubject.stream;
  }

  @override
  Future<void> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  }) async {
    final ids = await getLearnedWordIds();

    if (isLearned) {
      ids.add(wordId);
    } else {
      ids.remove(wordId);
    }

    await _persistLearnedIds(ids);
  }

  Future<void> _persistLearnedIds(Set<String> ids) async {
    try {
      await sharedPreferences.setStringList(_learnedWordsKey, ids.toList());
      _learnedIdsSubject.add(Set<String>.from(ids));
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  List<VocabularyModel> getCachedVocabularyList() {
    final stored = sharedPreferences.getString(_vocabularyListKey);
    if (stored == null || stored.isEmpty) {
      return const <VocabularyModel>[];
    }

    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      return decoded
          .map(
            (entry) => VocabularyModel.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
    } catch (error) {
      // A cache written by an older schema is worth less than a clean fetch,
      // so drop it rather than failing the launch.
      return const <VocabularyModel>[];
    }
  }

  @override
  Future<void> cacheVocabularyList(List<VocabularyModel> words) async {
    try {
      final encoded = jsonEncode(words.map((word) => word.toJson()).toList());
      await sharedPreferences.setString(_vocabularyListKey, encoded);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Set<String> getCachedRemoteLearnedIds(String userId) {
    final storedIds = sharedPreferences.getStringList(
      '$_remoteLearnedWordsPrefix$userId',
    );

    return storedIds?.toSet() ?? <String>{};
  }

  @override
  Future<void> cacheRemoteLearnedIds(String userId, Set<String> ids) async {
    try {
      await sharedPreferences.setStringList(
        '$_remoteLearnedWordsPrefix$userId',
        ids.toList(),
      );
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  int getStudyIndex() {
    return sharedPreferences.getInt(_studyIndexKey) ?? 0;
  }

  @override
  Future<void> cacheStudyIndex(int index) async {
    await sharedPreferences.setInt(_studyIndexKey, index);
  }

  @override
  int? getShuffleSeed() {
    return sharedPreferences.getInt(_shuffleSeedKey);
  }

  @override
  Future<void> cacheShuffleSeed(int? seed) async {
    if (seed == null) {
      await sharedPreferences.remove(_shuffleSeedKey);
      return;
    }

    await sharedPreferences.setInt(_shuffleSeedKey, seed);
  }

  @override
  bool getHideLearned() {
    return sharedPreferences.getBool(_hideLearnedKey) ?? false;
  }

  @override
  Future<void> cacheHideLearned(bool value) async {
    await sharedPreferences.setBool(_hideLearnedKey, value);
  }
}
