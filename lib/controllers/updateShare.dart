import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

updateShare(String quizID) async {
  final firestore = FirebaseFirestore.instance;

  final userCollection = await firestore.collection('users').get();
  final user = FirebaseAuth.instance.currentUser;

  final uid = user?.uid;
  final sharedQuizRef = firestore.collection('users/$uid/mySharedQuizzes');
  final sharedQuizSnapshot =
      await sharedQuizRef.where('quizID', isEqualTo: quizID).get();

  final bool isShared = sharedQuizSnapshot.docs.isNotEmpty;

  if (!isShared) {
    await sharedQuizRef.add({
      'quizID': quizID,
    });
    for (final userDoc in userCollection.docs) {
      final userId = userDoc.id;
      final quizCollection = await firestore
          .collection('users/$userId/myQuizzes')
          .doc(quizID)
          .get();

      final quizDataMap = quizCollection.data();

      int currentShare = quizDataMap?['shares'] ?? 0;

      await quizCollection.reference.update({'shares': currentShare + 1});
    }
  }
}
