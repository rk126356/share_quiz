import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/fonts.dart';
import 'package:share_quiz/controllers/update_share_firebase.dart';
import 'package:share_quiz/controllers/update_views_firebase.dart';
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
    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection('users/${widget.quizData.creatorUserID}/myQuizzes')
        .doc(widget.quizData.quizID)
        .get();

    final quizDataMap = quizCollection.data();
    int currentViews = quizDataMap?['views'] ?? 0;
    int updatedViews = currentViews + 1;
    await quizCollection.reference.update({'views': updatedViews});
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
  Widget build(BuildContext context) {
    if (!isViewsUpdated) {
      checkIfQuizIsLiked();
      checkIfQuizIsDisliked();
      updateViewsHere();
      updateViews(widget.quizData.quizID, widget.quizData.creatorUserID);
      isViewsUpdated = true;
    }

    String quizDescription = widget.quizData.quizDescription!;
    List<String> lines = quizDescription.split('\n');

    if (lines.length > 6) {
      quizDescription = lines.take(6).join('\n') + '...';
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
                          isViewsUpdated: isViewsUpdated,
                        )),
              );
            },
            title: Text(
              widget.quizData.quizTitle!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
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
                  updateShare(
                      widget.quizData.quizID, widget.quizData.creatorUserID);
                },
                icon: const Icon(Icons.share)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.tag,
                  color: CupertinoColors.activeBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
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
