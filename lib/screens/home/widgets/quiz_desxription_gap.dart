import 'package:flutter/cupertino.dart';

SizedBox quizDescriptionSizedBox(quizDescription) {
  if (quizDescription!.length > 250) {
    return const SizedBox(
      height: 50,
    );
  } else if (quizDescription!.length > 230) {
    return const SizedBox(
      height: 35,
    );
  } else if (quizDescription!.length > 200) {
    return const SizedBox(
      height: 25,
    );
  } else {
    // Return a default SizedBox or null if needed
    return const SizedBox(
      height: 0,
    );
  }
}
