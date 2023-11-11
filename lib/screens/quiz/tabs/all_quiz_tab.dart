import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
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
  bool _isLoading = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    fetchQuizzes(false, context);
  }

  Future<void> fetchQuizzes(bool next, context) async {
    if (quizItems.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
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
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: quizItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == quizItems.length) {
                        return Center(
                          child: _isButtonLoading
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        fetchQuizzes(true, context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors
                                            .primaryColor, // Change the button color
                                      ),
                                      child: const Text('Load more...',
                                          style:
                                              TextStyle(color: Colors.white)),
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
