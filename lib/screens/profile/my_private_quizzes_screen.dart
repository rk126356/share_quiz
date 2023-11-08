import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/my_quizzes_card_item.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class MyPrivateQuizzesScreen extends StatefulWidget {
  const MyPrivateQuizzesScreen({super.key});

  @override
  State<MyPrivateQuizzesScreen> createState() => _MyPrivateQuizzesScreenState();
}

class _MyPrivateQuizzesScreenState extends State<MyPrivateQuizzesScreen> {
  final List<CreateQuizDataModel> quizItems = [];
  bool _isLoading = false;

  Future<void> fetchQuizzes() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    quizItems.clear();

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('creatorUserID', isEqualTo: data.userData.uid)
        .where('visibility', isEqualTo: 'Private')
        .orderBy('createdAt', descending: true)
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

  Future<void> deleteQuiz(String quizID) async {
    setState(() {
      _isLoading = true;
    });
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('allQuizzes').doc(quizID).delete();
    await firestore
        .collection('users')
        .doc(data.userData.uid)
        .update({'noOfQuizzes': FieldValue.increment(-1)});

    setState(() {
      // Remove the deleted quiz from the list.
      quizItems.removeWhere((quiz) => quiz.quizID == quizID);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Private Quizzes'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : FutureBuilder(
              future: fetchQuizzes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                } else {
                  if (quizItems.isEmpty) {
                    return const Center(
                      child: Text('You have not created any quiz yet.'),
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
                                  bottom: quizItems.length - 1 == index
                                      ? 30.0
                                      : 0.0),
                              child: MyQuizCardItems(
                                onDelete: () {
                                  deleteQuiz(quizItems[index].quizID!);
                                },
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