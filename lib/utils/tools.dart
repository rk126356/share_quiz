// Function to convert Timestamp to String
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String timestampToString(Timestamp timestamp) {
  // Convert Timestamp to DateTime
  DateTime dateTime = timestamp.toDate();

  // Format the DateTime object as a string
  String formattedString = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  return formattedString;
}

// Function to convert String to Timestamp
Timestamp stringToTimestamp(String dateString) {
  // Parse the string and convert it to a DateTime object
  DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);

  // Convert DateTime to Timestamp
  Timestamp timestamp = Timestamp.fromDate(dateTime);
  return timestamp;
}
