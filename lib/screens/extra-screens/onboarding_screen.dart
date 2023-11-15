import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/providers/daily_login_provider.dart';

class OnBoardingScreen extends StatelessWidget {
  final List<Introduction> list = [
    Introduction(
      title: 'Welcome to ShareQuiz!',
      subTitle:
          'Ready to have fun and learn new things? ShareQuiz is here for you!',
      imageUrl: 'assets/images/on-1.png',
    ),
    Introduction(
      title: 'Create Your Own Quiz',
      subTitle: 'Think of cool questions? Make your quiz and let others enjoy!',
      imageUrl: 'assets/images/on-2.png',
    ),
    Introduction(
      title: 'Challenge Your Friends',
      subTitle:
          'Invite friends to take your quiz and compete for the title of Quiz Master!',
      imageUrl: 'assets/images/on-3.png',
    ),
    Introduction(
      title: 'Discover & Play',
      subTitle:
          'Explore quizzes made by others. Learn and play at the same time!',
      imageUrl: 'assets/images/on-4.png',
    ),
  ];

  OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyLogin = Provider.of<DailyLoginProvider>(context, listen: false);
    return IntroScreenOnboarding(
      backgroudColor: Colors.white,
      introductionList: list,
      onTapSkipButton: () {
        // dailyLogin.setFirstLaunchFalse();
        context.go('/login');
      },
    );
  }
}
