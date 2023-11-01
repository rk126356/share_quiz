import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/controllers/updateShare.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_scoreboard_screen.dart';
import 'package:share_quiz/screens/quiz/play_quiz_screen.dart';
import 'package:share_quiz/widgets/avatar_url_widget.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/small_row_buttons_widget.dart';
import 'package:share_quiz/widgets/stats_list_widget.dart';

class InsideQuizScreen extends StatefulWidget {
  final String quizID;
  final bool? isViewsUpdated;
  final bool? isQuickPlay;
  final String? creatorUserID;

  const InsideQuizScreen(
      {Key? key,
      required this.quizID,
      this.isViewsUpdated,
      this.isQuickPlay,
      this.creatorUserID})
      : super(key: key);

  @override
  State<InsideQuizScreen> createState() => _InsideQuizScreenState();
}

class _InsideQuizScreenState extends State<InsideQuizScreen> {
  late Future<CreateQuizDataModel> quizData;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isLoading = false;
  bool _shouldPlay = false;

  late DocumentSnapshot<Map<String, dynamic>> _quizCollection;

  Future<CreateQuizDataModel> fetchQuizDetails() async {
    final firestore = FirebaseFirestore.instance;

    final userCollection = await firestore.collection('users').get();

    if (widget.creatorUserID != null) {
      final quizCollection = await firestore
          .collection('users/${widget.creatorUserID}/myQuizzes')
          .doc(widget.quizID)
          .get();

      _quizCollection = quizCollection;
    } else {
      for (final userDoc in userCollection.docs) {
        final userId = userDoc.id;
        final quizCollection = await firestore
            .collection('users/$userId/myQuizzes')
            .doc(widget.quizID)
            .get();

        _quizCollection = quizCollection;
      }
    }

    try {
      final quizDataMap = _quizCollection.data();
      final quizzesList = quizDataMap?['quizzes'] as List<dynamic>;

      int currentViews = quizDataMap?['views'] ?? 0;

      int updatedViews = currentViews;

      if (widget.isViewsUpdated != null) {
        updatedViews + 1;
        await _quizCollection.reference.update({'views': updatedViews});
      } else {
        updatedViews - 1;
      }

      CreateQuizDataModel data = CreateQuizDataModel(
        quizID: widget.quizID,
        quizDescription: quizDataMap?['quizDescription'],
        quizTitle: quizDataMap?['quizTitle'],
        likes: quizDataMap?['likes'],
        disLikes: quizDataMap?['DisLikes'],
        views: updatedViews,
        taken: quizDataMap?['taken'],
        wins: quizDataMap?['wins'],
        topScorerImage: quizDataMap?['topScorerImage'],
        topScorerName: quizDataMap?['topScorerName'],
        categories: quizDataMap?['categories'],
        noOfQuestions: quizDataMap?['noOfQuestions'],
        creatorName: quizDataMap?['creatorName'],
        creatorImage: quizDataMap?['creatorImage'],
        shares: quizDataMap?['shares'],
        timer: quizDataMap?['timer'],
        visibility: quizDataMap?['visibility'],
        creatorUserID: quizDataMap?['creatorUserID'],
        quizzes: quizzesList.map((quizMap) {
          return Quizzes(
            questionTitle: quizMap['questionTitle'],
            choices: quizMap['choices'],
            correctAns: quizMap['correctAns'],
          );
        }).toList(),
      );
      if (_shouldPlay) {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayQuizScreen(
              quizData: data,
              quizID: widget.quizID,
            ),
          ),
        );
        _shouldPlay = false;
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return CreateQuizDataModel();
  }

  Future<void> checkIfQuizIsLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final likedQuizRef = firestore.collection('users/$uid/myLikedQuizzes');

      final likedQuizSnapshot =
          await likedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

      setState(() {
        _isLiked = likedQuizSnapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> checkIfQuizIsDisliked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final dislikedQuizRef =
          firestore.collection('users/$uid/myDislikedQuizzes');

      final dislikedQuizSnapshot =
          await dislikedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

      setState(() {
        _isDisliked = dislikedQuizSnapshot.docs.isNotEmpty;
      });
    }
  }

  Future<void> addLikedQuizToFirebase(
      String quizID, List<dynamic> categories) async {
    _isLoading = true;
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final likedQuizRef = firestore.collection('users/$uid/myLikedQuizzes');
      final likedQuizSnapshot =
          await likedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

      final dislikedQuizRef =
          firestore.collection('users/$uid/myDislikedQuizzes');

      final dislikedQuizSnapshot =
          await dislikedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

      final quizDataMap = _quizCollection.data();

      int currentLikes = quizDataMap?['likes'] ?? 0;
      int currentDisLikes = quizDataMap?['disLikes'] ?? 0;

      if (_isLiked) {
        if (currentLikes > 0) {
          await _quizCollection.reference
              .update({'likes': FieldValue.increment(-1)});
        }

        for (final doc in likedQuizSnapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          _isLiked = false;
        });
      } else {
        await _quizCollection.reference
            .update({'likes': FieldValue.increment(1)});
        if (currentDisLikes > 0) {
          await _quizCollection.reference
              .update({'disLikes': FieldValue.increment(-1)});
        }

        await likedQuizRef.add({
          'quizID': quizID,
          'categories': categories,
        });

        if (_isDisliked) {
          for (final doc in dislikedQuizSnapshot.docs) {
            await doc.reference.delete();
          }
        }
        setState(() {
          _isLiked = true;
        });
      }
    }
    quizData = fetchQuizDetails();
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    _isLoading = false;
  }

  Future<void> addDislikedQuizToFirebase(
      String quizID, List<dynamic> categories) async {
    _isLoading = true;
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;
      final likedQuizRef = firestore.collection('users/$uid/myLikedQuizzes');
      final likedQuizSnapshot =
          await likedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

      final dislikedQuizRef =
          firestore.collection('users/$uid/myDislikedQuizzes');

      final dislikedQuizSnapshot =
          await dislikedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

      final quizDataMap = _quizCollection.data();

      int currentDisLikes = quizDataMap?['disLikes'] ?? 0;
      int currentLikes = quizDataMap?['likes'] ?? 0;

      if (_isDisliked) {
        if (currentDisLikes > 0) {
          await _quizCollection.reference
              .update({'disLikes': currentDisLikes - 1});
        }
        for (final doc in dislikedQuizSnapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          _isDisliked = false;
        });
      } else {
        await _quizCollection.reference
            .update({'disLikes': FieldValue.increment(1)});

        await dislikedQuizRef.add({
          'quizID': quizID,
          'categories': categories,
        });
        if (_isLiked) {
          if (currentLikes > 0) {
            await _quizCollection.reference
                .update({'likes': FieldValue.increment(-1)});
          }
          for (final doc in likedQuizSnapshot.docs) {
            await doc.reference.delete();
          }
        }

        setState(() {
          _isDisliked = true;
        });
      }
    }
    quizData = fetchQuizDetails();
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    _isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    _shouldPlay = widget.isQuickPlay != null;
    quizData = fetchQuizDetails();
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(CupertinoIcons.bookmark)),
          IconButton(
              onPressed: () {
                quizData = fetchQuizDetails();
                checkIfQuizIsLiked();
                checkIfQuizIsDisliked();
              },
              icon: const Icon(CupertinoIcons.refresh))
        ],
        title: const Text('Quiz Details'),
        backgroundColor:
            CupertinoColors.activeBlue, // Customize the app bar color
      ),
      body: FutureBuilder<CreateQuizDataModel>(
        future: quizData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final quizData = snapshot.data;

            if (_isLoading) {
              return const LoadingWidget();
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Quiz Card
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            quizData?.quizTitle ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            quizData?.quizDescription ?? 'No Description',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SmallRowButton(
                        onTap: () {
                          FlutterClipboard.copy(widget.quizID).then((value) {
                            const snackBar = SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text("Copied to Clipboard"),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          });
                        },
                        title: 'ID: ${widget.quizID}',
                        icon: const Icon(
                          Icons.content_copy,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SmallRowButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayQuizScreen(
                                quizData: quizData!,
                                quizID: widget.quizID,
                              ),
                            ),
                          );
                        },
                        title: 'PLAY',
                        icon: const Icon(
                          CupertinoIcons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SmallRowButton(
                        onTap: () {
                          addLikedQuizToFirebase(
                              widget.quizID, quizData!.categories!);
                        },
                        title: 'Like',
                        icon: Icon(
                          _isLiked
                              ? CupertinoIcons.hand_thumbsup_fill
                              : CupertinoIcons.hand_thumbsup,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SmallRowButton(
                        onTap: () {
                          addDislikedQuizToFirebase(
                              widget.quizID, quizData!.categories!);
                        },
                        title: 'Dislike',
                        icon: Icon(
                          _isDisliked
                              ? CupertinoIcons.hand_thumbsdown_fill
                              : CupertinoIcons.hand_thumbsdown,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SmallRowButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsideQuizScoreBoardScreen(
                                quizData: quizData!,
                              ),
                            ),
                          );
                        },
                        title: 'Scoreboard',
                        icon: const Icon(
                          CupertinoIcons.chart_bar_square,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SmallRowButton(
                        onTap: () {
                          updateShare(quizData!.quizID, quizData.creatorUserID);
                        },
                        title: 'Share',
                        icon: const Icon(
                          CupertinoIcons.share,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SmallRowButton(
                        onTap: () {},
                        title: 'Releated',
                        icon: const Icon(
                          CupertinoIcons.list_dash,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SmallRowButton(
                        onTap: () {},
                        title: 'Report',
                        icon: const Icon(
                          CupertinoIcons.info,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // Wins and Top Scorer Card
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      avatarTile('Creator', quizData!.creatorImage!,
                          quizData.creatorName.toString(), () {
                        print("TAP");
                      }),
                      avatarTile('Top Scorer', quizData.topScorerImage!,
                          quizData.topScorerName.toString(), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsideQuizScoreBoardScreen(
                              quizData: quizData,
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                ),

                // Statistics Card
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      statTile('Tags', CupertinoIcons.tag,
                          '${quizData?.categories?.join(', ')}'),
                      statTile('Questions', CupertinoIcons.question_circle,
                          quizData.noOfQuestions.toString()),
                      statTile('Views', CupertinoIcons.eye,
                          quizData.views.toString()),
                      statTile('Plays', CupertinoIcons.play_arrow,
                          quizData.taken.toString()),
                      statTile(
                          'Likes',
                          _isLiked
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          quizData.likes.toString()),
                      statTile('Shares', CupertinoIcons.share,
                          quizData.shares.toString()),
                      statTile('Wins', CupertinoIcons.check_mark_circled,
                          quizData.wins.toString()),
                    ],
                  ),
                ),

                // Play Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayQuizScreen(
                          quizData: quizData,
                          quizID: widget.quizID,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: CupertinoColors.activeBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.play_arrow_solid, size: 24),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Play",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            );
          }
        },
      ),
    );
  }
}
