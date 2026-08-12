import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/adaptive_button.dart';
import '../../../../shared/widgets/glass_panel.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../di/vocabulary_dependencies.dart';
import '../../presentation/providers/study_session_providers.dart';
import '../providers/vocabulary_providers.dart';
import '../widgets/flashcard_widget.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const Color _pageTop = Color(0xFFF5F8FC);
  // Deepened towards the accent so the floating glass has saturated colour
  // beneath it. On the old near-white bottom the panel measured only ~23
  // levels of lift and read as a flat rectangle.
  static const Color _pageBottom = Color(0xFFBFD8DC);
  static const Color _ink = Color(0xFF15243A);
  static const Color _accent = Color(0xFF0F766E);
  static const Color _accentDeep = Color(0xFF115E59);
  static const Color _panelBorder = Color(0xFFD4DFED);

  // Height of the floating controls, which the card area has to clear. Two
  // values because the letter row disappears in shuffled order.
  static const double _controlsHeight = 138;
  static const double _controlsHeightShuffled = 78;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenAuthController(context, ref);
    final vocabularyListAsync = ref.watch(vocabularyListProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_pageTop, _pageBottom],
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
                  Column(
                    children: [
                      _buildHeaderCard(context, ref, session),
                      Expanded(
                        child: session.hasWords
                            ? _buildCardArea(context, ref, session)
                            : _buildEmptyState(ref),
                      ),
                      if (!session.hasWords) _buildFooter(),
                    ],
                  ),
                  // Floats above the card so the glass has something to
                  // refract — a flat backdrop would render it invisible.
                  if (session.hasWords)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildControls(ref, session),
                    ),
                ],
              );
            },
            loading: () => const _LoadingState(),
            error: (error, stackTrace) => _ErrorState(error: error.toString()),
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
  ) {
    final authState = ref.watch(authStateProvider);
    final authControllerState = ref.watch(authControllerProvider);
    final hideLearned = ref.watch(hideLearnedProvider);
    final isShuffled = ref.watch(shuffleSeedProvider) != null;

    final user = authState.value;
    final isLoading = authState.isLoading || authControllerState.isLoading;
    final progressPercent = (session.progress * 100).round();
    final remainingCount = session.totalCount - session.displayPosition;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: _panelDecoration(radius: 24),
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
                          color: const Color(0xFFECF6F4),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFC9E6E0)),
                        ),
                        child: const Text(
                          'C1 Vocabulary Focus',
                          style: TextStyle(
                            color: Color(0xFF0F766E),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'English Vocabulary Card',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildAuthAction(
                  context,
                  ref,
                  user: user,
                  isLoading: isLoading,
                ),
              ],
            ),
            if (session.hasWords) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6F1),
                  borderRadius: BorderRadius.circular(999),
                ),
                clipBehavior: Clip.antiAlias,
                child: LinearProgressIndicator(
                  value: session.progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Text(
                    '${session.displayPosition}/${session.totalCount}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Flexible so the two chips never get squeezed off the row
                  // once the counts grow to four digits.
                  Flexible(
                    child: Text(
                      '$progressPercent% · $remainingCount left',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ink.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildShuffleChip(ref, isShuffled),
                  const SizedBox(width: 6),
                  _buildHideLearnedChip(ref, hideLearned),
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
    WidgetRef ref, {
    required dynamic user,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _panelBorder),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.2, color: _accent),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F2D48), Color(0xFF0B1220)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              onBackgroundImageError: (exception, stackTrace) {},
              child: user.photoUrl == null
                  ? Text(
                      (user.displayName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await ref.read(authControllerProvider.notifier).signInWithGoogle();
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF25344F), Color(0xFF0F172A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.login_rounded, color: Colors.white, size: 21),
        ),
      ),
    );
  }

  Widget _buildShuffleChip(WidgetRef ref, bool isShuffled) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleShuffle(ref, isShuffled),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isShuffled ? _accentDeep : const Color(0xFFF3F6FA),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isShuffled ? const Color(0xFF0E7A75) : _panelBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isShuffled
                    ? Icons.shuffle_rounded
                    : Icons.sort_by_alpha_rounded,
                size: 14,
                color: isShuffled ? Colors.white : _ink.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 4),
              Text(
                isShuffled ? 'Shuffled' : 'Shuffle',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isShuffled
                      ? Colors.white
                      : _ink.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHideLearnedChip(WidgetRef ref, bool hideLearned) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleHideLearned(ref),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hideLearned ? _accentDeep : const Color(0xFFF3F6FA),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: hideLearned ? const Color(0xFF0E7A75) : _panelBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hideLearned ? Icons.visibility_off_rounded : Icons.visibility,
                size: 14,
                color: hideLearned
                    ? Colors.white
                    : _ink.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 4),
              Text(
                'Hide',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: hideLearned
                      ? Colors.white
                      : _ink.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    final hideLearned = ref.watch(hideLearnedProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: _panelDecoration(radius: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDBEAFE), Color(0xFFE0F2F1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 36,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No words available',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  hideLearned
                      ? 'All words are currently hidden as learned.'
                      : 'Try checking your data source or sync status.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hideLearned) ...[
                  const SizedBox(height: 16),
                  AdaptiveButton(
                    onPressed: () => _toggleHideLearned(ref),
                    isFilled: true,
                    color: _accent,
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
    );
  }

  Widget _buildCardArea(
    BuildContext context,
    WidgetRef ref,
    StudySessionState session,
  ) {
    final currentWord = session.currentWord;
    if (currentWord == null) {
      return const SizedBox();
    }

    final isLearned = session.isCurrentWordLearned;
    final isShuffled = ref.watch(shuffleSeedProvider) != null;
    final controlsHeight = isShuffled
        ? _controlsHeightShuffled
        : _controlsHeight;

    return Padding(
      // Clears the floating controls entirely so the card is never cut off.
      // What the glass refracts is the page backdrop.
      padding: EdgeInsets.fromLTRB(12, 4, 12, controlsHeight + 8),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final scaleAnimation = Tween<double>(
                  begin: 0.96,
                  end: 1,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: scaleAnimation, child: child),
                );
              },
              child: FlashcardWidget(
                key: ValueKey(currentWord.id),
                word: currentWord,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: _buildLearnedButton(
                  context,
                  isLearned: isLearned,
                  compact: true,
                  onTap: () => _toggleLearned(context, ref, currentWord.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnedButton(
    BuildContext context, {
    required bool isLearned,
    required VoidCallback onTap,
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
            color: isLearned ? null : Colors.white,
            gradient: isLearned
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accentDeep, Color(0xFF0F172A)],
                  )
                : null,
            borderRadius: BorderRadius.circular(buttonRadius),
            border: Border.all(
              color: isLearned ? const Color(0xFF0F766E) : _panelBorder,
            ),
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
                color: isLearned ? Colors.white : _ink.withValues(alpha: 0.82),
              ),
              const SizedBox(width: 8),
              Text(
                isLearned ? 'Learned' : 'Mark as Learned',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: isLearned
                      ? Colors.white
                      : _ink.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(WidgetRef ref, StudySessionState session) {
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
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF273A5D),
                                          Color(0xFF0F172A),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : const Color(0xFFF3F7FB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : _panelBorder,
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
                                  color: isSelected ? Colors.white : _ink,
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

  Widget _buildNavigationButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback? onPressed,
  }) {
    final background = isPrimary ? const Color(0xFF111C2E) : Colors.white;
    final foreground = isPrimary ? Colors.white : _ink;

    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: isPrimary
              ? const Color(0xFFA8B6C6)
              : const Color(0xFFF1F5F9),
          disabledForegroundColor: const Color(0xFF9DA8B8),
          elevation: onPressed == null ? 0 : (isPrimary ? 6 : 0),
          shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: _panelBorder),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '© 2025 English Vocabulary Card',
        style: TextStyle(
          color: _ink.withValues(alpha: 0.38),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration({double radius = 20}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF4F8FD)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _panelBorder),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Future<void> _toggleLearned(
    BuildContext context,
    WidgetRef ref,
    String wordId,
  ) async {
    final result = await ref
        .read(toggleLearnedStatusUseCaseProvider)
        .call(wordId);

    result.match((failure) {
      if (!context.mounted) {
        return;
      }

      _showAppDialog(
        context,
        title: 'Unable to update word',
        message: failure.message,
        isError: true,
      );
    }, (_) {});
  }

  Future<void> _toggleHideLearned(WidgetRef ref) async {
    await ref.read(hideLearnedProvider.notifier).toggle();
    ref.read(studyIndexProvider.notifier).reset();
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
                ? TextButton.styleFrom(foregroundColor: Colors.red)
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
              color: const Color(0xFF9CC8E5).withValues(alpha: 0.2),
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
              color: const Color(0xFF9EE6D3).withValues(alpha: 0.2),
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
              color: const Color(0xFF6FB3AA).withValues(alpha: 0.42),
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
              color: const Color(0xFF8FA9E8).withValues(alpha: 0.34),
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: MainScreen._accent),
          SizedBox(height: 12),
          Text(
            'Loading vocabulary...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7D2D2)),
          ),
          child: Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8B1E2C)),
          ),
        ),
      ),
    );
  }
}
