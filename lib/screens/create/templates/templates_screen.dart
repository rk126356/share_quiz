import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/quiz_template_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/data/quiz-templates/adventureTimeQuiz.dart';
import 'package:share_quiz/data/quiz-templates/literaryExplorerQuiz.dart';
import 'package:share_quiz/data/quiz-templates/movieBuffQuiz.dart';
import 'package:share_quiz/data/quiz-templates/myQuestions1.dart';
import 'package:share_quiz/data/quiz-templates/myTravelPreferencesQuiz.dart';
import 'package:share_quiz/data/quiz-templates/personalQuiz.dart';
import 'package:share_quiz/data/quiz-templates/sportsFanaticQuiz.dart';
import 'package:share_quiz/data/quiz-templates/techGeekTrivia.dart';
import 'package:share_quiz/screens/create/templates/inside_template_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({Key? key}) : super(key: key);

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<QuizTemplate> templateQuizItems = [
    QuizTemplate(
      templateQuizzes: personalQuiz,
      templateQuizTitle: "Discovering [Your Name]",
      templateQuizDescription:
          "This is the most popular quizzes, please edit the title and description.",
      templateQuizTags: 'personal, friends',
    ),
    QuizTemplate(
      templateQuizzes: myQuestions,
      templateQuizTitle: "Discovering [Your Name]: A Quiz About Me!",
      templateQuizDescription:
          "Welcome to the ultimate quiz about [Your Name]! Test your knowledge of [Your Name]'s preferences, favorites, and lifestyle. Dive into details, from colors to travel destinations, and discover what makes [Your Name] unique.",
      templateQuizTags: 'personal, friends',
    ),
    QuizTemplate(
      templateQuizzes: myTravelPreferencesQuiz,
      templateQuizTitle: "Travel Preferences Quiz",
      templateQuizDescription:
          "Dive into my wanderlust with the 'Travel Quiz'! Guess dream destinations, preferred stays, and more. Challenge friends to reveal the traveler in me!",
      templateQuizTags: 'Travel',
    ),
    QuizTemplate(
      templateQuizzes: adventureTimeQuiz,
      templateQuizTitle: "Discovering [Your Name]: Adventure Time Quiz",
      templateQuizDescription:
          "Unleash adventure with the 'Adventure Time Quiz'! From heart-pounding activities to dream destinations, discover the thrill-seeker in me. Who's the ultimate aficionado among your friends?",
      templateQuizTags: 'adventure, friends',
    ),
    QuizTemplate(
      templateQuizzes: sportsFanaticQuiz,
      templateQuizTitle: "Discovering [Your Name]: Sports Fanatic Quiz",
      templateQuizDescription:
          "Dive into sports with the 'Sports Fanatic Quiz.' Test your knowledge of my teams, workouts, and heart-racing sports moments. Can your friends claim victory in the arena of my sports passions? Let the games begin!",
      templateQuizTags: 'personal, sports',
    ),
    QuizTemplate(
      templateQuizzes: movieBuffQuiz,
      templateQuizTitle: "Discovering [Your Name]: Movie Buff Quiz",
      templateQuizDescription:
          "Step into cinema with the 'Movie Buff Quiz'! Test knowledge of my films, genres, and quotes. Can friends predict the blockbuster details in my cinematic journey? Let the movie magic unfold!",
      templateQuizTags: 'personal, movie, flim',
    ),
    QuizTemplate(
      templateQuizzes: techGeekTrivia,
      templateQuizTitle: "Discovering [Your Name]: Tech Geek Trivia",
      templateQuizDescription:
          "Tech Geek Trivia: Test knowledge of my tech preferences, gadgets, and digital obsessions. From cutting-edge innovations to geekery, can your friends emerge as the ultimate tech connoisseur?",
      templateQuizTags: 'tech, friends',
    ),
    QuizTemplate(
      templateQuizzes: literaryExplorerQuiz,
      templateQuizTitle: "Discovering [Your Name]: Literary Explorer Quiz",
      templateQuizDescription:
          "Embark on a literary journey with the 'Literary Explorer Quiz.' Test knowledge of my reading preferences and favorite authors. Can your friends claim the title of the ultimate literary explorer in this quiz of words and wonders?",
      templateQuizTags: 'Literary, books',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Templates'),
      ),
      body: ListView.builder(
        itemCount: templateQuizItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: index + 1 == templateQuizItems.length
                ? const EdgeInsets.only(top: 8, bottom: 32, right: 8, left: 8)
                : const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color:
                  predefinedColors[Random().nextInt(predefinedColors.length)],
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InsideTemplateScreen(
                        template: templateQuizItems[index],
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Add padding inside the card
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          templateQuizItems[index].templateQuizTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10), // Add some vertical spacing
                        Text(
                          templateQuizItems[index].templateQuizDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
