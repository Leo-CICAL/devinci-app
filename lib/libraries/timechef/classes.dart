import 'package:flutter/foundation.dart';

class PageChanger with ChangeNotifier {
  int position = 0;
  int page() {
    return position;
  }

  void setPage(int index) {
    position = index;
    notifyListeners();
  }
}
