import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class MyDislikedQuizzesScreen extends StatefulWidget {
  const MyDislikedQuizzesScreen({super.key});

  @override
  State<MyDislikedQuizzesScreen> createState() =>
      _MyDislikedQuizzesScreenState();
}

class _MyDislikedQuizzesScreenState extends State<MyDislikedQuizzesScreen> {
  final List<CreateQuizDataModel> quizItems = [];
  bool _isLoading = false;
  Timestamp? _lastLoaded;
  int perPage = 10;
  bool _isButtonLoading = false;

  Future<void> fetchQuizzes(bool next, context) async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot likedQuizzesCollection;

    if (quizItems.isNotEmpty) {
      setState(() {
        _isButtonLoading = true;
      });
      likedQuizzesCollection = await firestore
          .collection('users/${data.userData.uid}/myDislikedQuizzes')
          .orderBy('createdAt', descending: true)
          .startAfter([_lastLoaded])
          .limit(perPage)
          .get();
    } else {
      setState(() {
        _isLoading = true;
      });
      likedQuizzesCollection = await firestore
          .collection('users/${data.userData.uid}/myDislikedQuizzes')
          .orderBy('createdAt', descending: true)
          .limit(perPage)
          .get();
    }

    if (likedQuizzesCollection.docs.isEmpty) {
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

    for (final likedQuiz in likedQuizzesCollection.docs) {
      final quizCollection = await firestore
          .collection('allQuizzes')
          .where('quizID', isEqualTo: likedQuiz['quizID'])
          .get();

      _lastLoaded = likedQuiz['createdAt'];

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
          creatorUsername: quizData['creatorUsername'],
        );

        quizItems.add(quizItem);
      }
    }
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuizzes(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('My Disliked Quizzes'),
        ),
        body: _isLoading
            ? const LoadingWidget()
            : quizItems.isEmpty
                ? const Center(
                    child: Text('You have not disliked any quiz yet.'),
                  )
                : SizedBox(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: quizItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == quizItems.length) {
                          return _buildLoadMoreButton();
                        } else {
                          return SizedBox(
                            child: QuizCardItems(
                              quizData: quizItems[index],
                            ),
                          );
                        }
                      },
                    ),
                  ));
  }

  Widget _buildLoadMoreButton() {
    return _isButtonLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryColor, // Set the background color
                  ),
                  onPressed: () {
                    fetchQuizzes(true, context);
                  },
                  child: const Text('Load More...'),
                ),
              ),
              const SizedBox(
                height: 30,
              )
            ],
          );
  }
}
