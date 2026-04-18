import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale: loads persisted choice, saves new selections,
/// and notifies listeners so MaterialApp rebuilds immediately.
class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_locale';

  /// The three languages supported by the app.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
  ];

  /// Human-readable names shown in their own language.
  static const Map<String, String> localeNames = {
    'en': 'English',
    'fr': 'Français',
    'rw': 'Kinyarwanda',
  };

  Locale? _locale;

  /// Whether the user has already picked a language (persisted or just set).
  bool get hasLocaleSelected => _locale != null;

  /// Returns the persisted locale, falling back to English.
  Locale get effectiveLocale => _locale ?? const Locale('rw');

  /// Reads the saved locale from SharedPreferences.
  /// Call this once at app startup before `runApp`.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && supportedLocales.any((l) => l.languageCode == code)) {
      _locale = Locale(code);
    }
    // Do NOT call notifyListeners here — the widget tree doesn't exist yet.
  }

  /// Persist and apply a new locale. The UI updates instantly.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  /// Used as `localeResolutionCallback` on MaterialApp.
  /// If the user already picked a language, honour it.
  /// Otherwise try to match the device locale against supported locales.
  /// Falls back to English.
  Locale localeResolutionCallback(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (_locale != null) return _locale!;
    if (deviceLocale != null &&
        supported.any((l) => l.languageCode == deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('rw');
  }
}
