import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vocabulary_word.dart';

class VocabularyService with ChangeNotifier {
  List<VocabularyWord> _allWords = [];
  Set<String> _learnedWordIds = {};

  // Subscription to Firestore updates
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Cache key for SharedPreferences
  static const String _learnedWordsKey = 'learned_words';

  List<VocabularyWord> get allWords => _allWords;

  Future<void> initialize() async {
    await _loadAllWords();
    await _initDataListeners();
  }

  Future<void> _loadAllWords() async {
    _allWords = [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vocabulary')
          .get();

      if (snapshot.docs.isNotEmpty) {
        _allWords = snapshot.docs.map((doc) {
          final data = doc.data();
          // Map Firestore data to VocabularyWord
          // Firestore ID is used as the word ID
          return VocabularyWord(
            id: doc.id,
            word: data['word'] ?? '',
            partOfSpeech: data['partOfSpeech'] ?? '',
            definition: data['definition'] ?? '',
            example: data['example'] ?? '',
            chineseTranslation: data['chineseTranslation'] ?? '',
          );
        }).toList();
      } else {
        // Optional: Fallback to JSON if needed, but for now we rely on Firestore as the source of truth
        // per the plan to match IDs.
      }
    } catch (e) {}

    _allWords.sort(
      (a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()),
    );
    notifyListeners();
  }

  Future<void> _initDataListeners() async {
    // Initial load from local storage to have something ready immediately
    await _loadFromLocal();

    // Listen to Auth changes to switch data source
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null) {
        _subscribeToFirestore(user.uid);
      } else {
        _unsubscribeFromFirestore();
        _loadFromLocal();
      }
    });
  }

  void _subscribeToFirestore(String userId) {
    _unsubscribeFromFirestore(); // Safety check

    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('learnedWords');

    _firestoreSubscription = collectionRef.snapshots().listen((snapshot) {
      _learnedWordIds = snapshot.docs.map((doc) => doc.id).toSet();
      notifyListeners();
    }, onError: (e) {});
  }

  void _unsubscribeFromFirestore() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedIds = prefs.getStringList(_learnedWordsKey);
    if (storedIds != null) {
      _learnedWordIds = storedIds.toSet();
    } else {
      _learnedWordIds = {};
    }
    notifyListeners();
  }

  List<VocabularyWord> getAllWords() {
    return _allWords;
  }

  Set<String> getLearnedWordIds() {
    return _learnedWordIds;
  }

  bool isLearned(String id) {
    return _learnedWordIds.contains(id);
  }

  Future<void> toggleLearnedStatus(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Toggle in Firestore
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('learnedWords')
          .doc(id);

      try {
        if (_learnedWordIds.contains(id)) {
          // It's currently learned, so we remove it
          // We can just delete the doc.
          await docRef.delete();
          // The snapshot listener will update locally
        } else {
          // Not learned, add it
          // Reference project stores { timestamp: ... }
          await docRef.set({'timestamp': FieldValue.serverTimestamp()});
        }
      } catch (e) {}
    } else {
      // Toggle locally
      if (_learnedWordIds.contains(id)) {
        _learnedWordIds.remove(id);
      } else {
        _learnedWordIds.add(id);
      }
      await _saveLearnedStatusLocal();
      notifyListeners();
    }
  }

  Future<void> _saveLearnedStatusLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_learnedWordsKey, _learnedWordIds.toList());
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
