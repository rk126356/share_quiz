import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class UserQuizzesScreen extends StatefulWidget {
  final String uid;
  final String username;
  const UserQuizzesScreen(
      {super.key, required this.uid, required this.username});

  @override
  State<UserQuizzesScreen> createState() => _UserQuizzesScreenState();
}

class _UserQuizzesScreenState extends State<UserQuizzesScreen> {
  final List<CreateQuizDataModel> quizItems = [];

  Future<void> fetchQuizzes() async {
    final firestore = FirebaseFirestore.instance;

    quizItems.clear();

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('creatorUserID', isEqualTo: widget.uid)
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('${widget.username}: Quizzes'),
      ),
      body: FutureBuilder(
        future: fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          } else {
            if (quizItems.isEmpty) {
              return const Center(
                child: Text('This user have not created any quiz yet.'),
              );
            } else {
              return SizedBox(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: quizItems.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: quizItems.length - 1 == index ? 30.0 : 0.0),
                        child: QuizCardItems(
                          quizData: quizItems[index],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}
