import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/adaptive_button.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../di/vocabulary_dependencies.dart';
import '../../presentation/providers/study_session_providers.dart';
import '../providers/vocabulary_providers.dart';
import '../widgets/flashcard_widget.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenAuthController(context, ref);
    final vocabularyListAsync = ref.watch(vocabularyListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: vocabularyListAsync.when(
          data: (_) {
            final session = ref.watch(studySessionProvider);

            return Column(
              children: [
                _buildHeader(context, ref),
                if (session.hasWords) _buildProgressBar(ref, session),
                Expanded(
                  child: session.hasWords
                      ? _buildCardArea(context, ref, session)
                      : _buildEmptyState(ref),
                ),
                if (session.hasWords) _buildControls(ref, session),
                _buildFooter(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authControllerState = ref.watch(authControllerProvider);

    final user = authState.value;
    final isLoading = authState.isLoading || authControllerState.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                const Text(
                  'English Vocabulary Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Learn C1 CEFR vocabulary words',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  _authStatusLabel(user: user, isLoading: isLoading),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user != null ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : user != null
                ? InkWell(
                    onTap: () => _showLogoutDialog(context, ref),
                    borderRadius: BorderRadius.circular(16),
                    child: CircleAvatar(
                      radius: 16,
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
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                  )
                : AdaptiveButton(
                    onPressed: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .signInWithGoogle();
                    },
                    isFilled: false,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.login,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(WidgetRef ref, StudySessionState session) {
    final hideLearned = ref.watch(hideLearnedProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Progress ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '(${session.displayPosition}/${session.totalCount})',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _toggleHideLearned(ref),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hideLearned ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hideLearned
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 14,
                          color: hideLearned ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hide Learned',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hideLearned
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: session.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[800]!),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    final hideLearned = ref.watch(hideLearnedProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📚', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No words available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (hideLearned)
            AdaptiveButton(
              onPressed: () => _toggleHideLearned(ref),
              isFilled: false,
              textColor: Colors.grey[600],
              child: const Text('Show learned words'),
            ),
        ],
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: FlashcardWidget(
              key: ValueKey(currentWord.id),
              word: currentWord,
            ),
          ),
          const SizedBox(height: 24),
          AdaptiveButton(
            onPressed: () => _toggleLearned(context, ref, currentWord.id),
            icon: Icon(
              isLearned ? Icons.check : Icons.circle_outlined,
              size: 20,
            ),
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            color: isLearned ? Colors.grey[900] : Colors.white,
            textColor: isLearned ? Colors.white : Colors.grey[700],
            child: Text(isLearned ? 'Learned' : 'Mark as Learned'),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(WidgetRef ref, StudySessionState session) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: session.availableLetters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final letter = session.availableLetters[index];
              final isSelected =
                  session.currentWord?.word.toUpperCase().startsWith(letter) ??
                  false;

              return InkWell(
                onTap: () {
                  final targetIndex = session.letterIndexMap[letter];
                  if (targetIndex == null) {
                    return;
                  }

                  ref.read(studyIndexProvider.notifier).jumpTo(targetIndex);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  onPressed: session.isAtStart
                      ? null
                      : () {
                          ref
                              .read(studyIndexProvider.notifier)
                              .previous(session.currentIndex);
                        },
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  textColor: Colors.grey[800],
                  borderRadius: 16,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdaptiveButton(
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
                  icon: const Icon(Icons.arrow_forward),
                  color: Colors.grey[800],
                  textColor: Colors.white,
                  borderRadius: 16,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '© 2025 English Vocabulary Card',
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }, (_) {});
  }

  Future<void> _toggleHideLearned(WidgetRef ref) async {
    await ref.read(hideLearnedProvider.notifier).toggle();
    ref.read(studyIndexProvider.notifier).reset();
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

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

  String _authStatusLabel({required AppUser? user, required bool isLoading}) {
    if (isLoading) {
      return 'Checking sign-in status...';
    }

    if (user == null) {
      return 'Not signed in';
    }

    final displayName = user.displayName;
    final email = user.email;
    final identity = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (email ?? user.id);

    return 'Signed in as $identity';
  }

  void _listenAuthController(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!context.mounted) {
        return;
      }

      if (next.hasError) {
        final message = _formatError(next.error);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
        );
        return;
      }

      if (previous?.isLoading == true && next is AsyncData<void>) {
        final user = ref.read(authStateProvider).value;
        final message = user == null ? 'Signed out' : 'Signed in successfully';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  String _formatError(Object? error) {
    if (error == null) {
      return 'Unknown authentication error';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
