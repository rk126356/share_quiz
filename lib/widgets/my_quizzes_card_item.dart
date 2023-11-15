import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';

class MyQuizCardItems extends StatefulWidget {
  final CreateQuizDataModel quizData;
  final dynamic onDelete;

  const MyQuizCardItems({
    super.key,
    required this.quizData,
    required this.onDelete,
  });

  @override
  State<MyQuizCardItems> createState() => _MyQuizCardItemsState();
}

class _MyQuizCardItemsState extends State<MyQuizCardItems> {
  updateViews() async {
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

  bool isViewsUpdated = false;
  bool _isLiked = false;
  bool _isDisliked = false;

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
      updateViews();
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
                onPressed: widget.onDelete,
                icon: const Icon(CupertinoIcons.delete)),
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
                Text(
                  widget.quizData.categories!.isNotEmpty
                      ? 'Tags: ${widget.quizData.categories?.join(', ')}'
                      : 'No Tags',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
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
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.heart,
                      color: CupertinoColors.activeBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.quizData.likes.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
