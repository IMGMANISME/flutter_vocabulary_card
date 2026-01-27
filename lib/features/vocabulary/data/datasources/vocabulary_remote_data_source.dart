import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:rxdart/rxdart.dart';
import '../models/vocabulary_model.dart';

abstract class VocabularyRemoteDataSource {
  Future<List<VocabularyModel>> getVocabularyList();
  Future<void> toggleLearnedStatus(String wordId, bool isLearned);
  Stream<Set<String>> getLearnedWordIdsStream();
}

class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  VocabularyRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<List<VocabularyModel>> getVocabularyList() async {
    try {
      final snapshot = await firestore.collection('vocabulary').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is part of the map
        return VocabularyModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> toggleLearnedStatus(String wordId, bool isLearned) async {
    final user = auth.currentUser;
    if (user == null) {
      throw ServerException('User not authenticated');
    }

    final docRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('learnedWords')
        .doc(wordId);

    try {
      if (isLearned) {
        // Was learned, now removing
        await docRef.delete();
      } else {
        // Was not learned, now adding
        await docRef.set({'timestamp': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<Set<String>> getLearnedWordIdsStream() {
    return auth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value({});
      }
      return firestore
          .collection('users')
          .doc(user.uid)
          .collection('learnedWords')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => doc.id).toSet();
          });
    });
  }
}
