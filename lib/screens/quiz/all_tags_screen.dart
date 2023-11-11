import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';
import 'package:share_quiz/screens/search/search_tags_screen.dart';
import 'package:share_quiz/widgets/all_tags_box_widget.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class ALlTagsScreen extends StatefulWidget {
  const ALlTagsScreen({Key? key}) : super(key: key);

  @override
  State<ALlTagsScreen> createState() => _ALlTagsScreenState();
}

class _ALlTagsScreenState extends State<ALlTagsScreen> {
  final List tagItems = [];
  final List topTags = ['#india', '#cricket', '#football'];
  int listLength = 9;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  Future<void> fetchTags(bool next, context) async {
    if (tagItems.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> tagsCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      tagsCollection = await firestore
          .collection('allTags')
          .orderBy('category')
          .startAfter([lastDocument?['category']])
          .limit(listLength)
          .get();
    } else {
      tagsCollection = await firestore
          .collection('allTags')
          .orderBy('category')
          .limit(listLength)
          .get();
    }

    if (tagsCollection.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No more tags available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocument =
        tagsCollection.docs.isNotEmpty ? tagsCollection.docs.last : null;

    for (final tagDoc in tagsCollection.docs) {
      final tagData = tagDoc.data();

      if (!tagItems.contains(tagData['category'])) {
        tagItems.add(tagData['category']);
      } else {
        if (kDebugMode) {
          print('${tagData['category']} already exists');
        }
      }
    }
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTags(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("All Tags"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchTagsScreem()),
                );
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
                    const SizedBox(height: 18.0),
                    const Text(
                      "Top 3 Tags This Week",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(topTags.length, (index) {
                        return AllTagsBox(
                          title: topTags[index],
                          backgroundColor: predefinedColors[
                              Random().nextInt(predefinedColors.length)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InsideQuizTagScreen(
                                        tag: topTags[index],
                                      )),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    const SizedBox(
                      height: 22,
                    ),
                    const Text(
                      "All Tags",
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
                    _buildLoadMoreButton(),

                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadMoreButton() {
    return _isButtonLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryColor, // Set the background color
                  ),
                  onPressed: () {
                    fetchTags(true, context);
                  },
                  child: const Text('Load More...'),
                ),
              ),
              const SizedBox(
                height: 30,
              )
            ],
          );
  }
}
