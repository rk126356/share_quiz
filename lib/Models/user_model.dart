class UserModel {
  String? name;
  String? email;
  String? avatarUrl;
  String? uid;
  String? language;

  UserModel({this.name, this.email, this.uid, this.avatarUrl, this.language});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
    uid = json['uid'];
    language = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['email'] = email;
    data['avatarUrl'] = avatarUrl;
    data['uid'] = uid;
    data['currency'] = language;

    return data;
  }
}
