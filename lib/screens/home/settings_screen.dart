import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/history/my_disliked_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_likes_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_played_quizzes_screen.dart';
import 'package:share_quiz/screens/profile/history/my_shared_quizzes.dart';
import 'package:share_quiz/utils/launch_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              tryLaunchUrl('https://sharequiz.in/');
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
              tryLaunchUrl('https://sharequiz.in/contact-us/');
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
              tryLaunchUrl('https://sharequiz.in/terms-and-conditions/');
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
              tryLaunchUrl('https://sharequiz.in/privacy-policy/');
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
              tryLaunchUrl('https://sharequiz.in/delete-your-account/');
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
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              if (!kIsWeb && !kDebugMode) {
                SystemNavigator.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ],
      ),
    );
  }
}
