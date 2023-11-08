import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/search/enter_quiz_code_screen.dart';
import 'package:share_quiz/screens/search/search_quizzes_screen.dart';
import 'package:share_quiz/screens/search/search_tags_screen.dart';
import 'package:share_quiz/screens/search/search_user_screen.dart';
import 'package:share_quiz/widgets/search_popup_widget.dart';

void showSearchPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero, // Remove default padding
        backgroundColor: Colors.transparent, // Remove default background color
        content: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 8, 3, 162),
                Color.fromARGB(255, 83, 3, 244)
              ], // Create a cool gradient background
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20), // Add rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Add a subtle shadow
                blurRadius: 10,
                offset: const Offset(0, 5), // Offset the shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Search Options',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white, // Use white text to contrast with the gradient background
                  ),
                  textAlign: TextAlign.center, // Center the heading text
                ),
                const SizedBox(
                  height: 10,
                ),
                buildSearchButton(
                    context,
                    'Search Users',
                    AppColors.primaryColor,
                    const Icon(CupertinoIcons.group), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchUsersScreen()),
                  );
                }),
                buildSearchButton(context, 'Search Quizzes', Colors.green,
                    const Icon(CupertinoIcons.cube_box), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchQuizzesScreen()),
                  );
                }),
                buildSearchButton(context, 'Search Tags', Colors.orange,
                    const Icon(Icons.numbers), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchTagsScreem()),
                  );
                }),
                buildSearchButton(context, 'Play With Quiz Code',
                    Color(0xFF0044FF), const Icon(CupertinoIcons.play), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EnterQuizCodeScreen()),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}
