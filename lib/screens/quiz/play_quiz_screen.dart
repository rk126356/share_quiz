import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/quiz/result_quiz_screen.dart';

class PlayQuizScreen extends StatefulWidget {
  final CreateQuizDataModel quizData;
  final String quizID;

  const PlayQuizScreen({Key? key, required this.quizData, required this.quizID})
      : super(key: key);

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;

  updatePlays() async {
    final firestore = FirebaseFirestore.instance;

    final userCollection = await firestore.collection('users').get();

    for (final userDoc in userCollection.docs) {
      final userId = userDoc.id;
      final quizCollection = await firestore
          .collection('users/$userId/myQuizzes')
          .doc(widget.quizID)
          .get();

      final quizDataMap = quizCollection.data();
      int curentPlays = quizDataMap?['taken'] ?? 0;
      int updatedPlays = curentPlays + 1;
      await quizCollection.reference.update({'taken': updatedPlays});
    }
  }

  void checkAnswer(int selectedChoice) {
    final correctIndex =
        widget.quizData.quizzes![currentQuestionIndex].correctAns;

    if (selectedChoice.toString() == correctIndex) {
      setState(() {
        score++;
      });
    }

    // Move to the next question
    if (currentQuestionIndex < widget.quizData.quizzes!.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Quiz is complete, you can navigate to the results screen or perform any other action.
      updatePlays();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              ResultQuizScreen(score: score), // Pass the score
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Play Quiz'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CupertinoColors.activeBlue, Colors.blue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1} of ${widget.quizData.quizzes!.length}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.quizData.quizzes![currentQuestionIndex]
                            .questionTitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: widget
                            .quizData.quizzes![currentQuestionIndex].choices!
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final choice = entry.value;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    checkAnswer(index);
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        choice,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Text('Correct: $score',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
