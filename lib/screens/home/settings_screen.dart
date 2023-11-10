import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/history/my_disliked_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_likes_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_played_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_shared_quizzes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            leading:
                const Icon(CupertinoIcons.info, color: AppColors.primaryColor),
            title: const Text("About Us"),
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
          ListTile(
            leading:
                const Icon(CupertinoIcons.mail, color: AppColors.primaryColor),
            title: const Text("Contact Us"),
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
          ListTile(
            leading: const Icon(CupertinoIcons.shield,
                color: AppColors.primaryColor),
            title: const Text("Terms of Service"),
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
                const Icon(CupertinoIcons.lock, color: AppColors.primaryColor),
            title: const Text("Privacy Policy"),
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
            leading: const Icon(CupertinoIcons.delete,
                color: AppColors.primaryColor),
            title: const Text("Delete Account"),
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
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
