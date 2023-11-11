import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({super.key});

  @override
  State<MyFollowersScreen> createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> {
  List<UserModel> users = [];
  bool _isLoading = false;
  bool _isButtonLoading = false;
  DocumentSnapshot? lastDocument;
  int listLength = 1;

  void fetchFollowers(bool next, context) async {
    var data = Provider.of<UserProvider>(context, listen: false);
    if (users.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> followingRef;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      followingRef = await firestore
          .collection('users/${data.userData.uid}/myFollowers')
          .orderBy('createdAt', descending: true)
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      followingRef = await firestore
          .collection('users/${data.userData.uid}/myFollowers')
          .orderBy('createdAt', descending: true)
          .limit(listLength)
          .get();
    }

    lastDocument = followingRef.docs.isNotEmpty ? followingRef.docs.last : null;

    if (followingRef.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No more followers available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    for (final docs in followingRef.docs) {
      final userData = docs.data();

      final userRef =
          await firestore.collection('users').doc(userData['userID']).get();
      final user = userRef.data();

      if (user != null) {
        final newUser = UserModel(
          name: user['displayName'],
          uid: user['uid'],
          avatarUrl: user['avatarUrl'],
          noOfQuizzes: user['noOfQuizzes'],
          username: user['username'],
        );

        users.add(newUser);
      } else {
        if (kDebugMode) {
          print('Null user');
        }
      }
    }
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  Future<void> removeFollower(String userId) async {
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;

    // Remove the user from the local list
    users.removeWhere((user) => user.uid == userId);
    setState(() {});

    // Remove the user from Firebase
    await firestore
        .collection('users/${data.userData.uid}/myFollowers')
        .where('userID', isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    // Remove from the user from Firebase
    await firestore
        .collection('users/$userId/myFollowings')
        .where('userID', isEqualTo: data.userData.uid)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    await firestore
        .collection('users')
        .doc(data.userData.uid)
        .update({'noOfFollowers': FieldValue.increment(-1)});
    await firestore
        .collection('users')
        .doc(userId)
        .update({'noOfFollowings': FieldValue.increment(-1)});
  }

  @override
  void initState() {
    super.initState();
    fetchFollowers(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('My Followers')),
      body: _isLoading
          ? const LoadingWidget()
          : users.isEmpty
              ? const Center(
                  child: Text('You have no followers'),
                )
              : ListView.builder(
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == users.length) {
                      return Center(
                        child: _isButtonLoading
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchFollowers(true, context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors
                                          .primaryColor, // Change the button color
                                    ),
                                    child: const Text('Load more...',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  )
                                ],
                              ),
                      );
                    }
                    return UserCard(
                      user: users[index],
                      onRemove: () => removeFollower(users[index].uid!),
                    );
                  },
                ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRemove;

  const UserCard({super.key, required this.user, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InsideProfileScreen(
                        userId: user.uid!,
                      )),
            );
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl!),
          ),
          title: Text(user.name!),
          subtitle: Text('@${user.username}'),
          trailing: ElevatedButton(
            onPressed: onRemove,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Change the button color
            ),
            child: const Text('Remove'),
          ),
        ),
      ),
    );
  }
}
