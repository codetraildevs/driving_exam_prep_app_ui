import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Fallback Material localizations delegate for locales not natively supported
/// by [GlobalMaterialLocalizations] (e.g. Kinyarwanda 'rw').
/// Returns the default English Material localizations for those locales.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

/// Fallback Cupertino localizations delegate for locales not natively supported
/// by [GlobalCupertinoLocalizations] (e.g. Kinyarwanda 'rw').
/// Returns the default English Cupertino localizations for those locales.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}
