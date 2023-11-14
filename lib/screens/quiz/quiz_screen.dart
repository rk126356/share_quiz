import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/quiz_data_class.dart';
import 'package:share_quiz/screens/profile/create_profile_screen.dart';
import 'package:share_quiz/screens/quiz/all_tags_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';
import 'package:share_quiz/screens/quiz/tabs/all_quiz_tab.dart';
import 'package:share_quiz/screens/quiz/tabs/easy_quiz_tab.dart';
import 'package:share_quiz/screens/quiz/tabs/hard_quiz_tab.dart';
import 'package:share_quiz/screens/quiz/tabs/new_quiz_tab.dart';
import 'package:share_quiz/screens/quiz/tabs/popular_quiz_tab.dart';
import 'package:share_quiz/screens/quiz/tabs/likes_quiz_tab.dart';
import 'package:share_quiz/screens/quiz/tabs/recommended_quiz_tab.dart';
import 'package:share_quiz/utils/search_popup.dart';
import 'package:share_quiz/widgets/small_category_box_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {
              showSearchPopup(context);
            },
          )
        ],
        backgroundColor: CupertinoColors.activeBlue,
        title: const Text('Quizzes'),
      ),
      body: DefaultTabController(
        length: 7, // Number of tabs
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SmallCategoryBox(
                      title: 'All Tags',
                      backgroundColor: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ALlTagsScreen()),
                        );
                      },
                    ),
                    SmallCategoryBox(
                      title: 'Entertainment',
                      backgroundColor: Colors.blue,
                      onTap: () {},
                    ),
                    SmallCategoryBox(
                      title: 'JEE Main',
                      backgroundColor: Colors.pink,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InsideQuizTagScreen(
                                    tag: '#JEE Main',
                                  )),
                        );
                      },
                    ),
                    SmallCategoryBox(
                      title: 'India',
                      backgroundColor: Colors.deepOrangeAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InsideQuizTagScreen(
                                    tag: '#india',
                                  )),
                        );
                      },
                    ),
                    SmallCategoryBox(
                      title: 'Bollywood',
                      backgroundColor: Colors.deepPurple,
                      onTap: () {},
                    ),
                    SmallCategoryBox(
                      title: 'Cricket',
                      backgroundColor: Colors.black,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints.expand(height: 50),
              child: const TabBar(
                labelColor: Colors.blue, // Selected tab text color
                unselectedLabelColor: Colors.grey, // Unselected tab text color
                isScrollable: true, // Enable horizontal scrolling for tabs
                tabs: [
                  Tab(text: 'Recommended'),
                  Tab(text: 'Latest'),
                  Tab(text: 'Views'),
                  Tab(text: 'Likes'),
                  Tab(text: 'Easy'),
                  Tab(text: 'Medium'),
                  Tab(text: 'Hard'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  RecommendedQuizTab(),
                  AllQuizTab(),
                  PopularQuizTab(),
                  LikesQuizTab(),
                  EasyQuizTab(),
                  MediumQuizTab(),
                  HardQuizTab(),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            )
          ],
        ),
      ),
    );
  }
}
