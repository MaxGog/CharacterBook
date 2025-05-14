import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../generated/l10n.dart';

class LocaleProvider with ChangeNotifier {
  final Box _settingsBox;
  Locale? _locale;

  LocaleProvider(this._settingsBox) {
    final languageCode = _settingsBox.get('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
  }

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!S.delegate.supportedLocales.contains(locale)) {
      debugPrint('Locale $locale is not supported');
      return;
    }

    _locale = locale;
    _settingsBox.put('languageCode', locale.languageCode);
    notifyListeners();
  }
}