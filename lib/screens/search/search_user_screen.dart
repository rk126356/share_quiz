import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/screens/profile/inside_profile_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({Key? key}) : super(key: key);

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  List<DocumentSnapshot> _searchResults = [];

  void _searchUsers(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    _usersCollection
        .where('searchFields',
            isGreaterThanOrEqualTo: searchText.toLowerCase(),
            isLessThan: '${searchText}z')
        .limit(10)
        .get()
        .then((querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search for Users',
                  hintText: 'Enter a username, e.g., raihansk00',
                  hintStyle: const TextStyle(
                      color: Colors.grey), // Customize hint text color
                  border: OutlineInputBorder(
                    // Customize border
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2.0),
                  ),
                ),
                onChanged: (text) => _searchUsers(text),
              )),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var user =
                          _searchResults[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user['avatarUrl']),
                        ),
                        title: Text(user['displayName']),
                        subtitle: Text('@${user['username']}'),
                        trailing: Text('Quizzes: ${user['noOfQuizzes']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsideProfileScreen(
                                userId: user['uid'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text('No users found.'),
                  ),
          ),
        ],
      ),
    );
  }
}
