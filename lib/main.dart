import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/navigation.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/create/create_screen.dart';
import 'package:share_quiz/screens/explore/explore_screen.dart';
import 'package:share_quiz/screens/home/home_screen.dart';
import 'package:share_quiz/screens/login/login_screen.dart';
import 'package:share_quiz/screens/profile/create_profile_screen.dart';
import 'package:share_quiz/screens/profile/profile_screen.dart';
import 'package:share_quiz/screens/quiz/quiz_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> checkUser(user, context) async {
    var data = Provider.of<UserProvider>(context, listen: false);

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(data.userData.uid ?? user.uid);
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
        Navigator.pushReplacement(
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
    // checkUser(null, context);
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const LoginScreen();
            } else {
              var user = FirebaseAuth.instance.currentUser!;

              checkUser(user, context);

              Provider.of<UserProvider>(context, listen: false)
                  .setUserData(UserModel(
                uid: user.uid,
                email: user.email,
              ));
              return NavigationScreen();
            }
          }

          return const LoginScreen();
        },
      ),
      // initialRoute: '/app',
      routes: <String, WidgetBuilder>{
        '/app': (context) => NavigationScreen(),
        '/home': (context) => const HomeScreen(),
        '/quizzes': (context) => const QuizScreen(),
        '/create-quiz': (context) => const CreateScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
