import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    if (!isViewsUpdated) {
      updateViews();
      isViewsUpdated = true;
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
                          creatorUserID: widget.quizData.creatorUserID,
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
                widget.quizData.quizDescription!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            trailing:
                IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
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
