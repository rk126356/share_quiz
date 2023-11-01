import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/scores_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';

class InsideQuizScoreBoardScreen extends StatefulWidget {
  final CreateQuizDataModel quizData;
  final int? score;
  const InsideQuizScoreBoardScreen(
      {Key? key, required this.quizData, this.score})
      : super(key: key);

  @override
  State<InsideQuizScoreBoardScreen> createState() =>
      _InsideQuizScoreBoardScreenState();
}

class _InsideQuizScoreBoardScreenState
    extends State<InsideQuizScoreBoardScreen> {
  Future<List<Score>>? scores;
  List<Score> myScores = [];

  @override
  void initState() {
    super.initState();
    scores = fetchScores();
  }

  Future<List<Score>> fetchScores() async {
    var userDataProvider =
        Provider.of<UserProvider>(context, listen: false).userData;
    final firestore = FirebaseFirestore.instance;
    final document = await firestore
        .collection('users/${widget.quizData.creatorUserID}/myQuizzes')
        .doc(widget.quizData.quizID)
        .get();
    final quizCollection = firestore
        .collection('users/${widget.quizData.creatorUserID}/myQuizzes')
        .doc(widget.quizData.quizID);

    if (document.exists) {
      final data = document.data();
      if (data != null && data.containsKey('scores')) {
        try {
          final scoresData = data['scores'] as List<dynamic>;

          final List<Score> myLoadedSxores = [];

          final loadedScores = await Future.wait(scoresData.map((score) async {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(score['playerUid'])
                .get();

            final userData = userDoc.data();

            if (userDataProvider.uid == score['playerUid']) {
              myLoadedSxores.add(Score(
                playerUid: score['playerUid'] ?? '',
                playerName: userData?['displayName'],
                playerImage: userData?['avatarUrl'],
                playerScore: score['playerScore'] ?? 0,
                timestamp: score['timestamp'],
                timeTaken: score['timeTaken'] ?? 0,
                noOfQuestions: score['noOfQuestions'] ?? 0,
              ));
            }

            return Score(
              playerUid: score['playerUid'] ?? '',
              playerName: userData?['displayName'],
              playerImage: userData?['avatarUrl'],
              playerScore: score['playerScore'] ?? 0,
              timestamp: score['timestamp'],
              timeTaken: score['timeTaken'] ?? 0,
              noOfQuestions: score['noOfQuestions'] ?? 0,
            );
          }).toList());

          // Sort the loadedScores list by playerScore (in descending order) and timeTaken (in ascending order)
          loadedScores.sort((a, b) {
            int scoreComparison = b.playerScore.compareTo(a.playerScore);
            if (scoreComparison != 0) {
              return scoreComparison;
            } else {
              return a.timeTaken.compareTo(b.timeTaken);
            }
          });

          await quizCollection.update({
            'topScorerName': loadedScores.first.playerName,
            'topScorerImage': loadedScores.first.playerImage,
          });

          myLoadedSxores.sort((a, b) {
            int scoreComparison = b.playerScore.compareTo(a.playerScore);
            if (scoreComparison != 0) {
              return scoreComparison;
            } else {
              return a.timeTaken.compareTo(b.timeTaken);
            }
          });

          myScores = myLoadedSxores;

          return loadedScores;
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }
    return [];
  }

  // Future<void> findAndSaveTopScorer() async {
  //   List<Score> scores = await fetchScores();
  //   if (scores.isNotEmpty) {
  //     // Sort the scores by score in descending order and timeTaken in ascending order
  //     scores.sort((a, b) {
  //       if (a.playerScore != b.playerScore) {
  //         return b.playerScore.compareTo(a.playerScore);
  //       } else {
  //         return a.timeTaken.compareTo(b.timeTaken);
  //       }
  //     });

  //     Score topScorer = scores.first; // The top scorer is the first element

  //     // You can save the top scorer in another variable or use it as needed.
  //     // For example, you can save it to a class field or print it.
  //     // this.topScorer = topScorer; // Save it to a class field if needed
  //     print(
  //         "Top Scorer: ${topScorer.playerName}, Score: ${topScorer.playerScore}, Time Taken: ${topScorer.timeTaken}");
  //   } else {
  //     print("No scores found.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Scoreboard'),
      ),
      body: FutureBuilder<List<Score>>(
        future: scores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scores available.'));
          } else {
            return ListView(
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
                        'Your Correct Answer: ${widget.score}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  ),
                ExpansionTile(
                  initiallyExpanded: widget.score != null ? true : false,
                  title: const Text('My Scores'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: myScores.length,
                      itemBuilder: (context, index) {
                        final myScore = myScores[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(myScore.playerImage),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  myScore.playerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text('Time: ${myScore.timeTaken} sec'),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Score: ${myScore.playerScore}/${myScore.noOfQuestions}'),
                                Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(myScore.timestamp.toDate())}'),
                              ],
                            ),
                            onTap: () {
                              // Add your onTap functionality here
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ExpansionTile(
                  initiallyExpanded: widget.score != null ? false : true,
                  title: const Text('All Scores'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final score = snapshot.data![index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text('Time: ${score.timeTaken} sec'),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Score: ${score.playerScore}/${score.noOfQuestions}'),
                                Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(score.timestamp.toDate())}'),
                              ],
                            ),
                            onTap: () {
                              // Add your onTap functionality here
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
