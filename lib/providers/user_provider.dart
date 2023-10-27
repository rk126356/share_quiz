import 'package:flutter/material.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  var _userData = UserModel(
      // uid: 'HpWp3pyzgNWzvR2deGOmKPlBFKp2',
      // avatarUrl:
      //     'https://lh3.googleusercontent.com/a/ACg8ocIMy4Ub0gQghVTQOBgRvZzg8fgOjYRilIIv3dIzSZpFKw=s96-c',
      // name: 'SuperSuper Gaming',
      // email: 'rsk126356@gmail.com',
      );
  bool _isFirstLaunch = true;
  bool _isNewOpen = true;

  UserModel get userData => _userData;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isNewOpen => _isNewOpen;

  UserProvider() {
    _initializeDataFromPrefs();
  }

  setIsNewOpen(bool value) {
    _isNewOpen = value;
  }

  setFirstLaunch(bool data) async {
    _isFirstLaunch = data;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', data);
  }

  setUserData(UserModel user) {
    _userData = user;
  }

  Future<void> _initializeDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('firstLaunch');

    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
    }

    notifyListeners();
  }
}
