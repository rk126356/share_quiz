import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/quiz_template_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/common/fonts.dart';
import 'package:share_quiz/controllers/update_share_firebase.dart';
import 'package:share_quiz/controllers/update_views_firebase.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/create/templates/inside_template_screen.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_scoreboard_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';
import 'package:share_quiz/screens/quiz/play_quiz_screen.dart';
import 'package:share_quiz/utils/launch_url.dart';
import 'package:share_quiz/widgets/avatar_url_widget.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/small_row_buttons_widget.dart';
import 'package:share_quiz/widgets/stats_list_widget.dart';

class InsideQuizScreen extends StatefulWidget {
  final String quizID;
  final bool? isQuickPlay;

  const InsideQuizScreen({
    Key? key,
    required this.quizID,
    this.isQuickPlay,
  }) : super(key: key);

  @override
  State<InsideQuizScreen> createState() => _InsideQuizScreenState();
}

class _InsideQuizScreenState extends State<InsideQuizScreen> {
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isLoading = false;
  bool _shouldPlay = false;
  bool _isQuizDataFound = false;
  bool _isLoggedIn = true;

  late DocumentSnapshot<Map<String, dynamic>> _quizCollection;

  CreateQuizDataModel quizData = CreateQuizDataModel();

  void fetchQuizDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoggedIn = false;
      });

      return;
    }
    if (kDebugMode) {
      print("Fetching Quiz Details");
    }
    setState(() {
      _isLoading = true;
    });
    final firestore = FirebaseFirestore.instance;
    var varData = Provider.of<UserProvider>(context, listen: false);

    final quizCollection =
        await firestore.collection('allQuizzes').doc(widget.quizID).get();

    _quizCollection = quizCollection;

    final quizDataMap = _quizCollection.data();

    if (quizDataMap?['quizzes'] != null) {
      try {
        final quizzesList = quizDataMap?['quizzes'] as List<dynamic>;

        int currentViews = quizDataMap?['views'] ?? 0;

        int updatedViews = currentViews;

        final firestore = FirebaseFirestore.instance;

        if (!varData.quizViews.contains(widget.quizID)) {
          await quizCollection.reference
              .update({'views': FieldValue.increment(1)});

          varData.setNewQuizViews(widget.quizID!);
          updatedViews + 1;
        }

        String userName = 'Not found';
        String userImage = '';
        String topScorerName = 'No One Yet!';
        String topScorerImage =
            'https://firebasestorage.googleapis.com/v0/b/share-quiz.appspot.com/o/myfiles%2F186-1869910_ic-question-mark-roblox-question-mark-avatar.png?alt=media&token=272f2179-f476-44a3-9a6a-10dfe85f64cd';

        try {
          final userDoc = FirebaseFirestore.instance
              .collection('users')
              .doc(quizDataMap?['creatorUserID']);
          final userDocSnapshot = await userDoc.get();

          final userData = userDocSnapshot.data();

          setState(() {
            userName = userData?['displayName'];
            userImage = userData?['avatarUrl'];
          });

          final scoreCollection = await firestore
              .collection('allQuizzes/${widget.quizID}/scoreBoard')
              .orderBy('playerScore', descending: true)
              .orderBy('timeTaken')
              .orderBy('attemptNo')
              .limit(1)
              .get();

          final documents = scoreCollection.docs;
          final topScorer = documents.first.data();

          final topScorerUserDoc = FirebaseFirestore.instance
              .collection('users')
              .doc(topScorer['playerUid']);
          final topScorerUserDocSnapshot = await topScorerUserDoc.get();

          final topScorerData = topScorerUserDocSnapshot.data();

          setState(() {
            topScorerName = topScorerData?['displayName'];
            topScorerImage = topScorerData?['avatarUrl'];
          });
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }

        CreateQuizDataModel data = CreateQuizDataModel(
          quizID: widget.quizID,
          quizDescription: quizDataMap?['quizDescription'],
          quizTitle: quizDataMap?['quizTitle'],
          likes: quizDataMap?['likes'],
          disLikes: quizDataMap?['disLikes'],
          views: updatedViews,
          taken: quizDataMap?['taken'],
          wins: quizDataMap?['wins'],
          topScorerImage: topScorerImage,
          topScorerName: topScorerName,
          categories: quizDataMap?['categories'],
          noOfQuestions: quizDataMap?['noOfQuestions'],
          creatorName: userName,
          creatorImage: userImage,
          shares: quizDataMap?['shares'],
          timer: quizDataMap?['timer'],
          visibility: quizDataMap?['visibility'],
          creatorUserID: quizDataMap?['creatorUserID'],
          difficulty: quizDataMap?['difficulty'],
          createdAt: quizDataMap?['createdAt'],
          quizzes: quizzesList.map((quizMap) {
            return Quizzes(
              questionTitle: quizMap['questionTitle'],
              choices: quizMap['choices'],
              correctAns: quizMap['correctAns'],
            );
          }).toList(),
        );

        updateViews(widget.quizID, data.creatorUserID);
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

        quizData = data;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      setState(() {
        _isQuizDataFound = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isQuizDataFound = false;
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Quiz data is not available');
      }
    }
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
          'createdAt': Timestamp.now(),
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
    fetchQuizDetails();
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
              .update({'disLikes': FieldValue.increment(-1)});
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
          'createdAt': Timestamp.now(),
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
    fetchQuizDetails();
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    _isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    _shouldPlay = widget.isQuickPlay != null;
    fetchQuizDetails();
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);

    if (!_isLoggedIn) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Error...'),
            backgroundColor: AppColors.primaryColor,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("You have to login first."),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: const Text('Login'),
                )
              ],
            ),
          ));
    }

    if (_isLoading && _isQuizDataFound) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: const LoadingWidget(),
      );
    }

    if (!_isQuizDataFound && !_isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz Not Found'),
            backgroundColor: AppColors.primaryColor,
          ),
          body: const Center(
            child: Text("Quiz is deleted or wrong Quiz Code."),
          ));
    }

    if (!_isQuizDataFound && _isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fetching Quiz details...'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: const LoadingWidget(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Share.share(
                      'Quiz Title: \n${quizData.quizTitle}\n\n'
                      'Description: \n${quizData.quizDescription}\n\n'
                      'Questions: ${quizData.noOfQuestions}\n\n'
                      'Difficulty: ${quizData.difficulty}\n\n'
                      'Quiz Code: ${quizData.quizID}\n\n'
                      'Play Now: https://play.sharequiz.in/code/${quizData.quizID}',
                      subject: 'Check out this awesome Quiz');
                  updateShare(quizData.quizID, quizData.creatorUserID);
                },
                icon: const Icon(CupertinoIcons.arrowshape_turn_up_right)),
            IconButton(
                onPressed: () {
                  fetchQuizDetails();
                  checkIfQuizIsLiked();
                  checkIfQuizIsDisliked();
                },
                icon: const Icon(CupertinoIcons.refresh)),
          ],
          title: const Text('Quiz Details'),
          backgroundColor: CupertinoColors.activeBlue,
        ),
        body: ListView(
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
                          quizData.quizTitle ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              quizData.quizDescription!,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 8.0),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    quizData.quizDescription!,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: CupertinoColors.activeBlue,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4)),
                          ),
                          child: TextButton(
                            onPressed: data.userData.uid! ==
                                        quizData.creatorUserID &&
                                    quizData.visibility == 'Draft'
                                ? () {
                                    final template = QuizTemplate(
                                        templateQuizzes: quizData.quizzes!,
                                        templateQuizTitle: quizData.quizTitle!,
                                        templateQuizDescription:
                                            quizData.quizDescription!,
                                        templateQuizTags: quizData.categories!
                                            .join(", ")
                                            .toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              InsideTemplateScreen(
                                                template: template,
                                                quizID: quizData.quizID,
                                              )),
                                    );
                                  }
                                : data.userData.uid! !=
                                            quizData.creatorUserID &&
                                        quizData.visibility == 'Draft'
                                    ? () {}
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PlayQuizScreen(
                                              quizData: quizData,
                                              quizID: widget.quizID,
                                            ),
                                          ),
                                        );
                                      },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.play_arrow,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  data.userData.uid! !=
                                              quizData.creatorUserID &&
                                          quizData.visibility == 'Draft'
                                      ? 'Coming Soon...'
                                      : data.userData.uid! ==
                                                  quizData.creatorUserID &&
                                              quizData.visibility == 'Draft'
                                          ? 'Edit Quiz'
                                          : 'PLAY QUIZ',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: CupertinoColors.activeGreen,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(4)),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InsideQuizScoreBoardScreen(
                                    initialIndex: 1,
                                    quizID: quizData.quizID!,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.chart_bar_square,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'SCOREBOARD',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
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
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    title: 'Code: ${widget.quizID}',
                    icon: const Icon(
                      Icons.content_copy,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SmallRowButton(
                    onTap: () {
                      addLikedQuizToFirebase(
                          widget.quizID, quizData.categories!);
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
                          widget.quizID, quizData.categories!);
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
                      Share.share(
                          'Quiz Title: \n${quizData.quizTitle}\n\n'
                          'Description: \n${quizData.quizDescription}\n\n'
                          'Questions: ${quizData.noOfQuestions}\n\n'
                          'Difficulty: ${quizData.difficulty}\n\n'
                          'Quiz Code: ${quizData.quizID}\n\n'
                          'Play Now: https://play.sharequiz.in/code/${quizData.quizID}',
                          subject: 'Check out this awesome Quiz');

                      updateShare(quizData.quizID, quizData.creatorUserID);
                    },
                    title: 'Share',
                    icon: const Icon(
                      CupertinoIcons.share,
                      color: Colors.white,
                    ),
                  ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  // SmallRowButton(
                  //   onTap: () {},
                  //   title: 'Releated',
                  //   icon: const Icon(
                  //     CupertinoIcons.list_dash,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  const SizedBox(
                    width: 10,
                  ),
                  SmallRowButton(
                    onTap: () {
                      tryLaunchUrl('https://sharequiz.in/contact-us/');
                    },
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
                  avatarTile('Creator', quizData.creatorImage!,
                      quizData.creatorName.toString(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InsideProfileScreen(
                                userId: quizData.creatorUserID!,
                              )),
                    );
                  }),
                  avatarTile('Top Scorer', quizData.topScorerImage!,
                      quizData.topScorerName.toString(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InsideQuizScoreBoardScreen(
                          initialIndex: 1,
                          quizID: quizData.quizID!,
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
                  ListTile(
                    leading: const Icon(CupertinoIcons.tag,
                        color: CupertinoColors.activeBlue),
                    title: const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            quizData.categories!.asMap().entries.map((entry) {
                          final tagName = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InsideQuizTagScreen(
                                      tag: tagName,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                tagName,
                                style: AppFonts.link,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  statTile('Difficulty', CupertinoIcons.lightbulb,
                      quizData.difficulty!, () {}),
                  if (quizData.visibility != 'Public')
                    statTile('Visibility', CupertinoIcons.globe,
                        quizData.visibility!, () {}),
                  statTile('Questions', CupertinoIcons.question_circle,
                      quizData.noOfQuestions.toString(), () {}),
                  statTile('Views', CupertinoIcons.eye,
                      quizData.views.toString(), () {}),
                  statTile('Plays', CupertinoIcons.play_arrow,
                      quizData.taken.toString(), () {}),
                  statTile('Wins', CupertinoIcons.check_mark_circled,
                      quizData.wins.toString(), () {}),
                  statTile(
                      'Likes',
                      _isLiked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      quizData.likes.toString(),
                      () {}),
                  statTile('Shares', CupertinoIcons.share,
                      quizData.shares.toString(), () {}),
                  statTile(
                    'Date',
                    CupertinoIcons.time,
                    quizData.createdAt?.toDate() != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(quizData.createdAt!.toDate())
                        : 'N/A', // Provide a default value if the timestamp is null
                    () {},
                  ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
        ));
  }
}
