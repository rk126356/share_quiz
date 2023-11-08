import 'package:share_quiz/Models/create_quiz_data_model.dart';

class QuizTemplate {
  final List<Quizzes> templateQuizzes;
  final String templateQuizTitle;
  final String templateQuizDescription;
  final String templateQuizTags;

  QuizTemplate({
    required this.templateQuizzes,
    required this.templateQuizTitle,
    required this.templateQuizDescription,
    required this.templateQuizTags,
  });
}
