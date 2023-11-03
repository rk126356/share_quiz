import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/create_profile_screen.dart';
import 'package:share_quiz/screens/profile/my_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/user_quizzes_screen.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class InsideProfileScreen extends StatefulWidget {
  final String userId;
  const InsideProfileScreen({super.key, required this.userId});

  @override
  State<InsideProfileScreen> createState() => _InsideProfileScreenState();
}

class _InsideProfileScreenState extends State<InsideProfileScreen> {
  bool _isLoading = false;
  late UserModel user;
  final List<CreateQuizDataModel> quizItems = [];

  Future<void> fetchQuizzes(String userId) async {
    final firestore = FirebaseFirestore.instance;

    quizItems.clear();

    final quizCollection = await firestore
        .collection('allQuizzes')
        .where('creatorUserID', isEqualTo: userId)
        .get();

    for (final quizDoc in quizCollection.docs) {
      final quizData = quizDoc.data();
      final quizItem = CreateQuizDataModel(
        quizID: quizData['quizID'],
        quizDescription: quizData['quizDescription'],
        quizTitle: quizData['quizTitle'],
        likes: quizData['likes'],
        views: quizData['views'],
        taken: quizData['taken'],
        categories: quizData['categories'],
        noOfQuestions: quizData['noOfQuestions'],
        creatorImage: quizData['creatorImage'],
        creatorName: quizData['creatorName'],
        creatorUserID: quizData['creatorUserID'],
      );

      quizItems.add(quizItem);
    }
    setState(() {});
  }

  Future<void> fetchUser(String userId) async {
    _isLoading = true;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      if (kDebugMode) {
        print('User found');
      }
      final userData = userDocSnapshot.data();
      try {
        user = UserModel(
          name: userData?['displayName'],
          uid: userData?['uid'],
          email: userData!['email'],
          username: userData['username'],
          bio: userData['bio'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          dob: userData['dob'] ?? '',
          gender: userData['gender'] ?? '',
          avatarUrl: userData['avatarUrl'] ?? '',
          noOfQuizzes: userData['noOfQuizzes'] ?? 0,
          noOfFollowers: userData['noOfFollowers'] ?? 0,
          noOfFollowings: userData['noOfFollowings'] ?? 0,
        );
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      if (kDebugMode) {
        print('User not found');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  bool isAppBarExpanded = false;
  late ScrollController _scrollController;

  void _updateScrollPosition() {
    setState(() {
      isAppBarExpanded =
          _scrollController.hasClients && _scrollController.offset > 250;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser(widget.userId);
    fetchQuizzes(widget.userId);
    _scrollController = ScrollController()..addListener(_updateScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget());
    }
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController, // Add the scroll controller here
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: AppColors.primaryColor,
            expandedHeight: 380,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: isAppBarExpanded ? Text('@${user.username!}') : null,
              background: _ProfileAvatar(
                user: user,
              ),
            ),
            actions: [
              data.userData.uid == user.uid
                  ? IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateProfileScreen(
                                    isEdit: true,
                                  )),
                        );
                      },
                    )
                  : IconButton(
                      icon: const Icon(CupertinoIcons.info),
                      onPressed: () {
                        // Add your report functionality here
                      },
                    ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (quizItems.isEmpty) {
                  return const Center(
                    child: Text("No quizzes found"),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: quizItems.length - 1 == index ? 30.0 : 0.0,
                    ),
                    child: QuizCardItems(
                      quizData: quizItems[index],
                    ),
                  );
                }
              },
              childCount: quizItems.isEmpty ? 1 : quizItems.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  final UserModel user;

  const _ProfileAvatar({required this.user});
  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.indigo],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Stack(
              alignment: Alignment
                  .bottomRight, // Align the edit icon to the bottom right
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(widget.user.avatarUrl!),
                  ),
                ),
              ],
            ),
            _ProfileInfo(
              user: widget.user,
            ),
            data.userData.uid == widget.user.uid
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyQuizzesScreen()),
                          );
                        },
                        heroTag: 'follow',
                        elevation: 0,
                        label: const Text("My Quizzes"),
                        icon: const Icon(CupertinoIcons.cube_box),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {},
                        heroTag: 'follow',
                        elevation: 0,
                        label: const Text("Follow"),
                        icon: const Icon(Icons.person_add_alt_1),
                      ),
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserModel user;

  const _ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            data.userData.name!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '@${user.username}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.bio ?? 'No Bio',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _ProfileStats(
            user: user,
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final UserModel user;

  const _ProfileStats({required this.user});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem("Quizzes", '${user.noOfQuizzes ?? 0}', () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserQuizzesScreen(
                      uid: user.uid!,
                      username: user.username!,
                    )),
          );
        }),
        _StatItem("Followers", '${user.noOfFollowers ?? 0}', () {}),
        _StatItem("Following", '${user.noOfFollowings ?? 0}', () {}),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatItem(this.label, this.value, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
