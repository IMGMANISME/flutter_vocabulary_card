import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/adaptive_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../providers/vocabulary_providers.dart';
import '../widgets/flashcard_widget.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();

  int _currentIndex = 0;
  bool _hideLearned = false;

  List<VocabularyWord> _filteredWords = [];
  VocabularyWord? _currentWord;
  List<String> _availableLetters = [];
  final Map<String, int> _letterIndexMap = {};

  @override
  void initState() {
    super.initState();
    // Riverpod providers are auto-initialized/disposed, no explicit init needed.
  }

  void _processData(List<VocabularyWord> allWords, Set<String> learnedIds) {
    if (_hideLearned) {
      _filteredWords = allWords
          .where((w) => !learnedIds.contains(w.id))
          .toList();
    } else {
      _filteredWords = List.from(allWords);
    }

    _buildLetterIndex();

    if (_filteredWords.isEmpty) {
      _currentIndex = 0;
      _currentWord = null;
    } else {
      if (_currentIndex >= _filteredWords.length) {
        _currentIndex = _filteredWords.length - 1;
      }
      if (_currentIndex < 0) _currentIndex = 0;

      _currentWord = _filteredWords[_currentIndex];
    }
  }

  void _buildLetterIndex() {
    _availableLetters = [];
    _letterIndexMap.clear();

    for (int i = 0; i < _filteredWords.length; i++) {
      final letter = _filteredWords[i].word[0].toUpperCase();
      if (!_availableLetters.contains(letter)) {
        _availableLetters.add(letter);
        _letterIndexMap[letter] = i;
      }
    }
    _availableLetters.sort();
  }

  void _nextCard() {
    if (_currentIndex < _filteredWords.length - 1) {
      setState(() {
        _currentIndex++;
        if (_cardKey.currentState?.isFront == false) {
          _cardKey.currentState?.toggleCard();
        }
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        if (_cardKey.currentState?.isFront == false) {
          _cardKey.currentState?.toggleCard();
        }
      });
    }
  }

  void _jumpToLetter(String letter) {
    if (_letterIndexMap.containsKey(letter)) {
      setState(() {
        _currentIndex = _letterIndexMap[letter]!;
        if (_cardKey.currentState?.isFront == false) {
          _cardKey.currentState?.toggleCard();
        }
      });
    }
  }

  Future<void> _toggleLearned() async {
    if (_currentWord == null) return;
    final useCase = ref.read(toggleLearnedStatusUseCaseProvider);
    await useCase.call(_currentWord!.id);
    // Stream will automatically update UI
  }

  void _toggleHideLearned() {
    setState(() {
      _hideLearned = !_hideLearned;
      // Reset index if needed, or let _processData handle it
      _currentIndex = 0;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    final content = const Text('Are you sure you want to log out?');

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: content,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
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
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final vocabListAsync = ref.watch(vocabularyListProvider);
    final learnedIdsAsync = ref.watch(learnedWordIdsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: vocabListAsync.when(
          data: (allWords) {
            final learnedIds = learnedIdsAsync.value ?? {};
            _processData(allWords, learnedIds);

            return Column(
              children: [
                _buildHeader(),
                if (_filteredWords.isNotEmpty) _buildProgressBar(),
                Expanded(
                  child: _filteredWords.isEmpty
                      ? _buildEmptyState()
                      : _buildCardArea(learnedIds),
                ),
                if (_filteredWords.isNotEmpty) _buildControls(),
                _buildFooter(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authState = ref.watch(authStateProvider);
    final authControllerState = ref.watch(authControllerProvider);
    final user = authState.value;
    final isLoading = authState.isLoading || authControllerState.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    onTap: () => _showLogoutDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      onBackgroundImageError: (_, __) {},
                      child: user.photoURL == null
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

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _filteredWords.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                      '(${_currentIndex + 1}/${_filteredWords.length})',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _toggleHideLearned,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _hideLearned ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hideLearned
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 14,
                          color: _hideLearned ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hide Learned',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _hideLearned
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
                value: progress,
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

  Widget _buildEmptyState() {
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
          if (_hideLearned)
            AdaptiveButton(
              onPressed: _toggleHideLearned,
              isFilled: false,
              textColor: Colors.grey[600],
              child: const Text('Show learned words'),
            ),
        ],
      ),
    );
  }

  Widget _buildCardArea(Set<String> learnedIds) {
    if (_currentWord == null) return const SizedBox();

    final isLearned = learnedIds.contains(_currentWord!.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Expanded(
            child: FlashcardWidget(
              key: ValueKey(_currentWord!.id),
              cardKey: _cardKey,
              word: _currentWord!,
              isLearned: isLearned,
              onToggleLearned: _toggleLearned,
            ),
          ),
          const SizedBox(height: 24),
          AdaptiveButton(
            onPressed: _toggleLearned,
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

  Widget _buildControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _availableLetters.length,
            separatorBuilder: (c, i) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final letter = _availableLetters[index];
              final isSelected = _currentWord?.word.startsWith(letter) ?? false;

              return InkWell(
                onTap: () => _jumpToLetter(letter),
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
                  onPressed: _currentIndex > 0 ? _prevCard : null,
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
                  onPressed: _currentIndex < _filteredWords.length - 1
                      ? _nextCard
                      : null,
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '© 2025 English Vocabulary Card',
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
    );
  }
}
