import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/providers/quiz_language_provider.dart';
import 'package:translator/translator.dart';

class ChoiceButton extends StatefulWidget {
  final String text;
  final int index;
  final bool isWrong;
  final bool isCorrect;
  final int selectedChoice;

  const ChoiceButton({
    Key? key,
    required this.text,
    required this.index,
    required this.isWrong,
    required this.isCorrect,
    required this.selectedChoice,
  }) : super(key: key);

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  String? choice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    translateQ();
  }

  @override
  void didUpdateWidget(ChoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // If the question name has changed, trigger translation
      translateQ();
    }
  }

  void translateQ() {
    final qLanguage =
        Provider.of<QuestionsLanguageProvider>(context, listen: false);
    final translator = GoogleTranslator();
    if (qLanguage.languageName != 'None') {
      translator
          .translate(widget.text, from: 'auto', to: qLanguage.language)
          .then((s) {
        setState(() {
          choice = s.toString();
        });
      });
    } else {
      choice = null;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: widget.selectedChoice == widget.index
                ? widget.isCorrect
                    ? Colors.green
                    : widget.isWrong
                        ? Colors.red
                        : Colors.blue.withOpacity(0.5)
                : CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.index.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  choice != null ? choice! : widget.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
