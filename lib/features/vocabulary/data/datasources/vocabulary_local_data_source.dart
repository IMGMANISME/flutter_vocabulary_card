import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';

abstract class VocabularyLocalDataSource {
  Future<Set<String>> getLearnedWordIds();
  Future<void> cacheLearnedWordIds(Set<String> ids);
  Future<void> toggleLearnedStatus(String wordId);
  bool getHideLearned();
  Future<void> cacheHideLearned(bool value);
}

class VocabularyLocalDataSourceImpl implements VocabularyLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _learnedWordsKey = 'learned_words';

  VocabularyLocalDataSourceImpl({required this.sharedPreferences});

  static const String _hideLearnedKey = 'hide_learned';

  @override
  Future<Set<String>> getLearnedWordIds() async {
    try {
      final List<String>? storedIds = sharedPreferences.getStringList(
        _learnedWordsKey,
      );
      return storedIds?.toSet() ?? {};
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheLearnedWordIds(Set<String> ids) async {
    await sharedPreferences.setStringList(_learnedWordsKey, ids.toList());
  }

  @override
  Future<void> toggleLearnedStatus(String wordId) async {
    final ids = await getLearnedWordIds();
    if (ids.contains(wordId)) {
      ids.remove(wordId);
    } else {
      ids.add(wordId);
    }
    await cacheLearnedWordIds(ids);
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
