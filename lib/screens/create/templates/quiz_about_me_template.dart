import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/utils/generate_quizid.dart';

class QuizAboutMeTemplate extends StatefulWidget {
  const QuizAboutMeTemplate({Key? key}) : super(key: key);

  @override
  State<QuizAboutMeTemplate> createState() => _QuizAboutMeTemplateState();
}

class _QuizAboutMeTemplateState extends State<QuizAboutMeTemplate> {
  CreateQuizDataModel quizData = CreateQuizDataModel();
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> choiceControllers =
      List.generate(6, (index) => TextEditingController());
  int? selectedQuestionIndex;

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

    addQuestionPopup(choiceCount, selectedCorrectAns);
  }

  Future<dynamic> addQuestionPopup(
      int choiceCount, String? selectedCorrectAns) {
    return showDialog(
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

  // Function to show the edit question dialog
  Future<void> _showEditQuestionDialog(int index) async {
    selectedQuestionIndex = index;
    Quizzes selectedQuestion = previewQuestions[index];
    String? selectedCorrectAns = selectedQuestion.correctAns;
    int choiceCount = selectedQuestion.choices!.length;

    questionController.text = selectedQuestion.questionTitle!;
    for (int i = 0; i < choiceCount; i++) {
      choiceControllers[i].text = selectedQuestion.choices?[i];
    }

    editQuestionPopup(choiceCount, selectedCorrectAns);
  }

  Future<void> editQuestionPopup(int choiceCount, String? selectedCorrectAns) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 12,
          scrollable: true,
          title: const Text(
            "Edit Question",
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
                    Quizzes editedQuestion = Quizzes(
                      questionTitle: questionController.text,
                      choices: choiceControllers
                          .map((controller) => controller.text)
                          .toList()
                          .sublist(0, choiceCount),
                      correctAns: selectedCorrectAns,
                    );

                    previewQuestions[selectedQuestionIndex!] = editedQuestion;
                    questionController.clear();
                    for (var controller in choiceControllers) {
                      controller.clear();
                    }
                    selectedCorrectAns = null;
                    selectedQuestionIndex = null;
                    Navigator.of(context).pop();
                  }

                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child:
                    const Text("Save Changes", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

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
      quizData.topScorerImage =
          'https://www.nicepng.com/png/detail/186-1869910_ic-question-mark-roblox-question-mark-avatar.png';
      quizData.topScorerName = 'No One';
      quizData.shares = 0;
      quizData.creatorUserID = data.userData.uid;
      quizData.createdAt = Timestamp.now();
      quizData.timer = quizData.timer ?? 999;
      quizData.visibility = quizData.visibility ?? 'Public';
      quizData.creatorUsername = data.userData.username;
      quizData.noOfQuestions = previewQuestions.length;
      quizData.difficulty = quizData.difficulty ?? 'Medium';
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

  TextEditingController quizTitle = TextEditingController();
  TextEditingController quizDescription = TextEditingController();

  void initState() {
    super.initState();
    List<Quizzes> _westBengalQuestions = [
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
        questionTitle:
            "Which famous poet and Nobel laureate was from West Bengal?",
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

    quizTitle.text = "West Bengal Knowledge Quiz";
    quizDescription.text =
        "Test your knowledge about the Indian state of West Bengal with this easy quiz!";
    previewQuestions = _westBengalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 12,
          left: 12,
          right: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _showAddQuestionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Vibrant green button
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.add,
                    color: Colors.white, // White icon color
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Question",
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
                    CupertinoIcons.folder,
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
      ),
      appBar: AppBar(
        actions: [
          ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QuizAboutMeTemplate()),
                );
              },
              icon: const Icon(Icons.file_copy),
              label: const Text("Templates"))
        ],
        title: const Text("Create Quiz"),
        backgroundColor: AppColors.primaryColor, // Dark purple app bar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          child: Column(
            children: [
              TextField(
                controller: quizTitle,
                maxLength: 70,
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.title,
                    color: AppColors.primaryColor,
                  ),
                  labelText: 'Quiz Title',
                ),
                onChanged: (text) {
                  setState(() {
                    quizData.quizTitle = text;
                  });
                },
              ),
              TextField(
                controller: quizDescription,
                maxLines: null,
                maxLength: 280,
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.description,
                    color: AppColors.primaryColor,
                  ),
                  labelText: 'Quiz Description',
                ),
                onChanged: (text) {
                  setState(() {
                    quizData.quizDescription = text;
                  });
                },
              ),
              TextField(
                maxLength: 30,
                decoration: const InputDecoration(
                  icon: Icon(
                    CupertinoIcons.tag_fill,
                    color: AppColors.primaryColor,
                  ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Visibility',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Center(
                          child: DropdownButton<String>(
                            icon: const Icon(
                              CupertinoIcons.globe,
                              color: AppColors.primaryColor,
                            ),
                            value: quizData.visibility ?? 'Public',
                            onChanged: (value) {
                              setState(() {
                                quizData.visibility = value;
                              });
                            },
                            items: <String>['Public', 'Private']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Difficulty',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Center(
                          child: DropdownButton<String>(
                            icon: const Icon(
                              CupertinoIcons.hourglass,
                              color: AppColors.primaryColor,
                            ),
                            value: quizData.difficulty ?? 'Medium',
                            onChanged: (value) {
                              setState(() {
                                quizData.difficulty = value;
                              });
                            },
                            items: <String>['Easy', 'Medium', 'Hard']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Timer',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Center(
                          child: DropdownButton<int>(
                            icon: const Icon(
                              CupertinoIcons.timer,
                              color: AppColors.primaryColor,
                            ),
                            value: quizData.timer ?? 999,
                            onChanged: (value) {
                              setState(() {
                                quizData.timer = value;
                              });
                            },
                            items: <int>[20, 40, 60, 120, 999].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: value == 999
                                    ? const Text("Unlimited ")
                                    : Text('$value sec'),
                              );
                            }).toList(),
                          ),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showEditQuestionDialog(i); // Edit button
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green, // Green icon color
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    previewQuestions
                                        .remove(previewQuestions[i]);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red, // Red icon color
                                ),
                              ),
                            ],
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
