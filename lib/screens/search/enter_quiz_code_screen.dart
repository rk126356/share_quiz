import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';

class EnterQuizCodeScreen extends StatefulWidget {
  const EnterQuizCodeScreen({Key? key}) : super(key: key);

  @override
  _EnterQuizCodeScreenState createState() => _EnterQuizCodeScreenState();
}

class _EnterQuizCodeScreenState extends State<EnterQuizCodeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play With Quiz Code'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0044FF), Color(0xFF7700FF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                padding: const EdgeInsets.all(16.0),
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
                          hintText: 'Enter Quiz Code (e.g., d1313dax)',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.blue),
                        ),
                        onChanged: (value) {
                          _searchController.text = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor:
                      AppColors.primaryColor, // Match the gradient color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InsideQuizScreen(
                              quizID: _searchController.text,
                            )),
                  );
                },
                child: const Text(
                  'Go',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
