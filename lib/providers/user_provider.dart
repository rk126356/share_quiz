import 'package:flutter/material.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() {
    _initializeDataFromPrefs();
  }
  var _userData = UserModel(
      // uid: 'HpWp3pyzgNWzvR2deGOmKPlBFKp2',
      // email: 'rsk126356@gmail.com',
      );
  bool _isFirstLaunch = true;
  bool _isNewOpen = true;
  bool _isBioAdded = false;
  List<String> _quizViews = [];

  UserModel get userData => _userData;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isNewOpen => _isNewOpen;
  bool get isBioAdded => _isBioAdded;
  List get quizViews => _quizViews;

  void setNewQuizViews(String newQuizView) async {
    _quizViews.add(newQuizView);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('viewsList', _quizViews);
    if (_quizViews.length > 50) {
      await prefs.remove('viewsList');
    }
  }

  setIsNewOpen(bool value) {
    _isNewOpen = value;
  }

  setFirstLaunch(bool data) async {
    _isFirstLaunch = data;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', data);
  }

  setIsBioAdded(bool bio) async {
    _isBioAdded = bio;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBioAdded', bio);
  }

  setUserData(UserModel user) {
    _userData = UserModel(
      name: user.name ?? _userData.name,
      email: user.email ?? _userData.email,
      avatarUrl: user.avatarUrl ?? _userData.avatarUrl,
      uid: user.uid ?? _userData.uid,
      username: user.username ?? _userData.username,
      bio: user.bio ?? _userData.bio,
      gender: user.gender ?? _userData.gender,
      phoneNumber: user.phoneNumber ?? _userData.phoneNumber,
      dob: user.dob ?? _userData.dob,
      language: user.language ?? _userData.language,
    );
    notifyListeners();
  }

  Future<void> _initializeDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('firstLaunch');
    bool? isBioAdded = prefs.getBool('isBioAdded');
    List<String>? viewsList = prefs.getStringList('viewsList');

    if (viewsList != null) {
      _quizViews = viewsList;
    }

    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
    }

    if (isBioAdded != null) {
      _isBioAdded = isBioAdded;
    }

    notifyListeners();
  }
}
