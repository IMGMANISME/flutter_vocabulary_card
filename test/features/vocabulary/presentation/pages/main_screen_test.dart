import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vocabulary_card/config/theme/app_colors.dart';
import 'package:flutter_vocabulary_card/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/di/vocabulary_dependencies.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/presentation/pages/main_screen.dart';
import 'package:flutter_vocabulary_card/features/vocabulary/presentation/providers/study_session_providers.dart';

import '../../data/repositories/vocabulary_repository_impl_test.dart' as fakes;

const _deck = [
  VocabularyModel(
    id: '1',
    word: 'accountable',
    partOfSpeech: 'adjective',
    definition: 'Expected to explain decisions and accept responsibility.',
    example: 'The manager is accountable to the board for the budget.',
    chineseTranslation: '須負責並作出說明的',
    usageNote:
        'Accountable to names who you answer to; accountable for names the action.',
    sourceUrl:
        'https://dictionary.cambridge.org/us/dictionary/english/accountable',
  ),
  VocabularyModel(
    id: '2',
    word: 'critical',
    partOfSpeech: 'adjective',
    definition: 'Extremely important to the outcome of something.',
    example: 'Evidence is critical to a fair decision.',
    chineseTranslation: '關鍵的',
  ),
];

Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  bool hideLearned = false,
  double textScale = 1,
  List<VocabularyModel> cachedDeck = _deck,
  fakes.FakeVocabularyRemoteDataSource? remoteSource,
  fakes.FakeVocabularyLocalDataSource? localSource,
}) async {
  final local =
      localSource ??
      fakes.FakeVocabularyLocalDataSource(
        seededList: cachedDeck,
        hideLearned: hideLearned,
      );
  final remote = (remoteSource ?? fakes.FakeVocabularyRemoteDataSource())
    ..remoteList = _deck;
  final repository = VocabularyRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
  final container = ProviderContainer(
    overrides: [
      vocabularyRepositoryProvider.overrideWithValue(repository),
      authStateProvider.overrideWith((ref) => Stream.value(null)),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await local.dispose();
    await remote.dispose();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.macOS,
          extensions: const [AppColors.light],
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const MainScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets(
    'marking and undo restore a hidden card and learning progress',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = await _pumpApp(tester, hideLearned: true);
      expect(find.text('0/2 learned · 0%'), findsOneWidget);

      await tester.tap(find.text('Mark as Learned'));
      await tester.pumpAndSettle();
      expect(container.read(studySessionProvider).currentWord?.id, '2');
      expect(find.text('1/2 learned · 50%'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(container.read(studySessionProvider).currentWord?.id, '1');
      expect(find.text('0/2 learned · 0%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );

  testWidgets(
    'changing the filter keeps the current word',
    (tester) async {
      final container = await _pumpApp(tester);
      container.read(studyIndexProvider.notifier).jumpTo(1);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide learned'));
      await tester.pumpAndSettle();
      expect(container.read(studySessionProvider).currentWord?.id, '2');
      expect(find.text('Show all'), findsOneWidget);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );

  testWidgets(
    'failed vocabulary loading can be retried',
    (tester) async {
      final remote = fakes.FakeVocabularyRemoteDataSource()
        ..failVocabularyList = true;
      await _pumpApp(tester, cachedDeck: const [], remoteSource: remote);
      expect(find.text('Unable to load vocabulary'), findsOneWidget);
      remote.failVocabularyList = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('0/2 learned · 0%'), findsOneWidget);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );

  testWidgets(
    'a completed deck shows full progress and can be reviewed',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pumpApp(
        tester,
        localSource: fakes.FakeVocabularyLocalDataSource(
          seededList: _deck,
          seededIds: {'1', '2'},
          hideLearned: true,
        ),
      );
      expect(find.text('2/2 learned · 100%'), findsOneWidget);
      expect(find.text('All words learned!'), findsOneWidget);
      await tester.ensureVisible(find.text('Show learned words'));
      await tester.tap(find.text('Show learned words'));
      await tester.pumpAndSettle();
      expect(find.byType(FlipCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );

  testWidgets(
    'a pending word update ignores repeat taps',
    (tester) async {
      final local = _DelayedLocalDataSource();
      addTearDown(() {
        if (!local.gate.isCompleted) local.gate.complete();
      });
      await _pumpApp(tester, localSource: local);
      await tester.tap(find.text('Mark as Learned'));
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      await tester.tap(find.text('Saving…'));
      await tester.pump();
      expect(local.calls, 1);
      local.gate.complete();
      await tester.pumpAndSettle();
      expect(find.text('1/2 learned · 50%'), findsOneWidget);
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );

  for (final textScale in [1.0, 1.5, 2.0]) {
    testWidgets(
      'small screen supports scrolling the card at text scale $textScale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pumpApp(tester, textScale: textScale);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(FlipCard));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FlipCard));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.state<FlipCardState>(find.byType(FlipCard)).isFront,
          false,
        );
        expect(find.text('USAGE NOTE'), findsOneWidget);
      },
      variant: TargetPlatformVariant({TargetPlatform.macOS}),
    );
  }
}

class _DelayedLocalDataSource extends fakes.FakeVocabularyLocalDataSource {
  final gate = Completer<void>();
  int calls = 0;

  _DelayedLocalDataSource() : super(seededList: _deck);

  @override
  Future<void> setLearnedStatus({
    required String wordId,
    required bool isLearned,
  }) async {
    calls++;
    await gate.future;
    await super.setLearnedStatus(wordId: wordId, isLearned: isLearned);
  }
}
