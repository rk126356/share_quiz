import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/quiz_data_class.dart';
import 'package:share_quiz/screens/quiz/quiz_list_widget.dart';

class HardQuizTab extends StatelessWidget {
  HardQuizTab({
    super.key,
  });

  final List<QuizDataClass> quizItems = [];

  Future<void> fetchQuizzes() async {
    final firestore = FirebaseFirestore.instance;

    // Query the "users" collection to get all users
    final userCollection = await firestore.collection('users').get();

    quizItems.clear(); // Clear the list before adding new items

    for (final userDoc in userCollection.docs) {
      final userId = userDoc.id;

      // Query the "myQuizzes" collection for each user
      final quizCollection =
          await firestore.collection('users/$userId/myQuizzes').get();

      for (final quizDoc in quizCollection.docs) {
        final quizData = quizDoc.data();
        final quizItem = QuizDataClass(
          quizID: quizData['quizID'],
          title: quizData['quizTitle'],
          // Add other properties as needed
        );

        quizItems.add(quizItem);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchQuizzes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading indicator or placeholder widget while fetching data
          return const CircularProgressIndicator();
        } else {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: quizItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 250,
                  child: QuizList(
                    title: quizItems[index].title ?? 'No Title',
                    taken: quizItems[index].taken ?? 0,
                    views: quizItems[index].views ?? 0,
                    likes: quizItems[index].likes ?? 0,
                    topScorerName: quizItems[index].topScorerName ?? 'No One',
                    quizID: quizItems[index].quizID!,
                    wins: quizItems[index].wins ?? 0,
                    // Add other properties from QuizDataClass here
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
