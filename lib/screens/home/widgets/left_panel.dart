import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/fonts.dart';
import 'package:share_quiz/screens/home/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';

class LeftPanel extends StatefulWidget {
  LeftPanel({
    Key? key,
    required this.size,
    required this.name,
    required this.username,
    required this.categories,
    required this.topScorerName,
    required this.topScorerImage,
    required this.creatorUserID,
    required this.topScorerUid,
    required this.quizID,
  }) : super(key: key);

  final Size size;
  final String name;
  final String username;
  final List<dynamic> categories;
  String topScorerName;
  String topScorerImage;
  final String creatorUserID;
  String topScorerUid;
  final String quizID;

  @override
  State<LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  void fetchTopScorer() async {
    final firestore = FirebaseFirestore.instance;
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
      widget.topScorerName = topScorerData?['displayName'];
      widget.topScorerImage = topScorerData?['avatarUrl'];
      widget.topScorerUid = topScorerData?['uid'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTopScorer();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //  height: 100,
      height: widget.size.height,
      width: widget.size.width * 0.78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InsideProfileScreen(
                          userId: widget.creatorUserID,
                        )),
              );
            },
            child: Text(
              widget.name,
              style: const TextStyle(color: white, fontSize: 20),
            ),
          ),
          Text(
            '@${widget.username}',
            style: const TextStyle(color: white, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: widget.categories!.asMap().entries.map((entry) {
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
                      style: AppFonts.link.copyWith(color: Colors.white),
                    )),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              if (widget.topScorerUid != '') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsideProfileScreen(
                            userId: widget.topScorerUid,
                          )),
                );
              }
            },
            child: Row(
              children: [
                CachedNetworkImage(
                  width: 35,
                  height: 35,
                  imageUrl: widget.topScorerImage,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Set the border color
                        width: 2.0, // Set the border width
                      ),
                    ),
                    child: ClipOval(
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Top Scorer: ${widget.topScorerName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
