import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:devinci/extra/globals.dart' as globals;

import 'package:share_extend/share_extend.dart';
import 'package:easy_localization/easy_localization.dart';

class Cours {
  Cours(
      this.type,
      this.title,
      this.prof,
      this.location,
      this.site,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.flag,
      this.uid,
      this.groupe);

  String type;
  String title;
  String prof;
  String location;
  String site;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String flag;
  String uid;
  String groupe;
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

class DevinciTheme with ChangeNotifier {
  static bool _isDark = true;
  ThemeMode currentTheme() {
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  bool isDark() {
    return _isDark;
  }

  void setDark(bool setDark) {
    _isDark = setDark;
    notifyListeners();
  }
}

class IsLoading with ChangeNotifier {
  List<bool> isLoading = [false, false, false, false, false, false];
  bool state(int index) {
    return isLoading[index];
  }

  void setState(int index, bool state) {
    isLoading[index] = state;
    notifyListeners();
  }
}

class NoteLock with ChangeNotifier {
  bool locked = false;
  bool isLocked() {
    return locked;
  }

  void setState(bool state) {
    locked = state;
    notifyListeners();
  }
}

// ignore: must_be_immutable
class PDFScreen extends StatelessWidget {
  String pathPDF = '';
  String title = '';
  PDFScreen(this.pathPDF, this.title);

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        globals.currentTheme.isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        globals.currentTheme.isDark());
    return PDFViewerScaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              //change your color here
              ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: <Widget>[
            IconButton(
              icon: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: Icon(
                  Icons.share_outlined,
                ),
              ),
              onPressed: () {
                ShareExtend.share(pathPDF, title);
              },
            ),
          ],
        ),
        path: pathPDF);
  }
}

// ignore: must_be_immutable
class ContextEntry extends PopupMenuEntry<int> {
  @override
  double height = 50;
  // height doesn't matter, as long as we are not giving
  // initialValue to showMenu().

  @override
  bool represents(int n) => n == 1 || n == -1;

  @override
  ContextEntryState createState() => ContextEntryState();
}

class ContextEntryState extends State<ContextEntry> {
  void copy() {
    // This is how you close the popup menu and return user selection.
    Navigator.pop<int>(context, 1);
  }

  void share() {
    Navigator.pop<int>(context, -1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 20,
            child: TextButton(
              onPressed: copy,
              child: Text('copy').tr(),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            child: TextButton(
              onPressed: share,
              child: Text('share').tr(),
            ),
          ),
        ),
      ],
    );
  }
}

class Salle {
  Salle(this.name, this.occupation);
  final String name;
  final List<bool> occupation;
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
