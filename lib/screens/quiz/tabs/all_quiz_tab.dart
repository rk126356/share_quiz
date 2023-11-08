import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class AllQuizTab extends StatefulWidget {
  AllQuizTab({
    Key? key,
  }) : super(key: key);

  @override
  State<AllQuizTab> createState() => _AllQuizTabState();
}

class _AllQuizTabState extends State<AllQuizTab> {
  final List<CreateQuizDataModel> quizItems = [];

  int listLength = 6;

  DocumentSnapshot? lastDocument;

  bool noMoreQuizzes = false;

  @override
  void initState() {
    super.initState();
    fetchQuizzes(false);
  }

  Future<void> fetchQuizzes(bool shouldReload) async {
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (shouldReload) {
      setState(() {});
      quizCollection = await firestore
          .collection('allQuizzes')
          .orderBy('createdAt', descending: true)
          .where('visibility', isEqualTo: 'Public')
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('allQuizzes')
          .orderBy('createdAt', descending: true)
          .where('visibility', isEqualTo: 'Public')
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      setState(() {
        noMoreQuizzes = true;
      });
      return;
    }

    lastDocument =
        quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: noMoreQuizzes ? 1 : quizItems.length,
              itemBuilder: (context, index) {
                if (noMoreQuizzes) {
                  return Center(
                    child: Column(
                      children: [
                        const Text('No more quizzes to load.'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              noMoreQuizzes = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors
                                .primaryColor, // Change the button color
                          ),
                          child: const Text('Reload',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    ),
                  );
                }
                if (index + 1 == quizItems.length) {
                  return Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            fetchQuizzes(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors
                                .primaryColor, // Change the button color
                          ),
                          child: const Text('Load more...',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    ),
                  );
                }
                return SizedBox(
                  width: 250,
                  child: QuizCardItems(
                    quizData: quizItems[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
