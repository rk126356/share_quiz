import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
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
  bool _loading = false;

  fetchFollowers() async {
    setState(() {
      _loading = true;
    });
    var data = Provider.of<UserProvider>(context, listen: false);
    final firestore = FirebaseFirestore.instance;
    final followingRef = await firestore
        .collection('users/${data.userData.uid}/myFollowers')
        .get();

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
    data.setUserData(UserModel(
      noOfFollowers: data.userData.noOfFollowers! - 1,
    ));
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
      appBar: AppBar(title: const Text('My Followers')),
      body: users.isEmpty
          ? const Center(
              child: Text('You have no followers'),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
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
          subtitle: Text('Quizzes: ${user.noOfQuizzes.toString()}'),
          trailing: ElevatedButton(
            onPressed: onRemove,
            child: Text('Remove'),
          ),
        ),
      ),
    );
  }
}
