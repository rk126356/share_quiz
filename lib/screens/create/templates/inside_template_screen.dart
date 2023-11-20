import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/create_quiz_data_model.dart';
import 'package:share_quiz/Models/quiz_template_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/my_quizzes_screen.dart';
import 'package:share_quiz/utils/generate_quizid.dart';
import 'package:share_quiz/utils/remove_line_breakes.dart';

class InsideTemplateScreen extends StatefulWidget {
  final QuizTemplate template;
  final String? quizID;

  const InsideTemplateScreen({
    Key? key,
    required this.template,
    this.quizID,
  }) : super(key: key);

  @override
  State<InsideTemplateScreen> createState() => _InsideTemplateScreenState();
}

class _InsideTemplateScreenState extends State<InsideTemplateScreen> {
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

    choiceControllers[2].clear();
    choiceControllers[3].clear();
    choiceControllers[4].clear();
    choiceControllers[5].clear();

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
                      selectedCorrectAns != null &&
                      choiceControllers[0].text.isNotEmpty &&
                      choiceControllers[1].text.isNotEmpty) {
                    for (int i = 0; i < choiceCount; i++) {
                      if (choiceControllers[i].text.isEmpty) {
                        showDialog(
                          context:
                              context, // Make sure to have access to the context in your method.
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content:
                                  const Text("Please fill in the choices."),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                    }

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
                  } else {
                    showDialog(
                      context:
                          context, // Make sure to have access to the context in your method.
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "Please fill in the Question, add at least 2 choices and select the correct answer."),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
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

  Future<void> _showEditQuestionDialog(int index) async {
    Quizzes selectedQuestion = previewQuestions[index];
    String? selectedCorrectAns = selectedQuestion.correctAns;
    int choiceCount = selectedQuestion.choices!.length;

    questionController.text = selectedQuestion.questionTitle!;
    for (int i = 0; i < choiceCount; i++) {
      choiceControllers[i].text = selectedQuestion.choices?[i];
    }

    await editQuestionPopup(index, choiceCount, selectedCorrectAns);
  }

  Future<void> editQuestionPopup(
      int index, int choiceCount, String? selectedCorrectAns) {
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
                      selectedCorrectAns != null &&
                      choiceControllers[0].text.isNotEmpty &&
                      choiceControllers[1].text.isNotEmpty) {
                    for (int i = 0; i < choiceCount; i++) {
                      if (choiceControllers[i].text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content:
                                  const Text("Please fill in the choices."),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                    }

                    // Update the existing question with the edited data
                    Quizzes updatedQuestion = Quizzes(
                      questionTitle: questionController.text,
                      choices: choiceControllers
                          .map((controller) => controller.text)
                          .toList()
                          .sublist(0, choiceCount),
                      correctAns: selectedCorrectAns,
                    );
                    previewQuestions[index] = updatedQuestion;

                    questionController.clear();
                    for (var controller in choiceControllers) {
                      controller.clear();
                    }
                    selectedCorrectAns = null;
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "Please fill in the Question, add at least 2 choices, and select the correct answer."),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
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

  void saveQuiz(data, context) async {
    if (quizData.quizTitle != null &&
        quizData.quizDescription != null &&
        previewQuestions.length > 1 &&
        quizData.categories != null) {
      setState(() {
        _isLoading = true;
      });

      final quizTitle = quizData.quizTitle!.toLowerCase();

      // Split the quiz title into substrings
      List<String> quizTitleSubstrings = [];
      for (int i = 0; i < quizTitle!.length; i++) {
        for (int j = i + 1; j <= quizTitle!.length; j++) {
          quizTitleSubstrings.add(quizTitle!.substring(i, j).toLowerCase());
        }
      }

      quizData.quizTitleSubstrings = quizTitleSubstrings;
      quizData.quizzes = previewQuestions;
      quizData.quizID = widget.quizID ?? generateQuizID();
      quizData.likes = 0;
      quizData.disLikes = 0;
      quizData.taken = 0;
      quizData.views = 0;
      quizData.wins = 0;
      quizData.creatorName = data.userData.name;
      quizData.creatorImage = data.userData.avatarUrl;
      quizData.topScorerImage =
          'https://firebasestorage.googleapis.com/v0/b/share-quiz.appspot.com/o/myfiles%2F186-1869910_ic-question-mark-roblox-question-mark-avatar.png?alt=media&token=272f2179-f476-44a3-9a6a-10dfe85f64cd';
      quizData.topScorerName = 'No One Yet!';
      quizData.shares = 0;
      quizData.creatorUserID = data.userData.uid;
      quizData.createdAt = Timestamp.now();
      quizData.timer = quizData.timer ?? 999;
      quizData.visibility = quizData.visibility ?? 'Public';
      quizData.creatorUsername = data.userData.username;
      quizData.noOfQuestions = previewQuestions.length;
      quizData.difficulty = quizData.difficulty ?? 'Medium';
      quizData.quizDescription =
          removeExtraLineBreaks(quizData.quizDescription!);
      await _firestore
          .collection('allQuizzes')
          .doc(quizData.quizID)
          .set(quizData.toJson());

      List<dynamic>? categories = quizData.categories;

      for (final category in categories!) {
        await _firestore
            .collection('allTags')
            .doc(category)
            .set({'category': category});
      }

      if (quizData.visibility == 'Public') {
        await _firestore
            .collection('users')
            .doc(data.userData.uid)
            .update({'noOfQuizzes': FieldValue.increment(1)});
      }

      if (quizData.visibility == 'Private') {
        await _firestore
            .collection('users')
            .doc(data.userData.uid)
            .update({'noOfQuizzesPrivate': FieldValue.increment(1)});
      }

      previewQuestions.clear();
      questionController.clear();
      for (var controller in choiceControllers) {
        controller.clear();
      }
      setState(() {
        _isLoading = false;
      });

      if (quizData.visibility == 'Public') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MyQuizzesScreen(
                    initialIndex: 0,
                  )),
        );
      }

      if (quizData.visibility == 'Private') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MyQuizzesScreen(
                    initialIndex: 1,
                  )),
        );
      }

      if (quizData.visibility == 'Draft') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MyQuizzesScreen(
                    initialIndex: 2,
                  )),
        );
      }
    } else {
      showDialog(
        context:
            context, // Make sure to have access to the context in your method.
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Please fill in all required fields and add at least 2 questions.\n\nIf you are using template then you have to edit the title, description, and tags."),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  TextEditingController quizTitle = TextEditingController();
  TextEditingController quizDescription = TextEditingController();
  TextEditingController quizTags = TextEditingController();

  @override
  void initState() {
    super.initState();

    previewQuestions = widget.template.templateQuizzes;
    quizTitle.text = widget.template.templateQuizTitle;
    quizDescription.text = widget.template.templateQuizDescription;
    quizTags.text = widget.template.templateQuizTags;
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);

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
                saveQuiz(data, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    CupertinoColors.activeBlue, // Bold orange button
              ),
              child: Row(
                children: [
                  Icon(
                    quizData.visibility == 'Draft'
                        ? CupertinoIcons.folder
                        : CupertinoIcons.cloud_upload,
                    color: Colors.white, // White icon color
                  ),
                  const SizedBox(width: 5),
                  Text(
                    quizData.visibility == 'Draft'
                        ? 'Save Draft'
                        : "Publish Quiz",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Create Quiz"),
        backgroundColor: AppColors.primaryColor, // Dark purple app bar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
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
                      controller: quizTags,
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
                          final tags = text.toLowerCase().split(',');
                          for (int i = 0; i < tags.length; i++) {
                            if (!tags[i].trim().startsWith('#')) {
                              tags[i] = '#${tags[i].trim()}';
                            }
                          }
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
                                  items: <String>['Public', 'Private', 'Draft']
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
                                  items: <String>[
                                    'Easy',
                                    'Medium',
                                    'Hard',
                                  ].map((String value) {
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
                                  items: <int>[20, 40, 60, 120, 240, 999]
                                      .map((int value) {
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
                      Center(
                        child: Container(
                          // Styling for the timer box
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Total Questions: ${previewQuestions.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                      ),
                    if (previewQuestions.isNotEmpty)
                      Column(
                        children: previewQuestions.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final Quizzes question = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showEditQuestionDialog(index);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question.questionTitle!,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Choices: ${question.choices?.join(', ')}",
                                              style: const TextStyle(
                                                color: Colors.indigo,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _showEditQuestionDialog(index);
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.green,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                previewQuestions
                                                    .remove(question);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
