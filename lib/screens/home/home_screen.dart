import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/screens/home/colors.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final List<Color> predefinedColors = [
  Colors.red,
  Colors.green,
  Colors.blue.shade800,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  CupertinoColors.black,
  Colors.brown,
  Colors.grey,
];

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<CreateQuizDataModel> quizItems = [];

  Future<void> fetchQuizzes() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final userCollection = await firestore.collection('users').get();

      final List<CreateQuizDataModel> newQuizItems = [];

      for (final userDoc in userCollection.docs) {
        final userId = userDoc.id;
        final quizCollection =
            await firestore.collection('users/$userId/myQuizzes').get();

        for (final quizDoc in quizCollection.docs) {
          final quizData = quizDoc.data();
          final quizItem = CreateQuizDataModel(
            quizID: quizData['quizID'],
            creatorName: quizData['creatorName'],
            creatorImage: quizData['creatorImage'],
            quizDescription: quizData['quizDescription'],
            quizTitle: quizData['quizTitle'],
            likes: quizData['likes'],
            views: quizData['views'],
            taken: quizData['taken'],
            wins: quizData['wins'],
            shares: quizData['shares'],
            topScorerImage: quizData['topScorerImage'],
            topScorerName: quizData['topScorerName'],
            categories: quizData['categories'],
            noOfQuestions: quizData['noOfQuestions'],
            creatorUserID: quizData['creatorUserID'],
            createdAt:
                quizData['createdAt'].toString() ?? DateTime.now().toString(),
          );

          newQuizItems.add(quizItem);
        }
      }
      final random = Random();
      newQuizItems.shuffle(random);

      setState(() {
        quizItems.clear();
        quizItems.addAll(newQuizItems);
      });
    } catch (e) {
      print("Error fetching quizzes: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: quizItems.length, vsync: this);
    fetchQuizzes();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  getBody() {
    var size = MediaQuery.of(context).size;
    return RotatedBox(
      quarterTurns: 1,
      child: TabBarView(
        controller: _tabController,
        children: List.generate(
          quizItems.length,
          (index) => RotatedBox(
            quarterTurns: -1,
            child: SafeArea(
              child: Container(
                color: Colors.black,
                child: QuizTikTokItems(
                  size: size,
                  quizID: quizItems[index].quizID,
                  name: quizItems[index].creatorName!,
                  quizTitle: quizItems[index].quizTitle,
                  quizDescription: quizItems[index].quizDescription,
                  categories: quizItems[index].categories!.join(', '),
                  noOfQuestions: quizItems[index].noOfQuestions,
                  likes: quizItems[index].likes!,
                  views: quizItems[index].views,
                  taken: quizItems[index].taken,
                  topScorerImage: quizItems[index].topScorerImage,
                  topScorerName: quizItems[index].topScorerName,
                  wins: quizItems[index].wins,
                  shares: quizItems[index].shares.toString(),
                  profileImg: quizItems[index].creatorImage!,
                  creatorUserID: quizItems[index].creatorUserID!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("ShareQuiz"),
              const Center(child: HeaderHomePage()),
              IconButton(
                  onPressed: () {}, icon: const Icon(CupertinoIcons.search))
            ],
          ),
        ),
        leadingWidth: double.infinity,
        backgroundColor: Colors.black,
        toolbarHeight: 40,
      ),
      body: getBody(),
    );
  }
}

class QuizTikTokItems extends StatefulWidget {
  const QuizTikTokItems(
      {Key? key,
      required this.size,
      this.quizID,
      this.quizTitle,
      this.quizDescription,
      required this.name,
      this.noOfQuestions,
      required this.categories,
      this.topScorerName,
      this.topScorerImage,
      required this.likes,
      required this.shares,
      required this.profileImg,
      this.taken,
      this.views,
      this.wins,
      required this.creatorUserID})
      : super(key: key);

  final Size size;
  final String? quizID;
  final String? quizTitle;
  final String? quizDescription;
  final String name;
  final int? noOfQuestions;
  final String categories;
  final String? topScorerName;
  final String? topScorerImage;
  final int likes;
  final String shares;
  final String profileImg;
  final int? taken;
  final int? views;
  final int? wins;
  final String creatorUserID;

  @override
  State<QuizTikTokItems> createState() => _QuizTikTokItemsState();
}

class _QuizTikTokItemsState extends State<QuizTikTokItems>
    with SingleTickerProviderStateMixin {
  updateViews() async {
    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection('users/${widget.creatorUserID}/myQuizzes')
        .doc(widget.quizID)
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

    return InkWell(
      onTap: () {},
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Stack(
          children: [
            SizedBox(
                width: widget.size.width,
                height: widget.size.height,
                child: Stack(
                  children: [
                    Card(
                      color: predefinedColors[
                          Random().nextInt(predefinedColors.length)],
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 50),
                                child: ListTile(
                                  title: Text(
                                    widget.quizTitle!,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      widget.quizDescription!,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: ButtonBar(
                                  alignment: MainAxisAlignment.start,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InsideQuizScreen(
                                                    quizID: widget.quizID!,
                                                    creatorUserID:
                                                        widget.creatorUserID,
                                                    isViewsUpdated:
                                                        isViewsUpdated,
                                                  )),
                                        );
                                      },
                                      icon: const Icon(Icons.info_outline,
                                          size: 24),
                                      label: const Text(
                                        "More Info",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        side: const BorderSide(
                                            color: Colors
                                                .white), // Set the border color to white
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Adjust the border radius as needed
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: ButtonBar(
                                  alignment: MainAxisAlignment.start,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InsideQuizScreen(
                                                    isQuickPlay: true,
                                                    creatorUserID:
                                                        widget.creatorUserID,
                                                    quizID: widget.quizID!,
                                                    isViewsUpdated:
                                                        isViewsUpdated,
                                                  )),
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow,
                                          size: 24),
                                      label: const Text(
                                        "Quick Play",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        side: const BorderSide(
                                            color: Colors
                                                .white), // Set the border color to white
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Adjust the border radius as needed
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )),
            SizedBox(
              width: widget.size.width,
              height: widget.size.height,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 25,
                    bottom: 10,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              LeftPanel(
                                size: widget.size,
                                name: widget.name,
                                categories: widget.categories,
                                topScorerImage: widget.topScorerImage == null
                                    ? 'https://www.zooniverse.org/assets/simple-avatar.png'
                                    : widget.topScorerImage!,
                                topScorerName: widget.topScorerName!,
                              ),
                              RightPanel(
                                quizID: widget.quizID!,
                                creatorUserID: widget.creatorUserID,
                                size: widget.size,
                                views: widget.views.toString(),
                                noOfQuestions: widget.noOfQuestions.toString(),
                                likes: widget.likes,
                                shares: widget.shares,
                                profileImg: widget.profileImg,
                                taken: widget.taken.toString(),
                                categories: widget.categories,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightPanel extends StatefulWidget {
  const RightPanel(
      {Key? key,
      required this.size,
      required this.creatorUserID,
      required this.profileImg,
      required this.likes,
      required this.noOfQuestions,
      required this.shares,
      required this.views,
      required this.taken,
      required this.quizID,
      required this.categories})
      : super(key: key);

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

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  updateShare() async {
    final firestore = FirebaseFirestore.instance;

    final userCollection = await firestore.collection('users').get();
    final user = FirebaseAuth.instance.currentUser;

    final uid = user?.uid;
    final sharedQuizRef = firestore.collection('users/$uid/mySharedQuizzes');
    final sharedQuizSnapshot =
        await sharedQuizRef.where('quizID', isEqualTo: widget.quizID).get();

    final bool isShared = sharedQuizSnapshot.docs.isNotEmpty;

    if (!isShared) {
      await sharedQuizRef.add({
        'quizID': widget.quizID,
      });
      for (final userDoc in userCollection.docs) {
        final userId = userDoc.id;
        final quizCollection = await firestore
            .collection('users/$userId/myQuizzes')
            .doc(widget.quizID)
            .get();

        final quizDataMap = quizCollection.data();

        int currentShare = quizDataMap?['shares'] ?? 0;

        await quizCollection.reference.update({'shares': currentShare + 1});
      }
    }
  }

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

  DocumentSnapshot<Map<String, dynamic>>? _quizCollection;

  String? _currentLikes;

  Future<void> addLikedQuizToFirebase(String quizID, String categories) async {
    _isLoading = true;
    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection('users/${widget.creatorUserID}/myQuizzes')
        .doc(quizID)
        .get();

    _quizCollection = quizCollection;

    checkIfQuizIsLiked();
    checkIfQuizIsDisliked();
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

      final quizDataMap = _quizCollection?.data();

      int currentLikes = quizDataMap?['likes'] ?? 0;
      int currentDisLikes = quizDataMap?['disLikes'] ?? 0;

      if (_isLiked) {
        if (currentLikes > 0) {
          await _quizCollection?.reference.update({'likes': currentLikes - 1});
        }

        for (final doc in likedQuizSnapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          _isLiked = false;
          int update = quizDataMap?['likes'] - 1;
          _currentLikes = update.toString();
        });
      } else {
        await _quizCollection?.reference.update({'likes': currentLikes + 1});
        if (currentDisLikes > 0) {
          await _quizCollection?.reference
              .update({'disLikes': currentDisLikes - 1});
        }

        List<String> categories1 = categories.split(',');

        categories1 = categories1.map((category) => category.trim()).toList();

        await likedQuizRef.add({
          'quizID': quizID,
          'categories': categories1,
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
    _isLoading = false;
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
                  getProfile(
                    profileImg: widget.profileImg,
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
                            print(_currentLikes);
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
                    onTap: updateShare,
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.reply,
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
            const SizedBox(
              height: 50,
            )
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
                  Icons.add,
                  color: white,
                  size: 15,
                )),
              ))
        ],
      ),
    );
  }
}

class LeftPanel extends StatelessWidget {
  const LeftPanel(
      {Key? key,
      required this.size,
      required this.name,
      required this.categories,
      required this.topScorerName,
      required this.topScorerImage})
      : super(key: key);

  final Size size;
  final String name;
  final String categories;
  final String topScorerName;
  final String topScorerImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //  height: 100,
      height: size.height,
      width: size.width * 0.78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: const TextStyle(color: white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            categories,
            style: const TextStyle(
              color: white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.face,
                color: white,
                size: 28,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                'Top Scroeer: $topScorerName',
                style: const TextStyle(
                  color: white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}

class HeaderHomePage extends StatelessWidget {
  const HeaderHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Following',
          style: TextStyle(
            fontSize: 16,
            color: white.withOpacity(.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '|',
          style: TextStyle(
            fontSize: 16,
            color: white.withOpacity(.3),
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          'For You',
          style: TextStyle(
              fontSize: 17, color: white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
