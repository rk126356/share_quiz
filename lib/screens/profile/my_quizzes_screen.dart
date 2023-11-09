import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/my_quizzes_card_item.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class MyQuizzesScreen extends StatefulWidget {
  const MyQuizzesScreen({super.key});

  @override
  State<MyQuizzesScreen> createState() => _MyQuizzesScreenState();
}

class _MyQuizzesScreenState extends State<MyQuizzesScreen> {
  final List<CreateQuizDataModel> quizItemsPublic = [];
  final List<CreateQuizDataModel> quizItemsPrivate = [];
  final List<CreateQuizDataModel> quizItemsDrafts = [];
  bool _isLoading = false;

  Future<void> fetchQuizzesPublic() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    quizItemsPublic.clear();

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('creatorUserID', isEqualTo: data.userData.uid)
        .where('visibility', isEqualTo: 'Public')
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

      quizItemsPublic.add(quizItem);
    }
  }

  Future<void> fetchQuizzesPrivate() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    quizItemsPrivate.clear();

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

      quizItemsPrivate.add(quizItem);
    }
  }

  Future<void> fetchQuizzesDraft() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    quizItemsDrafts.clear();

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('creatorUserID', isEqualTo: data.userData.uid)
        .where('visibility', isEqualTo: 'Draft')
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

      quizItemsDrafts.add(quizItem);
    }
  }

  Future<void> deleteQuiz(String quizID, String what) async {
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
      if (what == 'Public') {
        quizItemsPublic.removeWhere((quiz) => quiz.quizID == quizID);
      }
      if (what == 'Private') {
        quizItemsPrivate.removeWhere((quiz) => quiz.quizID == quizID);
      }
      if (what == 'Draft') {
        quizItemsDrafts.removeWhere((quiz) => quiz.quizID == quizID);
      }

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('My Quizzes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Public'),
              Tab(text: 'Private'),
              Tab(
                text: 'Drafts',
              )
            ],
          ),
        ),
        body: TabBarView(children: [
          FutureBuilder(
            future: fetchQuizzesPublic(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingWidget());
              } else {
                if (quizItemsPublic.isEmpty) {
                  return const Center(
                    child: Text('You have not created any quiz yet.'),
                  );
                } else {
                  return SizedBox(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: quizItemsPublic.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: quizItemsPublic.length - 1 == index
                                    ? 30.0
                                    : 0.0),
                            child: MyQuizCardItems(
                              onDelete: () {
                                deleteQuiz(
                                    quizItemsPublic[index].quizID!, 'Public');
                              },
                              quizData: quizItemsPublic[index],
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
          FutureBuilder(
            future: fetchQuizzesPrivate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingWidget());
              } else {
                if (quizItemsPrivate.isEmpty) {
                  return const Center(
                    child: Text('You have not created any quiz yet.'),
                  );
                } else {
                  return SizedBox(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: quizItemsPrivate.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: quizItemsPrivate.length - 1 == index
                                    ? 30.0
                                    : 0.0),
                            child: MyQuizCardItems(
                              onDelete: () {
                                deleteQuiz(
                                    quizItemsPrivate[index].quizID!, 'Private');
                              },
                              quizData: quizItemsPrivate[index],
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
          FutureBuilder(
            future: fetchQuizzesDraft(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingWidget());
              } else {
                if (quizItemsDrafts.isEmpty) {
                  return const Center(
                    child: Text('You have not created any quiz yet.'),
                  );
                } else {
                  return SizedBox(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: quizItemsDrafts.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: quizItemsDrafts.length - 1 == index
                                    ? 30.0
                                    : 0.0),
                            child: MyQuizCardItems(
                              onDelete: () {
                                deleteQuiz(
                                    quizItemsDrafts[index].quizID!, 'Draft');
                              },
                              quizData: quizItemsDrafts[index],
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
        ]),
      ),
    );
  }
}
