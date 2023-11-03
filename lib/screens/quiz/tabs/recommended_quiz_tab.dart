import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class RecommendedQuizTab extends StatelessWidget {
  RecommendedQuizTab({
    Key? key,
  }) : super(key: key);

  final List<CreateQuizDataModel> quizItems = [];

  Future<void> fetchQuizzes() async {
    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('visibility', isEqualTo: 'Public')
        .get();

    for (final quizDoc in quizCollection.docs) {
      final quizData = quizDoc.data();
      final quizItem = CreateQuizDataModel(
        quizID: quizData['quizID'],
        quizDescription: quizData['quizDescription'],
        quizTitle: quizData['quizTitle'],
        likes: quizData['likes'],
        views: quizData['views'],
        taken: quizData['taken'],
        categories: quizData['categories'],
        noOfQuestions: quizData['noOfQuestions'],
        creatorImage: quizData['creatorImage'],
        creatorName: quizData['creatorName'],
        creatorUserID: quizData['creatorUserID'],
      );

      quizItems.add(quizItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: quizItems.isEmpty ? fetchQuizzes() : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        } else {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: quizItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                    width: 250,
                    child: QuizCardItems(
                      quizData: quizItems[index],
                    ));
              },
            ),
          );
        }
      },
    );
  }
}
