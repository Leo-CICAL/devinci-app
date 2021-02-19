import 'dart:io';

import 'package:devinci/extra/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:devinci/extra/globals.dart' as globals;

import 'package:share_extend/share_extend.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';

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

enum ThemeType { Light, Dark, TrueDark }

class DevinciTheme {
  static ThemeData currentTheme = darkTheme;
  static ThemeType _themeType = ThemeType.Dark;

  static ThemeData getTheme(ThemeType type) {
    switch (type) {
      case ThemeType.Light:
        currentTheme = lightTheme;
        _themeType = ThemeType.Light;
        break;
      case ThemeType.Dark:
        currentTheme = darkTheme;
        _themeType = ThemeType.Dark;
        break;
      case ThemeType.TrueDark:
        currentTheme = trueDarkTheme;
        _themeType = ThemeType.TrueDark;
        break;
      default:
        throw ArgumentError.value(
            type, 'type', 'type must be part of ThemeType');
    }
    return currentTheme;
  }
}

class CustomTheme extends StatefulWidget {
  final Widget child;
  final ThemeType initialThemeType;

  const CustomTheme({
    Key key,
    this.initialThemeType,
    @required this.child,
  }) : super(key: key);

  @override
  CustomThemeState createState() => new CustomThemeState();

  static ThemeData of(BuildContext context) {
    _CustomTheme inherited =
        (context.dependOnInheritedWidgetOfExactType<_CustomTheme>());
    return inherited.data.theme;
  }

  static CustomThemeState instanceOf(BuildContext context) {
    _CustomTheme inherited =
        (context.dependOnInheritedWidgetOfExactType<_CustomTheme>());
    return inherited.data;
  }
}

class CustomThemeState extends State<CustomTheme> {
  ThemeData _theme;

  ThemeData get theme => _theme;

  @override
  void initState() {
    _theme = DevinciTheme.getTheme(widget.initialThemeType);
    super.initState();
  }

  void changeTheme(ThemeType themeType) {
    setState(() {
      _theme = DevinciTheme.getTheme(themeType);
    });
  }

  void changeThemeByName(String name) {
    setState(() {
      switch (name) {
        case 'light':
          _theme = lightTheme;
          break;
        case 'dark':
          _theme = darkTheme;
          break;
        case 'amoled_dark':
          _theme = trueDarkTheme;
          break;
        default:
          throw ArgumentError.value(name, 'name', 'name must be a theme name');
      }
    });
  }

  bool isDark() {
    return _theme == darkTheme || _theme == trueDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return new _CustomTheme(
      data: this,
      child: widget.child,
    ); //nothing here for now!
  }
}

class _CustomTheme extends InheritedWidget {
  final CustomThemeState data;

  _CustomTheme({
    this.data,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CustomTheme oldWidget) {
    return true;
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
        CustomTheme.instanceOf(context).isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        CustomTheme.instanceOf(context).isDark());
    return Scaffold(
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
        body: SfPdfViewer.file(File(pathPDF)));
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

class AgendaTitle with ChangeNotifier {
  String _headerText = '';

  String get headerText => _headerText;

  set headerText(String value) {
    _headerText = value;
    notifyListeners();
  }
}
