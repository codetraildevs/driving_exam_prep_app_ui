import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last visited route to improve user experience on cold starts.
class LastRouteSession {
  static const String _key = 'last_visited_route';
  static final LastRouteSession _instance = LastRouteSession._internal();
  factory LastRouteSession() => _instance;
  LastRouteSession._internal();

  /// Saves the current location if it's a "restorable" route.
  Future<void> saveRoute(String location) async {
    // Avoid saving non-restorable pages like login or intermediate screens if necessary.
    // However, usually we can save everything that is protected.
    if (location == '/login' || location == '/landing' || location == '/language-select') return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, location);
  }

  /// Retrieves the last saved route.
  Future<String?> getSavedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Clears the saved route (e.g. on logout).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
