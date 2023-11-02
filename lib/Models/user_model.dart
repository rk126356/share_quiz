class UserModel {
  String? name;
  String? email;
  String? avatarUrl;
  String? uid;
  String? language;
  String? username;
  String? bio;
  String? phoneNumber;
  String? dob;
  String? gender;
  String? plan;
  String? isVerified;
  String? status;
  String? quizLanguage;
  int? noOfQuizzes;
  int? noOfFollowers;
  int? noOfFollowings;
  List<Follower>? listOfFollowers;
  List<Following>? listOfFollowing;

  UserModel({
    this.name,
    this.email,
    this.uid,
    this.avatarUrl,
    this.language,
    this.username,
    this.bio,
    this.phoneNumber,
    this.dob,
    this.gender,
    this.plan,
    this.isVerified,
    this.status,
    this.quizLanguage,
    this.noOfQuizzes,
    this.noOfFollowers,
    this.noOfFollowings,
    this.listOfFollowers,
    this.listOfFollowing,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
    uid = json['uid'];
    language = json['language'];
    username = json['username'];
    bio = json['bio'];
    phoneNumber = json['phoneNumber'];
    dob = json['dob'];
    gender = json['gender'];
    plan = json['plan'];
    isVerified = json['isVerified'];
    status = json['status'];
    quizLanguage = json['quizLanguage'];
    noOfQuizzes = json['noOfQuizzes'];
    noOfFollowers = json['noOfFollowers'];
    noOfFollowings = json['noOfFollowings'];

    if (json['listOfFollowers'] != null) {
      listOfFollowers = List<Follower>.from(json['listOfFollowers']
          .map((follower) => Follower.fromJson(follower)));
    }

    if (json['listOfFollowing'] != null) {
      listOfFollowing = List<Following>.from(json['listOfFollowing']
          .map((following) => Following.fromJson(following)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['email'] = email;
    data['avatarUrl'] = avatarUrl;
    data['uid'] = uid;
    data['language'] = language;
    data['username'] = username;
    data['bio'] = bio;
    data['phoneNumber'] = phoneNumber;
    data['dob'] = dob;
    data['gender'] = gender;
    data['plan'] = plan;
    data['isVerified'] = isVerified;
    data['status'] = status;
    data['quizLanguage'] = quizLanguage;
    data['noOfQuizzes'] = noOfQuizzes;
    data['noOfFollowers'] = noOfFollowers;
    data['noOfFollowings'] = noOfFollowings;

    if (listOfFollowers != null) {
      data['listOfFollowers'] =
          listOfFollowers?.map((follower) => follower.toJson()).toList();
    }

    if (listOfFollowing != null) {
      data['listOfFollowing'] =
          listOfFollowing?.map((following) => following.toJson()).toList();
    }

    return data;
  }
}

class Follower {
  String? userId;
  String? date;

  Follower({
    this.userId,
    this.date,
  });

  Follower.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['date'] = date;
    return data;
  }
}

class Following {
  String? userId;
  String? date;

  Following({
    this.userId,
    this.date,
  });

  Following.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['date'] = date;
    return data;
  }
}
