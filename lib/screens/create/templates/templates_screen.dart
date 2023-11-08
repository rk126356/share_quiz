import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/quiz_template_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/create/templates/inside_template_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({Key? key}) : super(key: key);

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

List<Quizzes> westBengalQuestions = [
  Quizzes(
    questionTitle: "What is the capital of West Bengal?",
    choices: ["Kolkata", "Howrah", "Siliguri", "Durgapur"],
    correctAns: '0',
  ),
  Quizzes(
    questionTitle:
        "Which river flows through Kolkata, the largest city in West Bengal?",
    choices: ["Ganges", "Yamuna", "Brahmaputra", "Hooghly"],
    correctAns: '3',
  ),
  Quizzes(
    questionTitle:
        "What is the famous sweet made from cottage cheese in West Bengal?",
    choices: ["Rasgulla", "Gulab Jamun", "Jalebi", "Barfi"],
    correctAns: '0',
  ),
  Quizzes(
    questionTitle:
        "Which festival is celebrated with grand processions and idol immersions in West Bengal?",
    choices: ["Diwali", "Holi", "Durga Puja", "Eid"],
    correctAns: '2',
  ),
  Quizzes(
    questionTitle:
        "What is the national park in West Bengal known for its Royal Bengal tigers?",
    choices: [
      "Sundarbans National Park",
      "Buxa Tiger Reserve",
      "Jaldapara National Park",
      "Neora Valley National Park"
    ],
    correctAns: '0',
  ),
  Quizzes(
    questionTitle: "Which famous poet and Nobel laureate was from West Bengal?",
    choices: [
      "Rabindranath Tagore",
      "Kazi Nazrul Islam",
      "Sukumar Ray",
      "Bankim Chandra Chattopadhyay"
    ],
    correctAns: '0',
  ),
  Quizzes(
    questionTitle: "What is the traditional folk dance of West Bengal?",
    choices: ["Bharatanatyam", "Kuchipudi", "Kathak", "Baul"],
    correctAns: '3',
  ),
  Quizzes(
    questionTitle:
        "Which is the famous cricket stadium in Kolkata, often called the 'Eden Gardens'?",
    choices: [
      "M. Chinnaswamy Stadium",
      "Wankhede Stadium",
      "Rajiv Gandhi International Cricket Stadium",
      "Eden Gardens"
    ],
    correctAns: '3',
  ),
  Quizzes(
    questionTitle: "What is the official language of West Bengal?",
    choices: ["Hindi", "Bengali", "English", "Oriya"],
    correctAns: '1',
  ),
  Quizzes(
    questionTitle:
        "Which famous religious site in West Bengal is known for its annual chariot festival?",
    choices: [
      "Belur Math",
      "Kali Temple",
      "Dakshineswar Temple",
      "ISKCON Mayapur"
    ],
    correctAns: '2',
  ),
];

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<QuizTemplate> templateQuizItems = [
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    ),
    QuizTemplate(
      templateQuizzes: westBengalQuestions,
      templateQuizTitle: "West Bengal Knowledge Quiz",
      templateQuizDescription:
          "Test your knowledge about the Indian state of West Bengal with this easy quiz!",
      templateQuizTags: 'West Bengal, India',
    )
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
