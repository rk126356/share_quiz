import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_scoreboard_screen.dart';

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
  Timer? quizTimer;
  Timer? timeTaken;
  late int secondsRemaining;
  int secondsTotal = 0;

  void updatePlays() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    final quizCollection = firestore
        .collection('users/${widget.quizData.creatorUserID}/myQuizzes')
        .doc(widget.quizID);

    await quizCollection.update({
      'taken': FieldValue.increment(1),
      'scores': FieldValue.arrayUnion([
        {
          'playerUid': data.userData.uid,
          'playerScore': score,
          'timestamp': DateTime.now(),
          'timeTaken': secondsTotal,
          'noOfQuestions': widget.quizData.noOfQuestions,
        },
      ]),
    });
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
        startTimer();
      });
    } else {
      // Quiz is complete, you can navigate to the results screen or perform any other action.
      if (timeTaken != null && timeTaken!.isActive) {
        timeTaken!.cancel();
      }
      if (quizTimer != null && quizTimer!.isActive) {
        quizTimer!.cancel();
      }
      updatePlays();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => InsideQuizScoreBoardScreen(
              score: score, quizData: widget.quizData), // Pass the score
        ),
      );
    }
  }

  void startTimer() {
    if (quizTimer != null) {
      quizTimer!.cancel();
    }
    secondsRemaining = widget.quizData.timer!;
    quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsRemaining--;
      });
      if (secondsRemaining == 0) {
        timer.cancel();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Time's up!"),
              content: const Text("Your quiz time has expired."),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    checkAnswer(99999);
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  startTimeTaken() {
    timeTaken = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      secondsTotal++;
      print(secondsTotal);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (quizTimer != null && quizTimer!.isActive) {
      quizTimer!.cancel();
    }
    if (timeTaken != null && timeTaken!.isActive) {
      timeTaken!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    startTimeTaken();
    if (widget.quizData.timer != 999) {
      startTimer();
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  // Styling for the timer box
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.quizData.timer == 999
                        ? 'Unlimited Time'
                        : 'Time Remaining: ${secondsRemaining.toString()} seconds',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
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
                Container(
                  // Styling for the timer box
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Correct Answer: $score',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
