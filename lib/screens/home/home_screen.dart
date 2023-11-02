import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/home/colors.dart';
import 'package:share_quiz/screens/home/search_quiz_screen.dart';
import 'package:share_quiz/screens/home/widgets/left_panel.dart';
import 'package:share_quiz/screens/home/widgets/quiz_desxription_gap.dart';
import 'package:share_quiz/screens/home/widgets/right_panel.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final List<CreateQuizDataModel> quizItems = [];

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    final firestore = FirebaseFirestore.instance;
    try {
      final userCollection = await firestore.collection('users').get();

      final List<CreateQuizDataModel> newQuizItems = [];

      for (final userDoc in userCollection.docs) {
        final userId = userDoc.id;
        final quizCollection = await firestore
            .collection('users/$userId/myQuizzes')
            .where('visibility', isEqualTo: 'Public')
            .get();

        final userData = userDoc.data();

        for (final quizDoc in quizCollection.docs) {
          final quizData = quizDoc.data();

          final quizItem = CreateQuizDataModel(
            quizID: quizData['quizID'],
            creatorName: userData['displayName'],
            creatorUsername: userData['username'],
            creatorImage: userData['avatarUrl'],
            quizDescription: quizData['quizDescription'],
            quizTitle: quizData['quizTitle'],
            likes: quizData['likes'],
            views: quizData['views'],
            taken: quizData['taken'],
            wins: quizData['wins'],
            shares: quizData['shares'],
            topScorerImage: quizData['topScorerImage'],
            topScorerName: quizData['topScorerName'],
            topScorerUid: quizData['topScorerUid'],
            categories: quizData['categories'],
            noOfQuestions: quizData['noOfQuestions'],
            creatorUserID: quizData['creatorUserID'],
            createdAt: quizData['createdAt'],
            timer: quizData['timer'],
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
      if (kDebugMode) {
        print("Error fetching quizzes: $e");
      }
    }
    _isLoading = false;
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
                  username: quizItems[index].creatorUsername!,
                  createdAt: quizItems[index].createdAt,
                  quizTitle: quizItems[index].quizTitle,
                  quizDescription: quizItems[index].quizDescription,
                  categories: quizItems[index].categories!,
                  noOfQuestions: quizItems[index].noOfQuestions,
                  likes: quizItems[index].likes!,
                  views: quizItems[index].views,
                  taken: quizItems[index].taken,
                  topScorerImage: quizItems[index].topScorerImage,
                  topScorerName: quizItems[index].topScorerName,
                  topScorerUid: quizItems[index].topScorerUid ?? '',
                  wins: quizItems[index].wins,
                  shares: quizItems[index].shares.toString(),
                  profileImg: quizItems[index].creatorImage!,
                  creatorUserID: quizItems[index].creatorUserID!,
                  timer: quizItems[index].timer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> checkUser(user, context) async {
  //   final userDoc =
  //       FirebaseFirestore.instance.collection('users').doc(user.uid);
  //   final userDocSnapshot = await userDoc.get();

  //   if (userDocSnapshot.exists) {
  //     final userData = userDocSnapshot.data();
  //     if (userData!.containsKey('bio') &&
  //         userData['bio'] != null &&
  //         userData['bio'] != '') {
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
  //       );
  //     }
  //   } else {}
  // }

  bool isUserChecked = false;

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    // if (!isUserChecked) {
    //   checkUser(data.userData, context);
    //   isUserChecked = true;
    // }

    if (_isLoading) {
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
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchQuizScreen()),
                          );
                        },
                        icon: const Icon(CupertinoIcons.search)),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchQuizScreen()),
                          );
                        },
                        icon: const Icon(CupertinoIcons.refresh)),
                  ],
                )
              ],
            ),
          ),
          leadingWidth: double.infinity,
          backgroundColor: Colors.black,
          toolbarHeight: 40,
        ),
        body: const LoadingWidget(),
      );
    }
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
              Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.search)),
                  IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      icon: const Icon(CupertinoIcons.refresh)),
                ],
              )
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
  const QuizTikTokItems({
    Key? key,
    required this.size,
    this.quizID,
    this.quizTitle,
    this.quizDescription,
    required this.name,
    required this.username,
    this.createdAt,
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
    required this.creatorUserID,
    required this.topScorerUid,
    this.timer,
  }) : super(key: key);

  final Size size;
  final String? quizID;
  final String? quizTitle;
  final String? quizDescription;
  final String name;
  final String username;
  final Timestamp? createdAt;
  final int? noOfQuestions;
  final List<dynamic> categories;
  final String? topScorerName;
  final String? topScorerImage;
  final String topScorerUid;
  final int likes;
  final String shares;
  final String profileImg;
  final int? taken;
  final int? views;
  final int? wins;
  final String creatorUserID;
  final int? timer;

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

    return SizedBox(
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
                                    icon:
                                        const Icon(Icons.play_arrow, size: 24),
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
                            quizDescriptionSizedBox(widget.quizDescription),
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
                              creatorUserID: widget.creatorUserID,
                              name: widget.name,
                              username: widget.username,
                              categories: widget.categories,
                              topScorerImage: widget.topScorerImage == null
                                  ? 'https://www.zooniverse.org/assets/simple-avatar.png'
                                  : widget.topScorerImage!,
                              topScorerName: widget.topScorerName!,
                              topScorerUid: widget.topScorerUid,
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
                              categories: widget.categories!.join(', '),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          DateFormat('yyyy-MM-dd')
                              .format(widget.createdAt!.toDate()),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
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
