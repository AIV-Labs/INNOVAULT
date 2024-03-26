

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppStateProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  String? selectedPage = 'Dashboard';
  int get selectedIndex => _selectedIndex;
  ThemeData theme = ThemeData.light();

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Selected Page
  void setSelectedPage(String? page) {
    selectedPage = page;
    notifyListeners();
  }

  void setTheme(ThemeData themeData) {
    theme = themeData;
    notifyListeners();
  }
}