import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';
import 'package:share_quiz/widgets/all_tags_box_widget.dart';
import 'package:share_quiz/widgets/small_category_box_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Dummy leaderboard data
  final List<String> topPlayersThisMonth = [
    "Player 1",
    "Player 2",
    "Player 3",
  ];

  final List tagItems = [];

  Future<void> fetchTags() async {
    final firestore = FirebaseFirestore.instance;

    tagItems.clear();

    final quizCollection = await firestore.collection('allQuizzes').get();

    for (final tagDoc in quizCollection.docs) {
      final tagData = tagDoc.data();
      final tagItem = tagData['categories'];

      for (final tag in tagItem) {
        if (!tagItems.contains(tag)) {
          tagItems.add(tag);
        } else {}
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              // Search bar and button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Player",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      onPressed: () {
                        // Handle the search button action here
                      },
                      child: const Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Top Players This Month leaderboard
              const SizedBox(height: 22.0),
              const Text(
                "Top 3 Players This Week",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                children: topPlayersThisMonth.asMap().entries.map((entry) {
                  final index = entry.key;
                  final playerName = entry.value;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.only(top: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        playerName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "Quiz Completed: ${1000 - index * 50}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  child: const Text("See All Rankings"),
                ),
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
                height: 25,
              )
            ],
          ),
        ),
      ),
    );
  }
}
