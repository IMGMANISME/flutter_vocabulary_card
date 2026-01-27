import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import '../models/vocabulary_word.dart';
import '../services/vocabulary_service.dart';
import '../services/auth_service.dart';
import '../components/flashcard_widget.dart';
import '../components/adaptive_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();

  // 導航/顯示狀態
  int _currentIndex = 0;
  bool _hideLearned = false;

  // 計算屬性（針對當前 Build 緩存）
  List<VocabularyWord> _filteredWords = [];
  VocabularyWord? _currentWord;
  List<String> _availableLetters = [];
  final Map<String, int> _letterIndexMap = {};
  Set<String> _learnedIds = {}; // 緩存輔助用

  @override
  void initState() {
    super.initState();
    // Trigger initialization once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyService>(context, listen: false).initialize();
    });
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

    // Safety check for index
    if (_filteredWords.isEmpty) {
      _currentIndex = 0;
      _currentWord = null;
    } else {
      // 嘗試盡可能保持同一個單字，或是同一個索引
      // 但如果列表變動很大（例如初始載入），索引 0 比較安全。
      // 如果我們只是切換已學習狀態，該單字可能會從列表中消失。

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
    final vocabService = Provider.of<VocabularyService>(context, listen: false);
    await vocabService.toggleLearnedStatus(_currentWord!.id);
    // UI will update automatically via build
  }

  void _toggleHideLearned() {
    setState(() {
      _hideLearned = !_hideLearned;
      // Index adjustment happens in build/_processData
      // But we might want to reset index or try to find current word?
      // For simplicity, let _processData handle bounds checking.
    });
  }

  void _showLogoutDialog(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AuthService>(context, listen: false).signOut();
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
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close dialog first
                Navigator.pop(context);
                // Perform sign out
                Provider.of<AuthService>(context, listen: false).signOut();
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
    // Reactive data source
    final vocabService = Provider.of<VocabularyService>(context);
    final allWords = vocabService.allWords;
    _learnedIds = vocabService.getLearnedWordIds();
    final bool isLoading = allWords.isEmpty;

    if (!isLoading) {
      _processData(allWords, _learnedIds);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Gray-50
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  if (_filteredWords.isNotEmpty) _buildProgressBar(),
                  Expanded(
                    child: _filteredWords.isEmpty
                        ? _buildEmptyState()
                        : _buildCardArea(),
                  ),
                  if (_filteredWords.isNotEmpty) _buildControls(),
                  _buildFooter(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final authService = Provider.of<AuthService>(context);

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
            child: authService.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : authService.user != null
                ? InkWell(
                    onTap: () => _showLogoutDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: authService.user!.photoURL != null
                          ? NetworkImage(authService.user!.photoURL!)
                          : null,
                      onBackgroundImageError: (_, __) {
                        // Allow fallback to child if image fails
                      },
                      child: authService.user!.photoURL == null
                          ? Text(
                              (authService.user!.displayName ?? 'U')[0]
                                  .toUpperCase(),
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
                      await authService.signInWithGoogle();
                      if (context.mounted && authService.user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Verification Mode: Logged in as Test User',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    // Sign In: Icon only
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
              color: Colors.black.withOpacity(0.05),
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

  Widget _buildCardArea() {
    if (_currentWord == null) return const SizedBox();

    final isLearned = _learnedIds.contains(_currentWord!.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // 使用 Expanded 讓 Flashcard 填滿剩餘空間，而不是使用固定的 60% 高度
          Expanded(
            child: FlashcardWidget(
              key: ValueKey(_currentWord!.id), // 使用唯一 Key 強制在單字變更時重建 Widget
              // 使用 Global Key 讓我們可以程式化控制翻牌
              // 使用 ValueKey 確保狀態重置（預設為正面）
              cardKey: _cardKey,
              word: _currentWord!,
              isLearned: isLearned,
              onToggleLearned: _toggleLearned,
            ),
          ),
          const SizedBox(height: 24),

          // 標記為已學習按鈕
          // 標記為已學習按鈕
          AdaptiveButton(
            onPressed: _toggleLearned,
            icon: Icon(
              isLearned ? Icons.check : Icons.circle_outlined,
              size: 20,
            ),
            child: Text(isLearned ? 'Learned' : 'Mark as Learned'),
            color: isLearned ? Colors.grey[900] : Colors.white,
            textColor: isLearned ? Colors.white : Colors.grey[700],
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Letter Jump
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

        // Navigation Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  onPressed: _currentIndex > 0 ? _prevCard : null,
                  icon: const Icon(Icons.arrow_back),
                  child: const Text('Previous'),
                  color: Colors.white,
                  textColor: Colors.grey[800],
                  borderRadius: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdaptiveButton(
                  onPressed: _currentIndex < _filteredWords.length - 1
                      ? _nextCard
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  child: const Text('Next'),
                  color: Colors.grey[800],
                  textColor: Colors.white,
                  borderRadius: 16,
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
