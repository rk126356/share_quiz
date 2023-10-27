class QuizDataClass {
  String? quizID;
  String? title;
  List? categories;
  int? taken;
  int? views;
  int? likes;
  int? wins;
  String? topScorerName;
  String? topScorerImage;

  QuizDataClass(
      {this.quizID,
      this.title,
      this.categories,
      this.taken,
      this.views,
      this.likes,
      this.wins,
      this.topScorerName,
      this.topScorerImage});

  QuizDataClass.fromJson(Map<String, dynamic> json) {
    quizID = json['quizID'];
    title = json['title'];
    categories = json['categories'];
    taken = json['taken'];
    views = json['views'];
    likes = json['likes'];
    wins = json['wins'];
    topScorerName = json['topScorerName'];
    topScorerImage = json['topScorerImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quizID'] = quizID;
    data['title'] = title;
    data['categories'] = categories;
    data['taken'] = taken;
    data['views'] = views;
    data['likes'] = likes;
    data['wins'] = wins;
    data['topScorerName'] = topScorerName;
    data['topScorerImage'] = topScorerImage;
    return data;
  }
}
