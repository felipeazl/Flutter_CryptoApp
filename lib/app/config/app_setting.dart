import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  late Box box;
  // late SharedPreferences _prefs;
  Map<String, String> locale = {
    "locale": "pt_BR",
    "symbol": "R\$",
  };

  AppSettings() {
    _startSettings();
  }

  _startSettings() async {
    await _startPreferences();
    await _readLocale();
  }

  Future<void> _startPreferences() async {
    // _prefs = await SharedPreferences.getInstance();
    box = await Hive.openBox("preferences");
  }

  _readLocale() {
    final local = box.get("local") ?? "pt_BR";
    final symbol = box.get("symbol") ?? "R\$";

    locale = {
      "locale": local,
      "symbol": symbol,
    };

    notifyListeners();
  }

  setLocale(String local, String symbol) async {
    await box.put("local", local);
    await box.put("symbol", symbol);
    _readLocale();
  }
}
