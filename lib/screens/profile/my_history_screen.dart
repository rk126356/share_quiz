import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/history/my_disliked_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_likes_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_played_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_shared_quizzes.dart';
import 'package:share_quiz/screens/profile/history/my_viewed_quizzes.dart';

class MyHistoryScreen extends StatefulWidget {
  const MyHistoryScreen({super.key});

  @override
  State<MyHistoryScreen> createState() => _MyHistoryScreenState();
}

class _MyHistoryScreenState extends State<MyHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('My History'),
      ),
      body: Column(
        children: [
          ListTile(
            leading:
                const Icon(CupertinoIcons.eye, color: AppColors.primaryColor),
            title: const Text("Recently Viewed"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyViewedQuizzesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(CupertinoIcons.play, color: AppColors.primaryColor),
            title: const Text("Played Quizzes"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyPlayedQuizzesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(CupertinoIcons.share, color: AppColors.primaryColor),
            title: const Text("Shared Quizzes"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySharedQuizzesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.hand_thumbsup,
                color: AppColors.primaryColor),
            title: const Text("Liked Quizzes"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyLikedQuizzesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.hand_thumbsdown,
                color: AppColors.primaryColor),
            title: const Text("Disliked Quizzes"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyDislikedQuizzesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
