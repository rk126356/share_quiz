import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/api/translation_api.dart';
import 'package:share_quiz/providers/quiz_language_provider.dart';
import 'package:translator/translator.dart';

class QuestionNameBox extends StatefulWidget {
  const QuestionNameBox({
    super.key,
    required this.name,
    required this.totalQuestions,
    required this.correct,
    required this.currentIndex,
  });

  final String name;
  final int totalQuestions;
  final int correct;
  final int currentIndex;

  @override
  State<QuestionNameBox> createState() => _QuestionNameBoxState();
}

class _QuestionNameBoxState extends State<QuestionNameBox> {
  String? translatrdQuestion;

  bool _hasInternet = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    translateQ();
  }

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    });
  }

  @override
  void didUpdateWidget(QuestionNameBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      // If the question name has changed, trigger translation
      translateQ();
      checkInternetConnection();
    }
  }

  void translateQ() async {
    final qLanguage =
        Provider.of<QuestionsLanguageProvider>(context, listen: false);
    final translator = GoogleTranslator();

    if (qLanguage.languageName != 'None') {
      translator
          .translate(widget.name, from: 'auto', to: qLanguage.language)
          .then((s) {
        setState(() {
          translatrdQuestion = s.toString();
        });
      });
    } else {
      translatrdQuestion = null;
    }
    if (kDebugMode) {
      print('Translated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final qLanguage = Provider.of<QuestionsLanguageProvider>(context);

    if (qLanguage.reload) {
      translateQ();
    }
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 320,
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor:
                          widget.currentIndex / widget.totalQuestions == 1.0
                              ? 0.99
                              : widget.currentIndex / widget.totalQuestions,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue,
                              CupertinoColors.activeBlue,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question: ${widget.currentIndex}/${widget.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Score: ${widget.correct}/${widget.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: CupertinoColors.activeBlue,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.blue[300]!,
                  width: 5.0,
                ),
              ),
              child: Text(
                translatrdQuestion != null ? translatrdQuestion! : widget.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
