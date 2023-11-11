import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class FollowingsScreen extends StatefulWidget {
  final String userID;
  final String username;
  const FollowingsScreen(
      {super.key, required this.userID, required this.username});

  @override
  State<FollowingsScreen> createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  List<UserModel> users = [];
  bool _isLoading = false;
  bool _isButtonLoading = false;
  DocumentSnapshot? lastDocument;
  int listLength = 1;

  void fetchFollowers(bool next, context) async {
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
          .collection('users/${widget.userID}/myFollowings')
          .orderBy('createdAt', descending: true)
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      followingRef = await firestore
          .collection('users/${widget.userID}/myFollowings')
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
            content: const Text('No more followings available.'),
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
          title: Text('@${widget.username}: Followings')),
      body: _isLoading
          ? const LoadingWidget()
          : users.isEmpty
              ? Center(
                  child: Text('@${widget.username} have no Followings'),
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
                      onRemove: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InsideProfileScreen(
                                    userId: users[index].uid!,
                                  )),
                        );
                      },
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
          onTap: onRemove,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl!),
          ),
          title: Text(user.name!),
          subtitle: Text('@${user.username}'),
          trailing: Text('Quizzes: ${user.noOfQuizzes.toString()}'),
        ),
      ),
    );
  }
}
