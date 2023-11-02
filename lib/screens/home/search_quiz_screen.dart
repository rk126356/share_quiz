import 'package:flutter/material.dart';

class SearchQuizScreen extends StatefulWidget {
  const SearchQuizScreen({super.key});

  @override
  State<SearchQuizScreen> createState() => _SearchQuizScreenState();
}

class _SearchQuizScreenState extends State<SearchQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Quiz',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(
                height:
                    20), // Add some space between the search bar and the button

            // Search Button
            ElevatedButton(
              onPressed: () {
                // Implement your search functionality here
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Button background color
                onPrimary: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
