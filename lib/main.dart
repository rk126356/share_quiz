import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/navigation.dart';
import 'package:share_quiz/providers/daily_login_provider.dart';
import 'package:share_quiz/providers/quiz_language_provider.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/extra-screens/onboarding_screen.dart';
import 'package:share_quiz/screens/login/login_screen.dart';
import 'package:share_quiz/screens/profile/create_profile_screen.dart';
import 'package:share_quiz/screens/quiz/inside_quiz_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //     // these are variable
  //     // for each firebase project
  //     apiKey: "AIzaSyB_9gA4rMApBvS2qAuFBQN2Rgy6Jm3gRas",
  //     authDomain: "share-quiz.firebaseapp.com",
  //     projectId: "share-quiz",
  //     storageBucket: "share-quiz.appspot.com",
  //     messagingSenderId: "980593065701",
  //     appId: "1:980593065701:web:05a629332f912b5b4cde0c",
  //     measurementId: "G-8KVGY2GHXS",
  //   ));
  // } else {
  //   await Firebase.initializeApp();
  // }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => QuestionsLanguageProvider()),
    ChangeNotifierProvider(create: (context) => DailyLoginProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> checkUser(user, context) async {
    var data = Provider.of<UserProvider>(context, listen: false);

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data();
      data.setUserData(UserModel(
        name: userData?['displayName'],
        uid: userData?['uid'],
        bio: userData?['bio'],
        phoneNumber: userData?['phoneNumber'],
        dob: userData?['dob'],
        gender: userData?['gender'],
        language: userData?['language'],
        avatarUrl: userData?['avatarUrl'],
        username: userData?['username'],
        email: userData?['email'],
      ));
      if (userData!.containsKey('bio') &&
          userData['bio'] != null &&
          userData['bio'] != '') {
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
        );
      }
    } else {
      if (kDebugMode) {
        print('No user found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // The route configuration.
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return user == null ? OnBoardingScreen() : NavigationScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'app',
              builder: (BuildContext context, GoRouterState state) {
                return NavigationScreen();
              },
            ),
            GoRoute(
              path: 'code/:quizCode',
              builder: (BuildContext context, GoRouterState state) {
                return InsideQuizScreen(
                  quizID: state.pathParameters['quizCode']!,
                );
              },
            ),
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) {
                // return kIsWeb ? const GoogleSignIn() : const LoginScreen();
                return const LoginScreen();
              },
            ),
          ],
        ),
      ],
    );

    if (kDebugMode) {
      return MaterialApp(
        title: 'ShareQuiz',
        theme: ThemeData(
          textTheme: const TextTheme(
            labelLarge: TextStyle(fontSize: 16.0, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blue)
              .copyWith(background: Colors.white),
        ),
        initialRoute: '/app',
        routes: <String, WidgetBuilder>{
          '/app': (context) => NavigationScreen(),
          '/edit-profile': (context) => const CreateProfileScreen(),
        },
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp.router(
      title: 'ShareQuiz',
      theme: ThemeData(
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontSize: 16.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.blue)
            .copyWith(background: Colors.white),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
