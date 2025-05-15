// lib/providers/text_scale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextScaleProvider with ChangeNotifier {
  double _scale = 1.0;

  double get scale => _scale;

  TextScaleProvider() {
    loadScale();
  }

  void setScale(double scale) {
    _scale = scale;
    saveScale();
    notifyListeners();
  }

  Future<void> loadScale() async {
    final prefs = await SharedPreferences.getInstance();
    _scale = prefs.getDouble('textScale') ?? 1.0;
    notifyListeners();
  }

  Future<void> saveScale() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('textScale', _scale);
  }
}
