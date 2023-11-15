import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_quiz/controllers/update_share_firebase.dart';
import 'package:share_quiz/screens/home/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';

class RightPanel extends StatefulWidget {
  const RightPanel({
    Key? key,
    required this.size,
    required this.creatorUserID,
    required this.profileImg,
    required this.likes,
    required this.noOfQuestions,
    required this.shares,
    required this.views,
    required this.taken,
    required this.quizID,
    required this.categories,
    required this.quizTitle,
    required this.quizDescription,
    required this.difficulty,
  }) : super(key: key);

  final Size size;
  final String creatorUserID;
  final String profileImg;
  final int likes;
  final String noOfQuestions;
  final String shares;
  final String views;
  final String taken;
  final String quizID;
  final String categories;
  final String quizTitle;
  final String quizDescription;
  final String difficulty;

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isLoading = false;

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

  String? _currentLikes;

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

      int currentLikes = quizDataMap?['likes'] ?? 0;
      int currentDisLikes = quizDataMap?['disLikes'] ?? 0;

      if (_isLiked) {
        if (currentLikes > 0) {
          await quizCollection.reference
              .update({'likes': FieldValue.increment(-1)});
        }

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
        if (currentDisLikes > 0) {
          await quizCollection.reference
              .update({'disLikes': FieldValue.increment(-1)});
        }

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
    return Expanded(
      child: SizedBox(
        height: widget.size.height,
        child: Column(
          children: [
            Container(
              height: widget.size.height * 0.3,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: getProfile(
                      profileImg: widget.profileImg,
                    ),
                  ),
                  getIcon(
                    icon: CupertinoIcons.question_circle,
                    count: widget.noOfQuestions,
                    size: 30,
                  ),
                  getIcon(
                    icon: CupertinoIcons.eye,
                    count: widget.views,
                    size: 30,
                  ),
                  getIcon(
                    icon: CupertinoIcons.play,
                    count: widget.taken,
                    size: 30,
                  ),
                  _isLoading
                      ? Lottie.asset(
                          'assets/images/heart_animation.json',
                        )
                      : InkWell(
                          onTap: () {
                            addLikedQuizToFirebase(
                                widget.quizID, widget.categories);
                          },
                          child: Column(
                            children: [
                              Icon(
                                _isLiked
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: white,
                                size: 25,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _currentLikes == null
                                    ? widget.likes.toString()
                                    : _currentLikes!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, color: white),
                              )
                            ],
                          ),
                        ),
                  InkWell(
                    onTap: () {
                      Share.share(
                          'Quiz Title: ${widget.quizTitle}\n\n'
                          'Description: ${widget.quizDescription}\n\n'
                          'Questions: ${widget.noOfQuestions}\n\n'
                          'Difficulty: ${widget.difficulty}\n\n'
                          'Quiz Code: ${widget.quizID}\n\n'
                          'Play Now: https://raihansk.com/play/${widget.quizID}',
                          subject: 'Check out this awesome Quiz');
                      updateShare(widget.quizID, widget.creatorUserID);
                    },
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.arrowshape_turn_up_right,
                          color: white,
                          size: 25,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.shares,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: white),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAlbum({albumImg}) {
    return SizedBox(
      width: 65,
      height: 65,
      child: Stack(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: black),
          ),
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(albumImg), fit: BoxFit.cover)),
            ),
          ),
        ],
      ),
    );
  }

  getIcon({icon, double? size, count, onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: white,
            size: size,
          ),
          const SizedBox(height: 5),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.w500, color: white),
          )
        ],
      ),
    );
  }

  getProfile({profileImg}) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: white),
                image: DecorationImage(
                    image: NetworkImage(profileImg), fit: BoxFit.cover)),
          ),
          Positioned(
              left: 12,
              bottom: -1,
              child: Container(
                width: 20,
                height: 20,
                // alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Icon(
                  CupertinoIcons.forward,
                  color: white,
                  size: 15,
                )),
              ))
        ],
      ),
    );
  }
}
