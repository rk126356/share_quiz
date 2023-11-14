import 'package:flutter/material.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/providers/quiz_language_provider.dart';

void openLanguagePickerDialog(context) {
  final languageProvider =
      Provider.of<QuestionsLanguageProvider>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.orange),
        child: LanguagePickerDialog(
            titlePadding: const EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration: const InputDecoration(hintText: 'Search...'),
            languages: [
              Language('original', 'None'),
              Languages.english,
              Languages.arabic,
              Languages.bengali,
              Languages.dutch,
              Languages.french,
              Languages.german,
              Languages.greek,
              Languages.gujarati,
              Languages.hindi,
              Languages.indonesian,
              Languages.irish,
              Languages.italian,
              Languages.japanese,
              Languages.korean,
              Languages.latin,
              Languages.marathi,
              Languages.nepali,
              Languages.persian,
              Languages.polish,
              Languages.portuguese,
              Languages.russian,
              Languages.spanish,
              Languages.tamil,
              Languages.telugu,
              Languages.thai,
              Languages.turkish,
              Languages.ukrainian,
              Languages.urdu,
              Languages.vietnamese,
            ],
            isSearchable: true,
            title: const Text("Select your quiz language"),
            onValuePicked: (Language language) {
              languageProvider.setReload(true);
              languageProvider.changeLanguage(language.isoCode);
              languageProvider.changeLanguageName(language.name);
              Future.delayed(const Duration(milliseconds: 100), () {
                languageProvider.setReload(false);
              });
            },
            itemBuilder: buildDialogItem)),
  );
}

Widget buildDialogItem(Language language) => Row(
      children: <Widget>[
        Text(language.name),
        const SizedBox(width: 8.0),
        Flexible(child: Text("(${language.isoCode})"))
      ],
    );
