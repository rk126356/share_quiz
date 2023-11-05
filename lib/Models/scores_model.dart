// Model class to represent scores
import 'package:cloud_firestore/cloud_firestore.dart';

class Score {
  final String playerUid;
  final int playerScore;
  final Timestamp timestamp;
  final int timeTaken;
  final String playerName;
  final String playerImage;
  final int noOfQuestions;
  int attemptNo;

  Score({
    required this.playerUid,
    required this.playerScore,
    required this.timestamp,
    required this.timeTaken,
    required this.playerName,
    required this.playerImage,
    required this.noOfQuestions,
    required this.attemptNo,
  });
}
