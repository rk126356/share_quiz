import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';
import 'package:share_quiz/widgets/quiz_card_widget.dart';

class SearchQuizzesScreen extends StatefulWidget {
  const SearchQuizzesScreen({Key? key}) : super(key: key);

  @override
  _SearchQuizzesScreenState createState() => _SearchQuizzesScreenState();
}

class _SearchQuizzesScreenState extends State<SearchQuizzesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('allQuizzes');
  List<DocumentSnapshot> _searchResults = [];

  void _searchQuizzes(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    _usersCollection
        .where('quizTitleSubstrings', arrayContains: searchText)
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
        title: const Text('Search Quizzes'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search Quizzes",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.blue),
                      ),
                      onChanged: (value) {
                        _searchController.text = value;
                      },
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
                      _searchQuizzes(_searchController.text);
                    },
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var quizData =
                          _searchResults[index].data() as Map<String, dynamic>;

                      final quiz = CreateQuizDataModel(
                        quizID: quizData['quizID'],
                        quizDescription: quizData['quizDescription'],
                        quizTitle: quizData['quizTitle'],
                        likes: quizData['likes'],
                        views: quizData['views'],
                        taken: quizData['taken'],
                        categories: quizData['categories'],
                        noOfQuestions: quizData['noOfQuestions'],
                        creatorImage: quizData['creatorImage'],
                        creatorName: quizData['creatorName'],
                        creatorUserID: quizData['creatorUserID'],
                      );
                      return QuizCardItems(quizData: quiz);
                    },
                  )
                : const Center(
                    child: Text('No Quizzes Found.'),
                  ),
          ),
        ],
      ),
    );
  }
}
