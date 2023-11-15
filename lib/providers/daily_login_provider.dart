import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyLoginProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  int _adsWatched = 0;
  int get adsWatched => _adsWatched;

  bool _firstLaunch = true;
  get firstLaunch => _firstLaunch;

  DailyLoginProvider() {
    _initSharedPreferences();
  }

  void increaseAdsWatched() {
    _adsWatched++;
    _saveAdsWatched();
    notifyListeners();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _checkAdsWatched();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final firstLaunch = _prefs?.getBool('isFirstLaunch');
    if (firstLaunch != null) {
      _firstLaunch = firstLaunch;
    }
  }

  Future<void> _saveIsFirstLaunch() async {
    await _prefs?.setBool('isFirstLaunch', _firstLaunch);
  }

  void setFirstLaunchFalse() {
    _firstLaunch = false;
    _saveIsFirstLaunch();
    notifyListeners();
  }

  Future<void> _checkAdsWatched() async {
    final adsWatchedPrefix = _prefs?.getInt('adsWatched');
    if (adsWatchedPrefix != null) {
      _adsWatched = adsWatchedPrefix;
    }
  }

  Future<void> _saveAdsWatched() async {
    await _prefs?.setInt('adsWatched', _adsWatched);
  }
}
