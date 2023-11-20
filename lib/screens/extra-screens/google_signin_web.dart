import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GoogleSignIn extends StatefulWidget {
  const GoogleSignIn({Key? key}) : super(key: key);

  @override
  State<GoogleSignIn> createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String? name, imageUrl, userEmail, uid;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Center(
          child: InkWell(
            onTap: () {
              signInWithGoogle();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Sign In with Google'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    var data = Provider.of<UserProvider>(context, listen: false);
    // Initialize Firebase
    await Firebase.initializeApp();
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    // The `GoogleAuthProvider` can only be
    // used while running on the web
    GoogleAuthProvider authProvider = GoogleAuthProvider();

    try {
      final UserCredential userCredential =
          await auth.signInWithPopup(authProvider);
      user = userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    if (user != null) {
      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;

      data.setUserData(UserModel(
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        avatarUrl: user.photoURL,
      ));

      print("name: $name");
      print("userEmail: $userEmail");
      print("imageUrl: $imageUrl");

      // Check if the user data already exists in Firestore
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        // If the document exists, update its data
        // await userDoc.update({
        //   // 'displayName': user.displayName,
        //   // 'email': user.email,
        //   // 'uid': user.uid,
        //   // 'avatarUrl': user.photoURL,
        // });
      } else {
        var uuid = const Uuid();
        var randomUuid = uuid.v4();
        var username = randomUuid.substring(0, 8);

        await userDoc.set({
          'displayName': user.displayName,
          'email': user.email,
          'uid': user.uid,
          'avatarUrl': user.photoURL,
          'plan': 'free',
          'username': username,
          'searchFields': username.toLowerCase(),
          'noOfFollowers': 0,
          'noOfFollowings': 0,
          'noOfQuizzes': 0,
        });
      }
      context.go('/app');
    }
  }
}
