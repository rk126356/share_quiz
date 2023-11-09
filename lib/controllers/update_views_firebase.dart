import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateViews(quizID, creatorUserID) async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final uid = user?.uid;
  final sharedQuizRef = firestore.collection('users/$uid/myViewedQuizzes');
  final sharedQuizSnapshot =
      await sharedQuizRef.where('quizID', isEqualTo: quizID).get();

  final bool isPlayed = sharedQuizSnapshot.docs.isNotEmpty;

  if (!isPlayed) {
    await sharedQuizRef.add({
      'quizID': quizID,
      'createdAt': Timestamp.now(),
    });

    final quizCollection =
        await firestore.collection('allQuizzes').doc(quizID).get();

    await quizCollection.reference
        .update({'uniqueViews': FieldValue.increment(1)});
  }
}
