import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/utils/generate_quizid.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  CreateQuizDataModel quizData = CreateQuizDataModel();
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> choiceControllers =
      List.generate(6, (index) => TextEditingController());

  List<Quizzes> previewQuestions = [];

  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to show the add question dialog
  Future<void> _showAddQuestionDialog() async {
    String? selectedCorrectAns = '0';
    int choiceCount = 2;

    questionController.clear();
    for (var controller in choiceControllers) {
      controller.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 12,
          scrollable: true,
          title: const Text(
            "Add Question",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  for (int i = 0; i < choiceCount; i++)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Checkbox(
                            value: selectedCorrectAns == i.toString(),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value != null && value) {
                                  selectedCorrectAns = i.toString();
                                } else {
                                  selectedCorrectAns = null;
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: choiceControllers[i],
                            decoration: InputDecoration(
                              labelText: 'Choice ${i + 1}',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (choiceCount < 6)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (choiceCount < 6) {
                            choiceCount++;
                          }
                        });
                      },
                      child: const Text("Add Choice"),
                    ),
                ],
              );
            },
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (questionController.text.isNotEmpty &&
                      selectedCorrectAns != null) {
                    previewQuestions.add(Quizzes(
                      questionTitle: questionController.text,
                      choices: choiceControllers
                          .map((controller) => controller.text)
                          .toList()
                          .sublist(0, choiceCount),
                      correctAns: selectedCorrectAns,
                    ));

                    questionController.clear();
                    for (var controller in choiceControllers) {
                      controller.clear();
                    }
                    selectedCorrectAns = null;
                    Navigator.of(context).pop();
                  }

                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child:
                    const Text("Save Question", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       duration: Duration(seconds: 3), // Adjust the duration as needed
  //     ),
  //   );
  // }

  saveQuiz(data) async {
    if (quizData.quizTitle!.isNotEmpty &&
        quizData.quizDescription!.isNotEmpty &&
        previewQuestions.length > 1 &&
        quizData.categories!.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      quizData.quizzes = previewQuestions;
      quizData.quizID = generateQuizID();
      quizData.likes = 0;
      quizData.disLikes = 0;
      quizData.taken = 0;
      quizData.views = 0;
      quizData.wins = 0;
      quizData.creatorName = data.userData.name;
      quizData.creatorImage = data.userData.avatarUrl;
      quizData.topScorerImage = '';
      quizData.topScorerName = 'No One';
      quizData.shares = 0;
      quizData.creatorUserID = data.userData.uid;
      quizData.createdAt = DateTime.now().toString();

      quizData.noOfQuestions = previewQuestions.length;
      await _firestore
          .collection('users')
          .doc(data.userData.uid)
          .collection('myQuizzes')
          .doc(quizData.quizID)
          .set(quizData.toJson());
      previewQuestions.clear();
      questionController.clear();
      for (var controller in choiceControllers) {
        controller.clear();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Quiz"),
        backgroundColor: AppColors.primaryColor, // Dark purple app bar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.title,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Quiz Title',
                        ),
                        onChanged: (text) {
                          setState(() {
                            quizData.quizTitle = text;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Quiz Description',
                        ),
                        onChanged: (text) {
                          setState(() {
                            quizData.quizDescription = text;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.tag_fill,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Quiz Tags',
                          helperText: "Ex: Sports, Football, Personal",
                        ),
                        onChanged: (text) {
                          setState(() {
                            final tags = text.split(',');
                            quizData.categories = tags;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _showAddQuestionDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Vibrant green button
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white, // White icon color
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Add Question",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveQuiz(data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          CupertinoColors.activeBlue, // Bold orange button
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.save,
                          color: Colors.white, // White icon color
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Save Quiz",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (previewQuestions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Preview Questions:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text color
                      ),
                    ),
                    for (int i = 0; i < previewQuestions.length; i++)
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            previewQuestions[i].questionTitle!,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors
                                    .deepPurple), // Dark purple text color
                          ),
                          subtitle: Text(
                            "Choices: ${previewQuestions[i].choices?.join(', ')}",
                            style: const TextStyle(
                                color: Colors.indigo), // Indigo text color
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                previewQuestions.remove(previewQuestions[i]);
                              });
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red, // Red icon color
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
