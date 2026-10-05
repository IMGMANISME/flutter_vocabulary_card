import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/adaptive_button.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../presentation/providers/study_session_providers.dart';
import '../providers/vocabulary_providers.dart';
import '../widgets/flashcard_widget.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenAuthController(context, ref);
    final c = context.colors;
    final vocabularyListAsync = ref.watch(vocabularyListProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.pageTop, c.pageBottom],
          ),
        ),
        child: SafeArea(
          child: vocabularyListAsync.when(
            data: (_) {
              final session = ref.watch(studySessionProvider);

              return Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: _DecorativeBackground()),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(20) / 20;
                      final cardHeight =
                          (constraints.maxHeight * 0.5).clamp(300.0, 520.0) *
                          math.min(textScale, 1.5);
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHeaderCard(context, ref, session, c),
                              SizedBox(
                                height: cardHeight,
                                child: session.hasWords
                                    ? _buildCardArea(context, ref, c, session)
                                    : _buildEmptyState(ref, c, session),
                              ),
                              if (session.hasWords)
                                _buildControls(ref, session, c),
                              if (!session.hasWords) _buildFooter(c),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const _LoadingState(),
            error: (error, stackTrace) => _ErrorState(
              onRetry: () => ref.invalidate(vocabularyListProvider),
            ),
          ),
        ),
      ),
    );
  }

  /// Identity and progress share one card: two panels of chrome above a single
  /// flashcard cost more vertical space than the content they describe.
  Widget _buildHeaderCard(
    BuildContext context,
    WidgetRef ref,
    StudySessionState session,
    AppColors c,
  ) {
    final authState = ref.watch(authStateProvider);
    final authControllerState = ref.watch(authControllerProvider);
    final hideLearned = ref.watch(hideLearnedProvider);
    final isShuffled = ref.watch(shuffleSeedProvider) != null;

    final user = authState.value;
    final isLoading = authState.isLoading || authControllerState.isLoading;
    final progressPercent = (session.progress * 100).round();
    final remainingCount = session.remainingCount;
    final learnedAsync = ref.watch(learnedWordIdsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: _panelDecoration(c, radius: 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: c.accentSoftBorder),
                        ),
                        child: Text(
                          'C1 Vocabulary Focus',
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gocab',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                          color: c.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildAuthAction(
                  context,
                  ref,
                  c,
                  user: user,
                  isLoading: isLoading,
                ),
              ],
            ),
            if (session.deckCount > 0) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: c.trackFill,
                  borderRadius: BorderRadius.circular(999),
                ),
                clipBehavior: Clip.antiAlias,
                child: LinearProgressIndicator(
                  value: learnedAsync.isLoading
                      ? null
                      : session.progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    learnedAsync.hasError
                        ? 'Learning progress unavailable'
                        : learnedAsync.isLoading
                        ? 'Loading learning progress…'
                        : '${session.learnedCount}/${session.deckCount} learned · $progressPercent%',
                    style: TextStyle(color: c.ink, fontWeight: FontWeight.w700),
                  ),
                  if (!learnedAsync.isLoading && !learnedAsync.hasError)
                    Text(
                      '$remainingCount to learn',
                      style: TextStyle(color: c.ink.withValues(alpha: 0.7)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (session.hasWords)
                    Text(
                      'Card ${session.displayPosition} of ${session.totalCount}',
                      style: TextStyle(color: c.ink.withValues(alpha: 0.7)),
                    ),
                  _buildShuffleChip(ref, isShuffled, c),
                  _buildHideLearnedChip(ref, hideLearned, c),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthAction(
    BuildContext context,
    WidgetRef ref,
    AppColors c, {
    required AppUser? user,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.panelBorder),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.2, color: c.accent),
        ),
      );
    }

    if (user != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context, ref),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.actionFill, c.actionFillEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: c.panelShadow.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: c.actionFill,
              foregroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              onForegroundImageError: user.photoUrl != null
                  ? (exception, stackTrace) {}
                  : null,
              child: Text(
                user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!.trim()[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // The shadow lives on an outer container, not on the Ink decoration.
    // Ink paints into the ancestor Material's ink layer, where the shadow is
    // rasterised against rectangular bounds — the corner radius is lost and a
    // hard-edged square appears behind the rounded button.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: c.panelShadow.withValues(alpha: 0.24),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            await ref.read(authControllerProvider.notifier).signInWithGoogle();
          },
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.actionFill, c.actionFillEnd],
              ),
            ),
            child: const Icon(
              Icons.login_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShuffleChip(WidgetRef ref, bool isShuffled, AppColors c) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleShuffle(ref, isShuffled),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isShuffled ? c.accentDeep : c.chipFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isShuffled ? c.accentDeep : c.panelBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isShuffled
                    ? Icons.shuffle_rounded
                    : Icons.sort_by_alpha_rounded,
                size: 14,
                color: isShuffled
                    ? Colors.white
                    : c.ink.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  isShuffled ? 'Shuffled' : 'Shuffle',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isShuffled
                        ? Colors.white
                        : c.ink.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHideLearnedChip(WidgetRef ref, bool hideLearned, AppColors c) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleHideLearned(ref),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hideLearned ? c.accentDeep : c.chipFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: hideLearned ? c.accentDeep : c.panelBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hideLearned ? Icons.visibility_off_rounded : Icons.visibility,
                size: 14,
                color: hideLearned
                    ? Colors.white
                    : c.ink.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hideLearned ? 'Show all' : 'Hide learned',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hideLearned
                        ? Colors.white
                        : c.ink.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    WidgetRef ref,
    AppColors c,
    StudySessionState session,
  ) {
    final hideLearned = ref.watch(hideLearnedProvider);
    final isComplete = hideLearned && session.deckCount > 0;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: _panelDecoration(c, radius: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [c.cardBannerStart, c.cardBannerEnd],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.panelShadow.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 36,
                      color: c.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isComplete ? 'All words learned!' : 'No words available',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: c.ink,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isComplete
                        ? 'You have marked every word as learned. Show them again to review.'
                        : 'Try checking your data source or sync status.',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.ink.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isComplete) ...[
                    const SizedBox(height: 16),
                    AdaptiveButton(
                      onPressed: () => _toggleHideLearned(ref),
                      isFilled: true,
                      color: c.accent,
                      textColor: Colors.white,
                      borderRadius: 14,
                      child: const Text('Show learned words'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardArea(
    BuildContext context,
    WidgetRef ref,
    AppColors c,
    StudySessionState session,
  ) {
    final currentWord = session.currentWord;
    if (currentWord == null) {
      return const SizedBox();
    }

    final isLearned = session.isCurrentWordLearned;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: FlashcardWidget(
                key: ValueKey(currentWord.id),
                word: currentWord,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (ref.watch(learnedWordIdsProvider).hasError)
            TextButton.icon(
              onPressed: () => ref.invalidate(learnedWordIdsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry loading learning progress'),
            )
          else if (ref.watch(learnedWordIdsProvider).isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Loading learning progress…'),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: _buildLearnedButton(
                context,
                c,
                isLearned: isLearned,
                isUpdating: ref
                    .watch(learnedStatusControllerProvider)
                    .contains(currentWord.id),
                compact: true,
                onTap:
                    ref
                        .watch(learnedStatusControllerProvider)
                        .contains(currentWord.id)
                    ? null
                    : () => _setLearned(
                        context,
                        ref,
                        wordId: currentWord.id,
                        wordLabel: currentWord.word,
                        isLearned: !isLearned,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLearnedButton(
    BuildContext context,
    AppColors c, {
    required bool isLearned,
    required VoidCallback? onTap,
    bool isUpdating = false,
    bool compact = false,
  }) {
    final buttonRadius = compact ? 16.0 : 20.0;
    final verticalPadding = compact ? 11.0 : 16.0;
    final horizontalPadding = compact ? 16.0 : 22.0;
    final iconSize = compact ? 18.0 : 20.0;
    final fontSize = compact ? 13.0 : 15.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(buttonRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isLearned ? null : c.panel,
            gradient: isLearned
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.accentDeep, c.actionFillEnd],
                  )
                : null,
            borderRadius: BorderRadius.circular(buttonRadius),
            border: Border.all(color: isLearned ? c.accent : c.panelBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF0F172A,
                ).withValues(alpha: isLearned ? 0.22 : 0.08),
                blurRadius: compact ? 10 : (isLearned ? 18 : 12),
                offset: Offset(0, compact ? 5 : 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLearned ? Icons.check_rounded : Icons.circle_outlined,
                size: iconSize,
                color: isLearned ? Colors.white : c.ink.withValues(alpha: 0.82),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isUpdating
                      ? 'Saving…'
                      : (isLearned ? 'Learned' : 'Mark as Learned'),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: isLearned
                        ? Colors.white
                        : c.ink.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(WidgetRef ref, StudySessionState session, AppColors c) {
    // Alphabetical jumping has no meaning once the deck is shuffled, so the
    // letter row goes away and the panel shrinks with it.
    final isShuffled = ref.watch(shuffleSeedProvider) != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Stack(
        children: [
          // Translucent surface. Sits underneath so the controls below
          // composite on top of it.
          const Positioned.fill(child: GlassPanel(cornerRadius: 26)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isShuffled)
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: session.availableLetters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final letter = session.availableLetters[index];
                        final isSelected =
                            session.currentWord?.word.toUpperCase().startsWith(
                              letter,
                            ) ??
                            false;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final targetIndex =
                                  session.letterIndexMap[letter];
                              if (targetIndex == null) {
                                return;
                              }

                              ref
                                  .read(studyIndexProvider.notifier)
                                  .jumpTo(targetIndex);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [c.actionFill, c.actionFillEnd],
                                      )
                                    : null,
                                color: isSelected ? null : c.chipFill,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : c.panelBorder,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF0F172A,
                                          ).withValues(alpha: 0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : c.ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (!isShuffled) const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNavigationButton(
                        c,
                        label: 'Previous',
                        icon: Icons.arrow_back_rounded,
                        isPrimary: false,
                        onPressed: session.isAtStart
                            ? null
                            : () {
                                ref
                                    .read(studyIndexProvider.notifier)
                                    .previous(session.currentIndex);
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNavigationButton(
                        c,
                        label: 'Next',
                        icon: Icons.arrow_forward_rounded,
                        isPrimary: true,
                        onPressed: session.isAtEnd
                            ? null
                            : () {
                                ref
                                    .read(studyIndexProvider.notifier)
                                    .next(
                                      currentIndex: session.currentIndex,
                                      totalCount: session.totalCount,
                                    );
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    AppColors c, {
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback? onPressed,
  }) {
    final background = isPrimary ? c.actionFillEnd : c.panel;
    final foreground = isPrimary ? Colors.white : c.ink;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 46),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: isPrimary
              ? c.actionDisabledInk
              : c.actionDisabled,
          disabledForegroundColor: c.actionDisabledInk,
          elevation: onPressed == null ? 0 : (isPrimary ? 6 : 0),
          shadowColor: c.panelShadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: c.panelBorder),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '© 2025 English Vocabulary Card',
        style: TextStyle(
          color: c.ink.withValues(alpha: 0.38),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration(AppColors c, {double radius = 20}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c.panel, c.cardFaceBottom],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: c.panelBorder),
      boxShadow: [
        BoxShadow(
          color: c.panelShadow.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Future<bool> _setLearned(
    BuildContext context,
    WidgetRef ref, {
    required String wordId,
    required String wordLabel,
    required bool isLearned,
    bool offerUndo = true,
  }) async {
    final userId = ref.read(authStateProvider).value?.id;
    final previousIndex = ref.read(studySessionProvider).currentIndex;
    final result = await ref
        .read(learnedStatusControllerProvider.notifier)
        .setStatus(wordId: wordId, isLearned: isLearned);

    if (!context.mounted || ref.read(authStateProvider).value?.id != userId) {
      return false;
    }

    return result.match(
      (failure) {
        _showAppDialog(
          context,
          title: 'Unable to update word',
          message: failure.message,
          isError: true,
        );
        return false;
      },
      (_) {
        if (offerUndo) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                isLearned
                    ? '$wordLabel marked as learned'
                    : '$wordLabel marked as not learned',
              ),
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  if (!context.mounted) return;
                  if (ref.read(authStateProvider).value?.id != userId) return;
                  final restored = await _setLearned(
                    context,
                    ref,
                    wordId: wordId,
                    wordLabel: wordLabel,
                    isLearned: !isLearned,
                    offerUndo: false,
                  );
                  if (restored && context.mounted) {
                    final restoredIndex = ref
                        .read(studySessionProvider)
                        .words
                        .indexWhere((word) => word.id == wordId);
                    ref
                        .read(studyIndexProvider.notifier)
                        .jumpTo(
                          restoredIndex >= 0 ? restoredIndex : previousIndex,
                        );
                  }
                },
              ),
            ),
          );
        }
        return true;
      },
    );
  }

  Future<void> _toggleHideLearned(WidgetRef ref) async {
    final current = ref.read(studySessionProvider);
    final save = ref.read(hideLearnedProvider.notifier).toggle();
    final next = ref.read(studySessionProvider);
    final retainedIndex = next.words.indexWhere(
      (word) => word.id == current.currentWord?.id,
    );
    ref
        .read(studyIndexProvider.notifier)
        .jumpTo(retainedIndex >= 0 ? retainedIndex : current.currentIndex);
    await save;
  }

  void _toggleShuffle(WidgetRef ref, bool isShuffled) {
    final controller = ref.read(shuffleSeedProvider.notifier);
    if (isShuffled) {
      controller.restoreOrder();
    } else {
      controller.shuffle();
    }
    // The index points into the old ordering, so keeping it would drop the
    // reader at an unrelated word.
    ref.read(studyIndexProvider.notifier).reset();
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isIOS = _isCupertinoPlatform(context);

    final content = const Text('Are you sure you want to log out?');

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: content,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authControllerProvider.notifier).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Logout'),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authControllerProvider.notifier).signOut();
              },
              style: TextButton.styleFrom(foregroundColor: c.danger),
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }
  }

  void _listenAuthController(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!context.mounted) {
        return;
      }

      if (next.hasError) {
        final message = _formatError(next.error);

        _showAppDialog(
          context,
          title: 'Authentication error',
          message: message,
          isError: true,
        );
        return;
      }

      if (previous?.isLoading == true && next is AsyncData<void>) {
        final user = ref.read(authStateProvider).value;
        final title = user == null ? 'Signed out' : 'Signed in';
        final message = user == null
            ? 'You are now signed out.'
            : 'Signed in successfully.';

        _showAppDialog(context, title: title, message: message);
      }
    });
  }

  bool _isCupertinoPlatform(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
  }

  void _showAppDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
  }) {
    final c = context.colors;

    if (_isCupertinoPlatform(context)) {
      showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              isDestructiveAction: isError,
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: isError
                ? TextButton.styleFrom(foregroundColor: c.danger)
                : null,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatError(Object? error) {
    if (error == null) {
      return 'Unknown authentication error';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}

class _DecorativeBackground extends StatelessWidget {
  const _DecorativeBackground();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.blobTop.withValues(alpha: 0.2),
            ),
          ),
        ),
        Positioned(
          top: 90,
          left: -80,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.blobMid.withValues(alpha: 0.2),
            ),
          ),
        ),
        // Two overlapping blobs sit directly under the floating controls.
        // Refraction only shows where the backdrop varies, so the bottom of
        // the page carries the colour rather than the top.
        Positioned(
          bottom: -70,
          right: -50,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.blobBottomA.withValues(alpha: 0.42),
            ),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -60,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.blobBottomB.withValues(alpha: 0.34),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: context.colors.accent),
          const SizedBox(height: 12),
          const Text(
            'Loading vocabulary...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.dangerSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.dangerBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load vocabulary',
                style: TextStyle(color: c.danger, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your connection and try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
