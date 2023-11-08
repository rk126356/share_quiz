import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/create_profile_screen.dart';
import 'package:share_quiz/screens/profile/my_draft_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/my_followers_screen.dart';
import 'package:share_quiz/screens/profile/my_followings_screen.dart';
import 'package:share_quiz/screens/profile/my_private_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/my_quizzes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                _HeaderBackground(),
                _ProfileAvatar(),
              ],
            ),
            _QuickLinks(),
          ],
        ),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.indigo],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    var data = Provider.of<UserProvider>(context);

    return Center(
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
                  backgroundImage: NetworkImage(data.userData.avatarUrl ?? ''),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    Colors.blue, // Background color of the edit icon
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white, // Color of the edit icon
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateProfileScreen(
                                isEdit: true,
                              )),
                    );
                  },
                ),
              ),
            ],
          ),
          _ProfileInfo(user: user!),
        ],
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final User user;

  const _ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var userData = snapshot.data?.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                userData['displayName'] ?? '',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '@${userData['username']}' ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userData['bio'] ?? 'No bio available',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _ProfileStats(user: user),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final User user;

  const _ProfileStats({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var userData = snapshot.data?.data() as Map<String, dynamic>;
        var followers = userData['noOfFollowers'] ?? 0;
        var quizzes = userData['noOfQuizzes'] ?? 0;
        var followings = userData['noOfFollowings'] ?? 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyQuizzesScreen(),
                  ),
                );
              },
              child: _StatItem("Quizzes", quizzes.toString()),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyFollowersScreen(),
                  ),
                );
              },
              child: _StatItem("Followers", followers.toString()),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyFollowingsScreen(),
                  ),
                );
              },
              child: _StatItem("Following", followings.toString()),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _QuickLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading:
              const Icon(CupertinoIcons.pencil, color: AppColors.primaryColor),
          title: const Text("Edit Profile"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateProfileScreen(
                  isEdit: true,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading:
              const Icon(CupertinoIcons.cube, color: AppColors.primaryColor),
          title: const Text("My Quizzes"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyQuizzesScreen()),
            );
          },
        ),
        ListTile(
          leading:
              const Icon(CupertinoIcons.lock, color: AppColors.primaryColor),
          title: const Text("Private Quizzes"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyPrivateQuizzesScreen()),
            );
          },
        ),
        ListTile(
          leading:
              const Icon(CupertinoIcons.folder, color: AppColors.primaryColor),
          title: const Text("My Drafts"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyDraftQuizzesScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(CupertinoIcons.arrow_2_circlepath,
              color: AppColors.primaryColor),
          title: const Text("My History"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateProfileScreen(
                  isEdit: true,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(CupertinoIcons.settings,
              color: AppColors.primaryColor),
          title: const Text("Settings"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () {
            // Handle navigation to the settings screen.
          },
        ),
        ListTile(
          leading: const Icon(CupertinoIcons.exclamationmark,
              color: AppColors.primaryColor),
          title: const Text("Log Out"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () async {
            await GoogleSignIn().signOut();
            FirebaseAuth.instance.signOut();
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.clear();
          },
        ),
        ListTile(
          leading: const Icon(CupertinoIcons.exclamationmark,
              color: AppColors.primaryColor),
          title: const Text("Clear Data"),
          trailing: const Icon(
            CupertinoIcons.forward,
            color: AppColors.primaryColor,
          ),
          onTap: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.clear();
          },
        ),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }
}
