import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final User _user;

  bool isLoading = false;

  Future<void> signInWithGoogle(data, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;
      _user = user!;

      data.setUserData(UserModel(
        uid: _user.uid,
        email: _user.email,
        name: _user.displayName,
        avatarUrl: _user.photoURL,
      ));

      // Check if the user data already exists in Firestore
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        // If the document exists, update its data
        await userDoc.update({
          // 'displayName': user.displayName,
          // 'email': user.email,
          // 'uid': user.uid,
          // 'avatarUrl': user.photoURL,
        });
      } else {
        var uuid = const Uuid();
        var randomUuid = uuid.v4();
        var username = randomUuid.substring(0, 8);

        await userDoc.set({
          'displayName': user.displayName,
          'email': user.email,
          'uid': user.uid,
          'avatarUrl': user.photoURL,
          'bio': 'No Bio',
          'plan': 'free',
          'username': username,
          'searchFields': username.toLowerCase(),
          'noOfFollowers': 0,
          'noOfFollowings': 0,
          'noOfQuizzes': 0,
        });
      }

      context.go('/app');

      if (kDebugMode) {
        print('User data stored in Firestore');
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in with Google: $error');
      }
      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        isLoading = false;
      });
      if (user != null) {
        context.go('/app');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    CupertinoColors.activeBlue,
                    CupertinoColors.activeBlue
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/srq_logo.gif',
                      height: 350,
                      width: 350,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        signInWithGoogle(data, context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google-logo.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
