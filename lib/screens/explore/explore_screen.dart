import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/all_tags_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';
import 'package:share_quiz/screens/search/enter_quiz_code_screen.dart';
import 'package:share_quiz/screens/search/search_quizzes_screen.dart';
import 'package:share_quiz/screens/search/search_tags_screen.dart';
import 'package:share_quiz/screens/search/search_user_screen.dart';
import 'package:share_quiz/utils/search_popup.dart';
import 'package:share_quiz/widgets/all_tags_box_widget.dart';
import 'package:share_quiz/widgets/loading_widget.dart';
import 'package:share_quiz/widgets/search_popup_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Dummy leaderboard data
  final List<UserModel> topPlayers = [];

  final List tagItems = [];

  bool _isLoading = false;

  Future<void> fetchTagsAndPlayers() async {
    setState(() {
      _isLoading = true;
    });
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore
        .collection('users')
        .orderBy('noOfQuizzes', descending: true)
        .limit(3)
        .get();

    for (final users in userDoc.docs) {
      final user = users.data();

      final newUser = UserModel(
        name: user['displayName'],
        uid: user['uid'],
        avatarUrl: user['avatarUrl'],
        noOfQuizzes: user['noOfQuizzes'],
      );

      topPlayers.add(newUser);
    }

    final quizCollection = await firestore.collection('allQuizzes').get();

    for (final tagDoc in quizCollection.docs) {
      final tagData = tagDoc.data();
      final tagItem = tagData['categories'];

      for (final tag in tagItem) {
        if (tagItems.length < 9) {
          if (!tagItems.contains(tag)) {
            tagItems.add(tag);
          } else {}
        } else {
          break;
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTagsAndPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Explore"),
        actions: [
          IconButton(
              onPressed: () {
                showSearchPopup(context);
              },
              icon: const Icon(CupertinoIcons.search))
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    // Top Players This Month leaderboard
                    const SizedBox(height: 8.0),
                    const Text(
                      "Top 3 Users",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      children: topPlayers.asMap().entries.map((entry) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: const EdgeInsets.only(top: 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InsideProfileScreen(
                                          userId: entry.value.uid!,
                                        )),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              backgroundImage:
                                  NetworkImage(entry.value.avatarUrl!),
                            ),
                            title: Text(
                              entry.value.name!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              "Quiz Created: ${entry.value.noOfQuizzes}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(
                      height: 22,
                    ),
                    const Text(
                      "Recent Tags",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(tagItems.length, (index) {
                        return AllTagsBox(
                          title: tagItems[index],
                          backgroundColor: predefinedColors[
                              Random().nextInt(predefinedColors.length)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InsideQuizTagScreen(
                                        tag: tagItems[index],
                                      )),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ALlTagsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        child: const Text("See All Tags"),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
