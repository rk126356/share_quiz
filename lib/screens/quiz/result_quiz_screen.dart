import 'package:flutter/material.dart';
import 'package:share_quiz/navigation.dart';
import 'package:share_quiz/screens/home/home_screen.dart';

class ResultQuizScreen extends StatefulWidget {
  final int score;

  const ResultQuizScreen({Key? key, required this.score}) : super(key: key);

  @override
  State<ResultQuizScreen> createState() => _ResultQuizScreenState();
}

class _ResultQuizScreenState extends State<ResultQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Score: ${widget.score}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("GO BACK"))
          ],
        ),
      ),
    );
  }
}
