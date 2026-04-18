import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/vocabulary_model.dart';

abstract class VocabularyRemoteDataSource {
  String? get currentUserId;

  Stream<String?> userIdChanges();

  Future<List<VocabularyModel>> getVocabularyList();

  Stream<Set<String>> watchLearnedWordIds(String userId);

  Future<void> toggleLearnedStatus({
    required String userId,
    required String wordId,
  });
}

class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  VocabularyRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  String? get currentUserId => auth.currentUser?.uid;

  @override
  Stream<String?> userIdChanges() {
    return auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<List<VocabularyModel>> getVocabularyList() async {
    try {
      final snapshot = await firestore.collection('vocabulary').get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VocabularyModel.fromJson(data);
      }).toList();

      list.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));

      return list;
    } catch (error) {
      throw ServerException(error.toString());
    }
  }

  @override
  Stream<Set<String>> watchLearnedWordIds(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('learnedWords')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.id).toSet();
        });
  }

  @override
  Future<void> toggleLearnedStatus({
    required String userId,
    required String wordId,
  }) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('learnedWords')
        .doc(wordId);

    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (snapshot.exists) {
          transaction.delete(docRef);
        } else {
          transaction.set(docRef, {'timestamp': FieldValue.serverTimestamp()});
        }
      });
    } catch (error) {
      throw ServerException(error.toString());
    }
  }
}
