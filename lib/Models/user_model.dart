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

    return data;
  }
}
