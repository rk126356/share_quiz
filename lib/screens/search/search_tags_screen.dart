import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_tag_screen.dart';
import 'package:share_quiz/widgets/category_home_widget.dart';
import 'package:share_quiz/widgets/small_category_box_widget.dart';

class SearchTagsScreem extends StatefulWidget {
  const SearchTagsScreem({Key? key}) : super(key: key);

  @override
  _SearchTagsScreemState createState() => _SearchTagsScreemState();
}

class _SearchTagsScreemState extends State<SearchTagsScreem> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('allTags');
  List<DocumentSnapshot> _searchResults = [];

  void _searchUsers(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    _usersCollection
        .where('category',
            isGreaterThanOrEqualTo: searchText.toLowerCase(),
            isLessThan: '${searchText}z')
        .limit(10)
        .get()
        .then((querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search #Tags'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search #tags',
                  hintText: 'Start with #, e.g., #football',
                  hintStyle: const TextStyle(
                      color: Colors.grey), // Customize hint text color
                  border: OutlineInputBorder(
                    // Customize border
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2.0),
                  ),
                ),
                onChanged: (text) => _searchUsers(text),
              )),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var category =
                          _searchResults[index].data() as Map<String, dynamic>;
                      return CategoryBox(
                          title: category['category'],
                          backgroundColor: predefinedColors[
                              Random().nextInt(predefinedColors.length)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InsideQuizTagScreen(
                                        tag: category['category'],
                                      )),
                            );
                          });
                    },
                  )
                : const Center(
                    child: Text(
                      'No tags found\n\nMake sure to start with #, e.g., #football',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
