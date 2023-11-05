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

    return data;
  }
}
