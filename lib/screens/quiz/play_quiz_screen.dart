import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/controllers/language_controller.dart';
import 'package:share_quiz/controllers/update_plays_firebase.dart';
import 'package:share_quiz/providers/quiz_language_provider.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_scoreboard_screen.dart';
import 'package:share_quiz/utils/generate_quizid.dart';
import 'package:share_quiz/widgets/choice_button.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/question_name_box.dart';

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
  int? noOfAttempts = 0;
  bool _isLoading = false;
  bool _isCorrect = false;
  bool _isWrong = false;
  bool hasInternet = false;
  int _selectedChoice = 100;
  bool _isLoadingAns = false;
  late String _scoreId;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _scoreId = generateQuizID();
    updatePlays(widget.quizData!.quizID, widget.quizData.creatorUserID);
    startTimeTaken();
    fetchScores();
    if (widget.quizData.timer != 999) {
      startTimer();
    }
    updatePlaysNow();
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    });
  }

  void fetchScores() async {
    setState(() {
      _isLoading = true;
    });
    var userDataProvider =
        Provider.of<UserProvider>(context, listen: false).userData;
    final firestore = FirebaseFirestore.instance;
    final scoreCollection = await firestore
        .collection('allQuizzes/${widget.quizID}/scoreBoard')
        .where('playerUid', isEqualTo: userDataProvider.uid)
        .get();

    final documents = scoreCollection.docs;

    if (documents.isEmpty) {
      noOfAttempts = 0;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    for (final doc in documents) {
      final data = doc.data();

      if (kDebugMode) {
        print(data['playerUid']);
      }

      noOfAttempts = noOfAttempts! + 1;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void updatePlaysNow() async {
    final firestore = FirebaseFirestore.instance;

    final quizCollection =
        firestore.collection('allQuizzes').doc(widget.quizID);

    await quizCollection.update({
      'taken': FieldValue.increment(1),
    });
  }

  void updateScore() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    final quizCollection = firestore
        .collection('allQuizzes/${widget.quizID}/scoreBoard')
        .doc(_scoreId);

    await quizCollection.set({
      'playerUid': data.userData.uid,
      'playerScore': score,
      'timeTaken': secondsTotal,
      'noOfQuestions': widget.quizData.noOfQuestions,
      'attemptNo': noOfAttempts ?? 0,
      'createdAt': Timestamp.now(),
    });
  }

  void checkAnswer(int selectedChoice) {
    setState(() {
      _isLoadingAns = true;
      _selectedChoice = selectedChoice;
    });

    if (kDebugMode) {
      print('Checking answer');
    }
    final correctIndex =
        widget.quizData.quizzes![currentQuestionIndex].correctAns;

    if (selectedChoice.toString() == correctIndex) {
      setState(() {
        _isCorrect = true;
        score++;
      });
    } else {
      setState(() {
        _isWrong = true;
      });
    }
    // Move to the next question
    if (currentQuestionIndex < widget.quizData.quizzes!.length - 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _selectedChoice = 100;
          currentQuestionIndex++;
          startTimer();
          _isLoadingAns = false;
        });
      });
    } else {
      // Quiz is complete, you can navigate to the results screen or perform any other action.
      if (timeTaken != null && timeTaken!.isActive) {
        timeTaken!.cancel();
      }
      if (quizTimer != null && quizTimer!.isActive) {
        quizTimer!.cancel();
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InsideQuizScoreBoardScreen(
              initialIndex: 0,
              score: score,
              quizID: widget.quizData.quizID!,
              noOfQuestions: widget.quizData.noOfQuestions,
              noOfAttempts: noOfAttempts! + 1,
            ), // Pass the score
          ),
        );
      });
    }
    updateScore();
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
        _showTimeUp();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isWrong = false;
        _isCorrect = false;
      });
    });
  }

  void _showTimeUp() {
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

  startTimeTaken() {
    timeTaken = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      secondsTotal++;
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
  Widget build(BuildContext context) {
    final qLanguage =
        Provider.of<QuestionsLanguageProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              openLanguagePickerDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.translate),
                const SizedBox(width: 8),
                Text(qLanguage.languageName == 'None'
                    ? 'Translate'
                    : '${qLanguage.languageName}'),
              ],
            ),
          )
        ],
        backgroundColor: AppColors.primaryColor,
        title: const Text('Play Quiz'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [CupertinoColors.activeBlue, Colors.blue],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        QuestionNameBox(
                          totalQuestions: widget.quizData.noOfQuestions!,
                          currentIndex: currentQuestionIndex + 1,
                          correct: score,
                          name: widget.quizData.quizzes![currentQuestionIndex]
                              .questionTitle!,
                        ),
                        if (widget.quizData.timer != 999)
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Container(
                              width: widget.quizData.timer == 999 ? 210 : 170,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: widget.quizData.timer == 999
                                      ? Colors.blue[300]!
                                      : Colors.red[300]!,
                                  width: 5.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 22,
                                    color: widget.quizData.timer == 999
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                  Text(
                                    widget.quizData.timer == 999
                                        ? 'Unlimited Time'
                                        : '${secondsRemaining.toString()} seconds',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: widget.quizData.timer == 999
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: widget
                              .quizData.quizzes![currentQuestionIndex].choices!
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final choice = entry.value;
                            return InkWell(
                              onTap: () {
                                if (!_isLoadingAns) {
                                  checkAnswer(index);
                                }
                              },
                              child: ChoiceButton(
                                isWrong: _isWrong,
                                isCorrect: _isCorrect,
                                index: index + 1,
                                text: choice,
                                selectedChoice: _selectedChoice + 1,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
