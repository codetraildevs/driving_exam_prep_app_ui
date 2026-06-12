import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State holder for the app locale.
class LocaleState {
  final Locale? locale;
  const LocaleState({this.locale});

  Locale get effectiveLocale => locale ?? const Locale('en');
  bool get hasLocaleSelected => locale != null;
}

/// Riverpod notifier for app locale management.
class LocaleNotifier extends Notifier<LocaleState> {
  static const String _prefKey = 'selected_locale';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
  ];

  static const Map<String, String> localeNames = {
    'en': 'English',
    'fr': 'Français',
    'rw': 'Kinyarwanda',
  };

  /// Stashed initial locale — set by the override factory before Riverpod
  /// has registered the notifier, so we cannot call [state=] during that
  /// phase. Instead we store it here and return it from [build] once the
  /// Riverpod internals are fully wired.
  Locale? _initialLocale;

  @override
  LocaleState build() => LocaleState(locale: _initialLocale);

  /// Called during app startup to set the initial locale from SharedPreferences.
  ///
  /// Stores the locale in a field rather than calling [state=] because this
  /// is invoked by the provider override factory before the notifier has been
  /// fully registered with Riverpod's element tree. Setting [state] during
  /// that phase would throw a [LateInitializationError].
  void setInitialLocale(Locale? locale) {
    _initialLocale = locale;
  }

  /// Persist and apply a new locale. The UI updates instantly via Riverpod.
  Future<void> setLocale(Locale locale) async {
    state = LocaleState(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  /// Used as [localeResolutionCallback] on MaterialApp.
  Locale localeResolutionCallback(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (state.locale != null) return state.locale!;
    if (deviceLocale != null &&
        supported.any((l) => l.languageCode == deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }
    return const Locale('en');
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(
  LocaleNotifier.new,
);
