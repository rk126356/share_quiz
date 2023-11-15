import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/fonts.dart';
import 'package:share_quiz/controllers/update_share_firebase.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';

class QuizCardItems extends StatefulWidget {
  final CreateQuizDataModel quizData;

  const QuizCardItems({
    super.key,
    required this.quizData,
  });

  @override
  State<QuizCardItems> createState() => _QuizCardItemsState();
}

class _QuizCardItemsState extends State<QuizCardItems> {
  bool isViewsUpdated = false;
  bool _isLiked = false;
  bool _isDisliked = false;

  updateViewsHere() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    if (!data.quizViews.contains(widget.quizData.quizID)) {
      final quizCollection = await firestore
          .collection('allQuizzes')
          .doc(widget.quizData.quizID)
          .get();

      await quizCollection.reference.update({'views': FieldValue.increment(1)});

      data.setNewQuizViews(widget.quizData.quizID!);
    }
  }

  Future<void> checkIfQuizIsLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final likedQuizRef = firestore.collection('users/$uid/myLikedQuizzes');

      final likedQuizSnapshot = await likedQuizRef
          .where('quizID', isEqualTo: widget.quizData.quizID)
          .get();

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

      final dislikedQuizSnapshot = await dislikedQuizRef
          .where('quizID', isEqualTo: widget.quizData.quizID)
          .get();

      setState(() {
        _isDisliked = dislikedQuizSnapshot.docs.isNotEmpty;
      });
    }
  }

  String? _currentLikes;
  bool _isLoading = false;

  Future<void> addLikedQuizToFirebase(String quizID, String categories) async {
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    setState(() {
      _isLoading = true;
    });
    final firestore = FirebaseFirestore.instance;

    final quizCollection =
        await firestore.collection('allQuizzes').doc(quizID).get();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final likedQuizRef = firestore.collection('users/$uid/myLikedQuizzes');
      final likedQuizSnapshot =
          await likedQuizRef.where('quizID', isEqualTo: quizID).get();

      final dislikedQuizRef =
          firestore.collection('users/$uid/myDislikedQuizzes');

      final dislikedQuizSnapshot =
          await dislikedQuizRef.where('quizID', isEqualTo: quizID).get();

      final quizDataMap = quizCollection.data();

      if (_isLiked) {
        await quizCollection.reference
            .update({'likes': FieldValue.increment(-1)});

        for (final doc in likedQuizSnapshot.docs) {
          await doc.reference.delete();
        }

        if (_isDisliked) {
          for (final doc in dislikedQuizSnapshot.docs) {
            await doc.reference.delete();
          }
        }

        setState(() {
          _isLiked = false;
          int update = quizDataMap?['likes'] - 1;
          _currentLikes = update.toString();
        });
      } else {
        await quizCollection.reference
            .update({'likes': FieldValue.increment(1)});

        await quizCollection.reference
            .update({'disLikes': FieldValue.increment(-1)});

        List<String> categories1 = categories.split(',');

        categories1 = categories1.map((category) => category.trim()).toList();

        await likedQuizRef.add({
          'quizID': quizID,
          'categories': categories1,
          'createdAt': Timestamp.now(),
        });

        if (_isDisliked) {
          for (final doc in dislikedQuizSnapshot.docs) {
            await doc.reference.delete();
          }
        }

        setState(() {
          _isLiked = true;
          int update = quizDataMap?['likes'] + 1;
          _currentLikes = update.toString();
        });
      }
    }
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
  }

  @override
  Widget build(BuildContext context) {
    if (!isViewsUpdated) {
      updateViewsHere();
      isViewsUpdated = true;
    }

    String quizDescription = widget.quizData.quizDescription!;
    List<String> lines = quizDescription.split('\n');

    if (lines.length > 1) {
      if (lines[0].length > 200) {
        quizDescription = lines[0];
      } else if (lines[0].length > 100 ||
          lines[1].length > 100 ||
          (lines.length > 1 && lines[1].length > 100)) {
        quizDescription = '${lines.take(2).join('\n')}...';
      } else if (lines.length > 6) {
        quizDescription = '${lines.take(5).join('\n')}...';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InsideQuizScreen(
                          quizID: widget.quizData.quizID!,
                        )),
              );
            },
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.quizData.quizTitle!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                quizDescription!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            trailing: IconButton(
                onPressed: () {
                  Share.share(
                      'Quiz Title: ${widget.quizData.quizTitle}\n\n'
                      'Description: ${widget.quizData.quizDescription}\n\n'
                      'Questions: ${widget.quizData.noOfQuestions}\n\n'
                      'Difficulty: ${widget.quizData.difficulty}\n\n'
                      'Quiz Code: ${widget.quizData.quizID}\n\n'
                      'Play Now: https://raihansk.com/play/${widget.quizData.quizID}',
                      subject: 'Check out this awesome Quiz');
                  updateShare(
                      widget.quizData.quizID, widget.quizData.creatorUserID);
                },
                icon: const Icon(CupertinoIcons.arrowshape_turn_up_right)),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InsideProfileScreen(
                  userId: widget.quizData.creatorUserID!,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.quizData.creatorImage!),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.quizData.creatorName!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '@${widget.quizData.creatorUsername!}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // const Icon(
                //   CupertinoIcons.number,
                //   color: CupertinoColors.activeBlue,
                //   size: 20,
                // ),
                // const SizedBox(width: 8),
                Row(
                  children:
                      widget.quizData.categories!.asMap().entries.map((entry) {
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
                                      )),
                            );
                          },
                          child: Text(
                            tagName,
                            style: AppFonts.link,
                          )),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.question_circle,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.quizData.noOfQuestions.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.eye,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.quizData.views.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.play_arrow,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.quizData.taken.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    addLikedQuizToFirebase(widget.quizData.quizID!,
                        widget.quizData.categories.toString());
                  },
                  child: _isLoading
                      ? Lottie.asset(
                          'assets/images/heart_animation.json',
                          width: 40,
                          height: 40,
                        )
                      : Row(
                          children: [
                            Icon(
                              _isLiked
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: CupertinoColors.activeBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentLikes != null
                                  ? _currentLikes!
                                  : widget.quizData.likes.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
