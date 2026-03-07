import 'package:shared_preferences/shared_preferences.dart';

class AppLaunchSession {
  static const _openedKey = 'has_opened_app';

  Future<bool> consumeFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOpened = prefs.getBool(_openedKey) ?? false;
    if (!hasOpened) {
      await prefs.setBool(_openedKey, true);
      return true;
    }
    return false;
  }
}
