import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/datasources/vocabulary_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('concurrent guest additions preserve all IDs across restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final source = VocabularyLocalDataSourceImpl(sharedPreferences: prefs);
    await Future.wait([
      source.setLearnedStatus(wordId: 'a', isLearned: true),
      source.setLearnedStatus(wordId: 'b', isLearned: true),
      source.setLearnedStatus(wordId: 'c', isLearned: true),
    ]);
    expect(await source.getLearnedWordIds(), {'a', 'b', 'c'});
    final restarted = VocabularyLocalDataSourceImpl(sharedPreferences: prefs);
    expect(await restarted.getLearnedWordIds(), {'a', 'b', 'c'});
    await source.dispose();
    await restarted.dispose();
  });

  test(
    'queued additions and removals preserve their invocation order',
    () async {
      SharedPreferences.setMockInitialValues({
        'learned_words': ['a', 'existing'],
      });
      final prefs = await SharedPreferences.getInstance();
      final source = VocabularyLocalDataSourceImpl(sharedPreferences: prefs);
      final updates = <Set<String>>[];
      final subscription = source.getLearnedWordIdsStream().listen(updates.add);
      await Future.wait([
        source.setLearnedStatus(wordId: 'a', isLearned: false),
        source.setLearnedStatus(wordId: 'b', isLearned: true),
        source.setLearnedStatus(wordId: 'b', isLearned: false),
        source.setLearnedStatus(wordId: 'c', isLearned: true),
      ]);
      expect(await source.getLearnedWordIds(), {'existing', 'c'});
      await Future<void>.delayed(Duration.zero);
      expect(updates, [
        {'a', 'existing'},
        {'existing'},
        {'existing', 'b'},
        {'existing'},
        {'existing', 'c'},
      ]);
      await subscription.cancel();
      await source.dispose();
    },
  );
}
