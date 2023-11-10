import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/Models/user_model.dart';
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
  bool _loading = false;

  fetchFollowers() async {
    setState(() {
      _loading = true;
    });
    final firestore = FirebaseFirestore.instance;
    final followingRef =
        await firestore.collection('users/${widget.userID}/myFollowings').get();

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
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFollowers();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('@${widget.username}: Followings')),
      body: users.isEmpty
          ? Center(
              child: Text('@${widget.username} have no followings'),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
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
