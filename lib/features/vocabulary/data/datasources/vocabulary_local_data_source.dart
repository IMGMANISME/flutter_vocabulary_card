import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';

abstract class VocabularyLocalDataSource {
  Future<Set<String>> getLearnedWordIds();

  Stream<Set<String>> getLearnedWordIdsStream();

  Future<void> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  });

  bool getHideLearned();

  Future<void> cacheHideLearned(bool value);
}

class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _learnedWordsKey = 'learned_words';
  static const String _hideLearnedKey = 'hide_learned';

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
  bool getHideLearned() {
    return sharedPreferences.getBool(_hideLearnedKey) ?? false;
  }

  @override
  Future<void> cacheHideLearned(bool value) async {
    await sharedPreferences.setBool(_hideLearnedKey, value);
  }
}
