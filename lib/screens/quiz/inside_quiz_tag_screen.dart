import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class InsideQuizTagScreen extends StatefulWidget {
  final String tag;
  const InsideQuizTagScreen({super.key, required this.tag});

  @override
  State<InsideQuizTagScreen> createState() => _InsideQuizTagScreenState();
}

class _InsideQuizTagScreenState extends State<InsideQuizTagScreen> {
  final List<CreateQuizDataModel> quizItems = [];

  Future<void> fetchQuizzes() async {
    final firestore = FirebaseFirestore.instance;

    quizItems.clear();

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('categories', arrayContainsAny: [widget.tag])
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('Tag: ${widget.tag}'),
      ),
      body: FutureBuilder(
        future: fetchQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          } else {
            if (quizItems.isEmpty) {
              return Center(
                child: Text('No quizzes found for this tag ${widget.tag}.'),
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
