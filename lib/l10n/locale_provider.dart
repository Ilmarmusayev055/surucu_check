import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('az'),
    const Locale('en'),
    const Locale('ru'),
  ];
}
