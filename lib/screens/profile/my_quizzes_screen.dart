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
  bool noMoreQuizzesPublic = false;
  bool noMoreQuizzesPrivate = false;
  bool noMoreQuizzesDrafts = false;

  Future<void> fetchQuizzesPublic(bool next) async {
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
      setState(() {
        noMoreQuizzesPublic = true;
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

  Future<void> fetchQuizzesPrivate(bool next) async {
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
        noMoreQuizzesPrivate = true;
        _isButtonLoading = false;
        _isLoading = false;
      });
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

  Future<void> fetchQuizzesDraft(bool next) async {
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
        noMoreQuizzesDrafts = true;
        _isButtonLoading = false;
        _isLoading = false;
      });
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
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.initialIndex == 0) {
      if (quizItemsPublic.isEmpty) {
        fetchQuizzesPublic(false);
      }
    }
    if (widget.initialIndex == 1) {
      if (quizItemsPrivate.isEmpty) {
        fetchQuizzesPrivate(false);
      }
    }
    if (widget.initialIndex == 2) {
      if (quizItemsDrafts.isEmpty) {
        fetchQuizzesDraft(false);
      }
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
          bottom: TabBar(
            onTap: (tab) {
              if (tab == 0) {
                if (quizItemsPublic.isEmpty) {
                  fetchQuizzesPublic(false);
                }
              }
              if (tab == 1) {
                if (quizItemsPrivate.isEmpty) {
                  fetchQuizzesPrivate(false);
                }
              }
              if (tab == 2) {
                if (quizItemsDrafts.isEmpty) {
                  fetchQuizzesDraft(false);
                }
              }
            },
            tabs: const [
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
                  itemCount:
                      noMoreQuizzesPublic ? 1 : quizItemsPublic.length + 1,
                  itemBuilder: (context, index) {
                    if (noMoreQuizzesPublic) {
                      return Center(
                        child: Column(
                          children: [
                            const Text('No more quizzes to load.'),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  noMoreQuizzesPublic = false;
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
                    if (index == quizItemsPublic.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchQuizzesPublic(true);
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
                  itemCount:
                      noMoreQuizzesPrivate ? 1 : quizItemsPrivate.length + 1,
                  itemBuilder: (context, index) {
                    if (noMoreQuizzesPrivate) {
                      return Center(
                        child: Column(
                          children: [
                            const Text('No more quizzes to load.'),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  noMoreQuizzesPrivate = false;
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
                    if (index == quizItemsPrivate.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchQuizzesPrivate(true);
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
                  itemCount:
                      noMoreQuizzesDrafts ? 1 : quizItemsDrafts.length + 1,
                  itemBuilder: (context, index) {
                    if (noMoreQuizzesDrafts) {
                      return Center(
                        child: Column(
                          children: [
                            const Text('No more quizzes to load.'),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  noMoreQuizzesDrafts = false;
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
                    if (index == quizItemsDrafts.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchQuizzesDraft(true);
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
