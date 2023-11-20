import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/controllers/update_app_launch.dart';
import 'package:share_quiz/controllers/update_views_firebase.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/home/colors.dart';
import 'package:share_quiz/screens/home/widgets/left_panel.dart';
import 'package:share_quiz/screens/home/widgets/quiz_desxription_gap.dart';
import 'package:share_quiz/screens/home/widgets/right_panel.dart';
import 'package:share_quiz/screens/profile/create_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_quiz/utils/search_popup.dart';
import 'package:share_quiz/utils/tools.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final bool? isFollowingTab;
  const HomeScreen({Key? key, this.isFollowingTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isForYouTab = true;
  int forYouTabLength = 19;
  int followingTabLemgth = 19;

  List<CreateQuizDataModel> forYouQuizzes = [];
  List<CreateQuizDataModel> followingQuizzes = [];
  String? createdAt;
  DocumentSnapshot? lastDocumentFollowings;
  DocumentSnapshot? lastFollowingQuiz;

  final firestore = FirebaseFirestore.instance;

  void fetchForYouQuizzes(bool next) async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      final st = stringToTimestamp(createdAt!);
      quizCollection = await firestore
          .collection('allQuizzes')
          .where('visibility', isEqualTo: 'Public')
          .orderBy('createdAt', descending: true)
          .startAfter([st])
          .limit(20)
          .get();
    } else {
      String? latCreatedAt = prefs.getString('lastCreatedAt');

      if (latCreatedAt != null) {
        final st = stringToTimestamp(latCreatedAt!);

        quizCollection = await firestore
            .collection('allQuizzes')
            .where('visibility', isEqualTo: 'Public')
            .orderBy('createdAt', descending: true)
            .startAfter([st])
            .limit(20)
            .get();
      } else {
        quizCollection = await firestore
            .collection('allQuizzes')
            .orderBy('createdAt', descending: true)
            .where('visibility', isEqualTo: 'Public')
            .limit(20)
            .get();
      }
    }

    if (quizCollection.docs.isEmpty) {
      await prefs.remove('lastCreatedAt');
      fetchForYouQuizzes(false);
    }

    final lastDocument =
        quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

    createdAt = timestampToString(lastDocument?['createdAt']);

    // await prefs.setString('lastCreatedAt', createdAt!);

    bool limit = false;
    bool limit2 = false;

    for (final quizDoc in quizCollection.docs) {
      final quizData = quizDoc.data();

      final quizItem = CreateQuizDataModel(
        quizID: quizData['quizID'],
        creatorName: quizData['creatorName'],
        creatorUsername: quizData['creatorUsername'],
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
        topScorerUid: quizData['topScorerUid'],
        categories: quizData['categories'],
        noOfQuestions: quizData['noOfQuestions'],
        creatorUserID: quizData['creatorUserID'],
        createdAt: quizData['createdAt'],
        timer: quizData['timer'],
        difficulty: quizData['difficulty'],
      );

      forYouQuizzes.add(quizItem);

      if (!limit) {
        if (forYouQuizzes.length > 5) {
          setState(() {
            _isLoading = false;
            limit = true;
          });
        }
      }

      if (!limit2) {
        if (forYouQuizzes.length > 10) {
          setState(() {
            _isLoading = false;
            limit2 = true;
          });
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchFollowingsQuizzes(bool dontClear) async {
    setState(() {
      _isLoading = true;
    });

    final firestore = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;

    QuerySnapshot<Map<String, dynamic>> followingRef;

    if (dontClear) {
      followingRef = await firestore
          .collection('users/${user?.uid}/myFollowings')
          .orderBy('createdAt')
          .startAt([lastDocumentFollowings?['createdAt']])
          .limit(5)
          .get();
    } else {
      followingRef = await firestore
          .collection('users/${user?.uid}/myFollowings')
          .orderBy('createdAt')
          .limit(5)
          .get();
    }

    for (final docs in followingRef.docs) {
      final userData = docs.data();
      if (kDebugMode) {
        print(userData['userID']);
      }

      lastDocumentFollowings =
          followingRef.docs.isNotEmpty ? followingRef.docs.last : null;

      if (kDebugMode) {
        print(lastDocumentFollowings?['userID']);
      }

      try {
        final QuerySnapshot<Map<String, dynamic>> quizCollection;

        if (dontClear) {
          quizCollection = await firestore
              .collection('allQuizzes')
              .where('creatorUserID', isEqualTo: userData['userID'])
              .where('visibility', isEqualTo: 'Public')
              .orderBy('createdAt', descending: true)
              .startAfter([lastFollowingQuiz?['createdAt']])
              .limit(5)
              .get();
        } else {
          quizCollection = await firestore
              .collection('allQuizzes')
              .where('creatorUserID', isEqualTo: userData['userID'])
              .where('visibility', isEqualTo: 'Public')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();
        }

        lastFollowingQuiz =
            quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

        for (final quizDoc in quizCollection.docs) {
          final quizData = quizDoc.data();

          final quizItem = CreateQuizDataModel(
            quizID: quizData['quizID'],
            creatorName: quizData['creatorName'],
            creatorUsername: quizData['creatorUsername'],
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
            topScorerUid: quizData['topScorerUid'],
            categories: quizData['categories'],
            noOfQuestions: quizData['noOfQuestions'],
            creatorUserID: quizData['creatorUserID'],
            createdAt: quizData['createdAt'],
            timer: quizData['timer'],
            difficulty: quizData['difficulty'],
            visibility: quizData['visibility'],
          );

          followingQuizzes.add(quizItem);
        }

        setState(() {
          followingQuizzes.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching following quizzes: $e");
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void saveUserData(context) async {
    var user = FirebaseAuth.instance.currentUser!;
    var data = Provider.of<UserProvider>(context, listen: false);

    if (kDebugMode) {
      print(user.uid);
    }

    data.setUserData(UserModel(
      uid: user.uid,
      email: user.email,
    ));

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data();
      data.setUserData(UserModel(
        name: userData?['displayName'],
        uid: userData?['uid'],
        bio: userData?['bio'],
        phoneNumber: userData?['phoneNumber'],
        dob: userData?['dob'],
        gender: userData?['gender'],
        language: userData?['language'],
        avatarUrl: userData?['avatarUrl'],
        username: userData?['username'],
        email: userData?['email'],
      ));
    }

    if (data.userData.username == null || data.userData.username == '') {
      SystemNavigator.pop();
    }
  }

  void initializeOneSignal() {
    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("6b7604f1-6ca9-454d-add0-a850fce22ec8");

// // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//     OneSignal.Notifications.requestPermission(true);
  }

  @override
  void initState() {
    super.initState();

    if (widget.isFollowingTab != null) {
      setState(() {
        _isForYouTab = widget.isFollowingTab!;
      });
    }
    fetchForYouQuizzes(false);
    _tabController = TabController(length: 9999, vsync: this);

    updateAppLaunched(context);
    saveUserData(context);
    initializeOneSignal();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  bool _isFirstTime = true;

  bool _isReloadQuizForYou = false;
  bool _isReloadQuizFollowings = false;

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (kDebugMode) {
        print(_tabController.index);
      }
      final createdAtTab =
          timestampToString(forYouQuizzes[_tabController.index].createdAt!);
      await prefs.setString('lastCreatedAt', createdAtTab);
      if (_tabController.index == forYouTabLength && _isForYouTab) {
        setState(() {
          _isReloadQuizForYou = true;
        });
      }

      if (_tabController.index == followingTabLemgth && !_isForYouTab) {
        setState(() {
          _isReloadQuizFollowings = true;
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/share-quiz.appspot.com/o/myfiles%2Fezgif-4-e8a7f6764c.gif?alt=media&token=1e048c6a-74cd-4d44-bb79-90671ecc20f9',
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fadeInDuration: const Duration(milliseconds: 200),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isForYouTab = false;
                        _tabController.index = 0;
                      });
                      if (_isFirstTime) {
                        fetchFollowingsQuizzes(false);
                        _isFirstTime = false;
                      }
                    },
                    child: Text(
                      'Following',
                      style: _isForYouTab
                          ? TextStyle(
                              fontSize: 16,
                              color: white.withOpacity(.5),
                            )
                          : const TextStyle(
                              fontSize: 17,
                              color: white,
                              fontWeight: FontWeight.bold),
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
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isForYouTab = true;
                        _tabController.index = 0;
                      });
                      if (_isFirstTime) {
                        fetchForYouQuizzes(false);
                        _isFirstTime = false;
                      }
                    },
                    child: Text(
                      'For You',
                      style: !_isForYouTab
                          ? TextStyle(
                              fontSize: 16,
                              color: white.withOpacity(.5),
                            )
                          : const TextStyle(
                              fontSize: 17,
                              color: white,
                              fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        showSearchPopup(context);
                      },
                      icon: const Icon(CupertinoIcons.search)),
                  IconButton(
                      onPressed: () async {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    isFollowingTab: _isForYouTab,
                                  )),
                        );
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove('lastCreatedAt');
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
      body: _isLoading
          ? const LoadingWidget()
          : !_isForYouTab
              ? _isReloadQuizFollowings
                  ? reload()
                  : getBody(followingQuizzes)
              : _isReloadQuizForYou
                  ? reload()
                  : getBody(forYouQuizzes),
    );
  }

  Widget reload() {
    return Center(
      child: Container(
        width: 200,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              if (_isForYouTab) {
                fetchForYouQuizzes(true);
                forYouTabLength = forYouTabLength + 19;
                _isReloadQuizForYou = false;
              }

              if (!_isForYouTab) {
                fetchFollowingsQuizzes(true);
                followingTabLemgth = followingTabLemgth + 19;
                _isReloadQuizFollowings = false;
              }
            });
          },
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all(Colors.white), // Text color
          ),
          child: const Text(
            'Load More Quizzes',
            style: TextStyle(
              fontSize: 16.0, // Text size
              fontWeight: FontWeight.bold, // Text weight
            ),
          ),
        ),
      ),
    );
  }

  Widget getBody(List<CreateQuizDataModel> quizItems) {
    var size = MediaQuery.of(context).size;

    return RotatedBox(
      quarterTurns: 1,
      child: TabBarView(
        controller: _tabController,
        children: List.generate(
          quizItems.length,
          (index) {
            return RotatedBox(
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
                    difficulty: quizItems[index].difficulty,
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
    this.difficulty,
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
  final String? difficulty;

  @override
  State<QuizTikTokItems> createState() => _QuizTikTokItemsState();
}

class _QuizTikTokItemsState extends State<QuizTikTokItems>
    with SingleTickerProviderStateMixin {
  updateViewsHere() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    if (!data.quizViews.contains(widget.quizID)) {
      final quizCollection =
          await firestore.collection('allQuizzes').doc(widget.quizID).get();

      await quizCollection.reference.update({'views': FieldValue.increment(1)});

      data.setNewQuizViews(widget.quizID!);
    }
  }

  bool isViewsUpdated = false;

  @override
  Widget build(BuildContext context) {
    if (!isViewsUpdated) {
      updateViewsHere();
      updateViews(widget.quizID, widget.creatorUserID);
      isViewsUpdated = true;
    }

    String quizDescription = widget.quizDescription!;
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => InsideQuizScreen(
                                              quizID: widget.quizID!,
                                            )),
                                  );
                                },
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
                                      quizDescription!,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    )),
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
                                                  quizID: widget.quizID!,
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
                              quizID: widget.quizID!,
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
                              quizTitle: widget.quizTitle!,
                              quizDescription: widget.quizDescription!,
                              difficulty: widget.difficulty!,
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
                          widget.difficulty!,
                          style: const TextStyle(color: Colors.white),
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
