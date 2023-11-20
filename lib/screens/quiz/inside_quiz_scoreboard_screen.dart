import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/scores_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class InsideQuizScoreBoardScreen extends StatefulWidget {
  final String quizID;
  final int? score;
  final int? noOfAttempts;
  final int? noOfQuestions;
  final int initialIndex;

  const InsideQuizScoreBoardScreen({
    Key? key,
    required this.quizID,
    this.score,
    this.noOfAttempts,
    required this.initialIndex,
    this.noOfQuestions,
  }) : super(key: key);

  @override
  State<InsideQuizScoreBoardScreen> createState() =>
      _InsideQuizScoreBoardScreenState();
}

class _InsideQuizScoreBoardScreenState
    extends State<InsideQuizScoreBoardScreen> {
  List<Score> scores = [];
  List<Score> myScores = [];
  int listLength = 10;

  DocumentSnapshot? lastDocumentAllScore;
  DocumentSnapshot? lastDocumentMyScore;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    fetchScores(false, context);
    fetchMyScores(false, context);
  }

  void fetchMyScores(bool next, context) async {
    var data = Provider.of<UserProvider>(context, listen: false);

    if (myScores.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> scoreCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      scoreCollection = await firestore
          .collection('allQuizzes/${widget.quizID}/scoreBoard')
          .orderBy('playerScore', descending: true)
          .orderBy('timeTaken')
          .orderBy('attemptNo')
          .where('playerUid', isEqualTo: data.userData.uid)
          .startAfterDocument(lastDocumentMyScore!)
          .limit(listLength)
          .get();
    } else {
      scoreCollection = await firestore
          .collection('allQuizzes/${widget.quizID}/scoreBoard')
          .orderBy('playerScore', descending: true)
          .orderBy('timeTaken')
          .orderBy('attemptNo')
          .where('playerUid', isEqualTo: data.userData.uid)
          .limit(listLength)
          .get();
    }

    if (scoreCollection.docs.isEmpty) {
      if (next) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('No more scores available.'),
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
      }

      return;
    }

    lastDocumentMyScore =
        scoreCollection.docs.isNotEmpty ? scoreCollection.docs.last : null;

    for (final doc in scoreCollection.docs) {
      final data = doc.data();

      if (kDebugMode) {
        print(data['playerUid']);
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(data['playerUid'])
          .get();

      final userData = userDoc.data();

      final scoreData = Score(
          playerUid: data['playerUid'] ?? '',
          playerName: userData?['displayName'],
          playerImage: userData?['avatarUrl'],
          playerScore: data['playerScore'] ?? 0,
          timestamp: data['createdAt'],
          timeTaken: data['timeTaken'] ?? 0,
          noOfQuestions: data['noOfQuestions'] ?? 0,
          attemptNo: data['attemptNo'] ?? 0);

      myScores.add(scoreData);
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  void fetchScores(bool next, context) async {
    if (scores.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> scoreCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      scoreCollection = await firestore
          .collection('allQuizzes/${widget.quizID}/scoreBoard')
          .orderBy('playerScore', descending: true)
          .orderBy('timeTaken')
          .orderBy('attemptNo')
          .startAfterDocument(lastDocumentAllScore!)
          .limit(listLength)
          .get();
    } else {
      scoreCollection = await firestore
          .collection('allQuizzes/${widget.quizID}/scoreBoard')
          .orderBy('playerScore', descending: true)
          .orderBy('timeTaken')
          .orderBy('attemptNo')
          .limit(listLength)
          .get();
    }

    if (scoreCollection.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No more scores available.'),
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

    lastDocumentAllScore =
        scoreCollection.docs.isNotEmpty ? scoreCollection.docs.last : null;

    for (final doc in scoreCollection.docs) {
      final data = doc.data();

      if (kDebugMode) {
        print(data['playerUid']);
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(data['playerUid'])
          .get();

      final userData = userDoc.data();

      final scoreData = Score(
          playerUid: data['playerUid'] ?? '',
          playerName: userData?['displayName'],
          playerImage: userData?['avatarUrl'],
          playerScore: data['playerScore'] ?? 0,
          timestamp: data['createdAt'],
          timeTaken: data['timeTaken'] ?? 0,
          noOfQuestions: data['noOfQuestions'] ?? 0,
          attemptNo: data['attemptNo'] ?? 0);

      scores.add(scoreData);
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('Scoreboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Scores'),
              Tab(text: 'All Scores'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _isLoading
                ? const LoadingWidget()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.score != null)
                          Center(
                            child: Container(
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
                                'Attempt: ${widget.noOfAttempts} | Correct Answer: ${widget.score}/${widget.noOfQuestions}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                            ),
                          ),
                        ListView.builder(
                          physics:
                              const BouncingScrollPhysics(), // Enable scrolling
                          shrinkWrap: true,
                          itemCount: myScores.length + 1,
                          itemBuilder: (context, index) {
                            if (index == myScores.length) {
                              return Center(
                                child: _isButtonLoading
                                    ? const CircularProgressIndicator()
                                    : Column(
                                        children: [
                                          if (myScores.length >= listLength)
                                            ElevatedButton(
                                              onPressed: () {
                                                fetchMyScores(true, context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors
                                                    .primaryColor, // Change the button color
                                              ),
                                              child: const Text('Load more...',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          const SizedBox(
                                            height: 25,
                                          )
                                        ],
                                      ),
                              );
                            }
                            return ScoreBoardWidgetCard(score: myScores[index]);
                          },
                        ),
                      ],
                    ),
                  ),
            _isLoading
                ? const LoadingWidget()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics:
                              const BouncingScrollPhysics(), // Enable scrolling
                          shrinkWrap: true,
                          itemCount: scores.length + 1,
                          itemBuilder: (context, index) {
                            if (index == scores.length) {
                              return Center(
                                child: _isButtonLoading
                                    ? const CircularProgressIndicator()
                                    : Column(
                                        children: [
                                          if (scores.length >= listLength)
                                            ElevatedButton(
                                              onPressed: () {
                                                fetchScores(true, context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors
                                                    .primaryColor, // Change the button color
                                              ),
                                              child: const Text('Load more...',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          const SizedBox(
                                            height: 25,
                                          )
                                        ],
                                      ),
                              );
                            }
                            return ScoreBoardWidgetCard(score: scores[index]);
                          },
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ScoreBoardWidgetCard extends StatelessWidget {
  const ScoreBoardWidgetCard({
    super.key,
    required this.score,
  });

  final Score score;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(score.playerImage),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              score.playerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('Time: ${score.timeTaken} sec'),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Score: ${score.playerScore}/${score.noOfQuestions}'),
            Text('Attempt: ${score.attemptNo + 1}'),
            Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(score.timestamp.toDate())}'),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsideProfileScreen(
                userId: score.playerUid,
              ),
            ),
          );
        },
      ),
    );
  }
}
