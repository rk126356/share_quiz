import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> getRandomOrderDocuments(String userId) async {
  // Get the collection
  CollectionReference collection =
      FirebaseFirestore.instance.collection('users/$userId/myQuizzes');

  // Get all the documents in the collection
  QuerySnapshot querySnapshot = await collection.get();

  // Convert the documents to a list
  List<DocumentSnapshot> documents = querySnapshot.docs;

  // Shuffle the list randomly
  var random = Random();
  documents.shuffle(random);

  return documents;
}
