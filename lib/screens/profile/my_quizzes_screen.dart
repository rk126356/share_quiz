import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/my_quizzes_card_item.dart';

class MyQuizzesScreen extends StatefulWidget {
  final int initialIndex;
  const MyQuizzesScreen({super.key, required this.initialIndex});

  @override
  State<MyQuizzesScreen> createState() => _MyQuizzesScreenState();
}

class _MyQuizzesScreenState extends State<MyQuizzesScreen> {
  final List<CreateQuizDataModel> quizItemsPublic = [];
  final List<CreateQuizDataModel> quizItemsPrivate = [];
  final List<CreateQuizDataModel> quizItemsDrafts = [];

  DocumentSnapshot? lastDocumentPublic;
  DocumentSnapshot? lastDocumentPrivate;
  DocumentSnapshot? lastDocumentDrafts;

  int listLength = 6;

  bool _isLoading = false;
  bool _isButtonLoading = false;

  Future<void> fetchQuizzesPublic(bool next, context) async {
    if (quizItemsPublic.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collection('allQuizzes')
          .orderBy('createdAt', descending: true)
          .where('creatorUserID', isEqualTo: data.userData.uid)
          .where('visibility', isEqualTo: 'Public')
          .startAfter([lastDocumentPublic?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('allQuizzes')
          .where('creatorUserID', isEqualTo: data.userData.uid)
          .where('visibility', isEqualTo: 'Public')
          .orderBy('createdAt', descending: true)
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No more quizzes available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocumentPublic =
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

      quizItemsPublic.add(quizItem);
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  Future<void> fetchQuizzesPrivate(bool next, context) async {
    if (quizItemsPrivate.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collection('allQuizzes')
          .orderBy('createdAt', descending: true)
          .where('creatorUserID', isEqualTo: data.userData.uid)
          .where('visibility', isEqualTo: 'Private')
          .startAfter([lastDocumentPrivate?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('allQuizzes')
          .where('creatorUserID', isEqualTo: data.userData.uid)
          .where('visibility', isEqualTo: 'Private')
          .orderBy('createdAt', descending: true)
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      if (next) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('No more quizzes available.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      return;
    }

    lastDocumentPrivate =
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

      quizItemsPrivate.add(quizItem);
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  Future<void> fetchQuizzesDraft(bool next, context) async {
    if (quizItemsDrafts.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collection('allQuizzes')
          .orderBy('createdAt', descending: true)
          .where('creatorUserID', isEqualTo: data.userData.uid)
          .where('visibility', isEqualTo: 'Draft')
          .startAfter([lastDocumentDrafts?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('allQuizzes')
          .where('creatorUserID', isEqualTo: data.userData.uid)
          .where('visibility', isEqualTo: 'Draft')
          .orderBy('createdAt', descending: true)
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      if (next) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('No more quizzes available.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      return;
    }

    lastDocumentDrafts =
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

      quizItemsDrafts.add(quizItem);
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  Future<void> deleteQuiz(String quizID, String what) async {
    setState(() {
      _isLoading = true;
    });
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('allQuizzes').doc(quizID).delete();

    if (what == 'Public') {
      quizItemsPublic.removeWhere((quiz) => quiz.quizID == quizID);
      await firestore
          .collection('users')
          .doc(data.userData.uid)
          .update({'noOfQuizzes': FieldValue.increment(-1)});
    }
    if (what == 'Private') {
      quizItemsPrivate.removeWhere((quiz) => quiz.quizID == quizID);
      await firestore
          .collection('users')
          .doc(data.userData.uid)
          .update({'noOfQuizzesPrivate': FieldValue.increment(-1)});
    }
    if (what == 'Draft') {
      quizItemsDrafts.removeWhere((quiz) => quiz.quizID == quizID);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (quizItemsPublic.isEmpty) {
      fetchQuizzesPublic(false, context);
    }

    if (quizItemsPrivate.isEmpty) {
      fetchQuizzesPrivate(false, context);
    }

    if (quizItemsDrafts.isEmpty) {
      fetchQuizzesDraft(false, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('My Quizzes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Public'),
              Tab(text: 'Private'),
              Tab(text: 'Drafts')
            ],
          ),
        ),
        body: _isLoading
            ? const LoadingWidget()
            : TabBarView(children: [
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: quizItemsPublic.length + 1,
                  itemBuilder: (context, index) {
                    if (index == quizItemsPublic.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchQuizzesPublic(true, context);
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
                    return MyQuizCardItems(
                      onDelete: () {
                        deleteQuiz(quizItemsPublic[index].quizID!, 'Public');
                      },
                      quizData: quizItemsPublic[index],
                    );
                  },
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: quizItemsPrivate.length + 1,
                  itemBuilder: (context, index) {
                    if (index == quizItemsPrivate.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchQuizzesPrivate(true, context);
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
                    return MyQuizCardItems(
                      onDelete: () {
                        deleteQuiz(quizItemsPrivate[index].quizID!, 'Private');
                      },
                      quizData: quizItemsPrivate[index],
                    );
                  },
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: quizItemsDrafts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == quizItemsDrafts.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchQuizzesDraft(true, context);
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
                    return MyQuizCardItems(
                      onDelete: () {
                        deleteQuiz(quizItemsDrafts[index].quizID!, 'Draft');
                      },
                      quizData: quizItemsDrafts[index],
                    );
                  },
                ),
              ]),
      ),
    );
  }
}
