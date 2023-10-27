import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizDataModel {
  String? quizTitle;
  String? creatorName;
  String? creatorUserID;
  String? creatorImage;
  String? quizDescription;
  List<Quizzes>? quizzes;
  int? noOfQuestions;
  String? quizID;
  List? categories;
  int? taken;
  int? views;
  int? likes;
  int? disLikes;
  int? wins;
  int? shares;
  String? topScorerName;
  String? topScorerImage;
  String? createdAt;

  CreateQuizDataModel({
    this.quizTitle,
    this.creatorName,
    this.creatorUserID,
    this.creatorImage,
    this.quizDescription,
    this.quizzes,
    this.noOfQuestions,
    this.quizID,
    this.categories,
    this.taken,
    this.views,
    this.likes,
    this.disLikes,
    this.wins,
    this.shares,
    this.topScorerName,
    this.topScorerImage,
    this.createdAt,
  });

  CreateQuizDataModel.fromJson(Map<String, dynamic> json) {
    quizTitle = json['quizTitle'];
    creatorName = json['creatorName'];
    createdAt = json['createdAt'];
    creatorUserID = json['creatorUserID'];
    creatorImage = json['creatorImage'];
    quizDescription = json['quizDescription'];
    if (json['quizzes'] != null) {
      quizzes = <Quizzes>[];
      json['quizzes'].forEach((v) {
        quizzes!.add(Quizzes.fromJson(v));
      });
    }
    noOfQuestions = json['noOfQuestions'];
    quizID = json['quizID'];
    categories = json['categories'];
    taken = json['taken'];
    views = json['views'];
    shares = json['shares'];
    likes = json['likes'];
    disLikes = json['disLikes'];
    wins = json['wins'];
    topScorerName = json['topScorerName'];
    topScorerImage = json['topScorerImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quizTitle'] = quizTitle;
    data['creatorName'] = creatorName;
    data['creatorUserID'] = creatorUserID;
    data['createdAt'] = createdAt;
    data['creatorImage'] = creatorImage;
    data['quizDescription'] = quizDescription;
    if (quizzes != null) {
      data['quizzes'] = quizzes!.map((v) => v.toJson()).toList();
    }
    data['noOfQuestions'] = noOfQuestions;
    data['quizID'] = quizID;
    data['categories'] = categories;
    data['taken'] = taken;
    data['views'] = views;
    data['likes'] = likes;
    data['disLikes'] = disLikes;
    data['wins'] = wins;
    data['shares'] = shares;
    data['topScorerName'] = topScorerName;
    data['topScorerImage'] = topScorerImage;

    return data;
  }
}

class Quizzes {
  String? questionTitle;
  List<dynamic>? choices;
  String? correctAns;

  Quizzes({this.questionTitle, this.choices, this.correctAns});

  Quizzes.fromJson(Map<String, dynamic> json) {
    questionTitle = json['questionTitle'];
    choices = json['choices'].cast<dynamic>();
    correctAns = json['correctAns'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['questionTitle'] = questionTitle;
    data['choices'] = choices;
    data['correctAns'] = correctAns;
    return data;
  }
}
