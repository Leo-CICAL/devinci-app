import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import 'CommonWidgets.dart';
import 'classes.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  accentColor: Colors.tealAccent[200],
  textSelectionColor: Colors.tealAccent[700],
  textSelectionHandleColor: Colors.tealAccent[200],
  cursorColor: Colors.teal,
  backgroundColor: Color(0xff121212),
  scaffoldBackgroundColor: Color(0xff121212),
  cardColor: Color(0xff1E1E1E),
  indicatorColor: Colors.tealAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);

ThemeData darkEsilvTheme = ThemeData(
  brightness: Brightness.dark,
  //primaryColor: Color(0xffC90F50),
  primaryColor: Colors.pink[600],
  accentColor: Colors.pinkAccent[200],
  textSelectionColor: Colors.pinkAccent[700],
  textSelectionHandleColor: Colors.pinkAccent[200],
  cursorColor: Colors.pink,
  backgroundColor: Color(0xff121212),
  scaffoldBackgroundColor: Color(0xff121212),
  cardColor: Color(0xff1E1E1E),
  indicatorColor: Colors.pinkAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);

ThemeData darkIimTheme = ThemeData(
  brightness: Brightness.dark,
  //primaryColor: Color(0xffE87900),
  primaryColor: Colors.orange[700],
  accentColor: Colors.orangeAccent[200],
  textSelectionColor: Colors.orangeAccent[700],
  textSelectionHandleColor: Colors.orangeAccent[200],
  cursorColor: Colors.orange,
  backgroundColor: Color(0xff121212),
  scaffoldBackgroundColor: Color(0xff121212),
  cardColor: Color(0xff1E1E1E),
  indicatorColor: Colors.orangeAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);

ThemeData darkEmlvTheme = ThemeData(
  brightness: Brightness.dark,
  //primaryColor: Color(0xff0296B7),
  primaryColor: Colors.cyan[700],
  accentColor: Colors.cyanAccent[200],
  textSelectionColor: Colors.cyanAccent[700],
  textSelectionHandleColor: Colors.cyanAccent[200],
  cursorColor: Colors.cyan,
  backgroundColor: Color(0xff121212),
  scaffoldBackgroundColor: Color(0xff121212),
  cardColor: Color(0xff1E1E1E),
  indicatorColor: Colors.cyanAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);

ThemeData lightEsilvTheme = ThemeData(
  primaryColor: Colors.pink,
  accentColor: Color(0xffC90F50),
  textSelectionColor: Colors.pink.withOpacity(0.4),
  textSelectionHandleColor: Color(0xffC90F50),
  cursorColor: Colors.pink,
  scaffoldBackgroundColor: Color(0xffFAFAFA),
  cardColor: Colors.white,
  indicatorColor: Color(0xffC90F50),
  accentIconTheme: IconThemeData(color: Colors.black),
  unselectedWidgetColor: Colors.black,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.black,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black,
    ),
  ),
);

ThemeData lightIimTheme = ThemeData(
  primaryColor: Colors.orange,
  accentColor: Color(0xffE87900),
  textSelectionColor: Colors.orange.withOpacity(0.4),
  textSelectionHandleColor: Color(0xffE87900),
  cursorColor: Colors.orange,
  scaffoldBackgroundColor: Color(0xffFAFAFA),
  cardColor: Colors.white,
  indicatorColor: Color(0xffE87900),
  accentIconTheme: IconThemeData(color: Colors.black),
  unselectedWidgetColor: Colors.black,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.black,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black,
    ),
  ),
);

ThemeData lightEmlvTheme = ThemeData(
  primaryColor: Colors.cyan,
  accentColor: Color(0xff0296B7),
  textSelectionColor: Colors.cyan.withOpacity(0.4),
  textSelectionHandleColor: Color(0xff0296B7),
  cursorColor: Colors.cyan,
  scaffoldBackgroundColor: Color(0xffFAFAFA),
  cardColor: Colors.white,
  indicatorColor: Color(0xff0296B7),
  accentIconTheme: IconThemeData(color: Colors.black),
  unselectedWidgetColor: Colors.black,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.black,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black,
    ),
  ),
);

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.teal,
  primaryColor: Colors.teal,
  accentColor: Colors.teal[800],
  textSelectionColor: Colors.teal.withOpacity(0.4),
  textSelectionHandleColor: Colors.teal[800],
  cursorColor: Colors.teal,
  scaffoldBackgroundColor: Color(0xffFAFAFA),
  cardColor: Colors.white,
  indicatorColor: Colors.teal[800],
  accentIconTheme: IconThemeData(color: Colors.black),
  unselectedWidgetColor: Colors.black,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.black,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.black,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black,
    ),
  ),
);

ThemeData trueDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.teal,
  accentColor: Colors.tealAccent[200],
  textSelectionColor: Colors.tealAccent[700],
  textSelectionHandleColor: Colors.tealAccent[200],
  cursorColor: Colors.teal,
  backgroundColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Color(0xff121212),
  indicatorColor: Colors.tealAccent[200],
  accentIconTheme: IconThemeData(color: Colors.white),
  unselectedWidgetColor: Colors.white,
  fontFamily: 'ProductSans',
  textTheme: TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 26,
      color: Colors.white,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
);

void showThemePicker(BuildContext context) async {
  return await showBarModalBottomSheet(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: ListView(
        shrinkWrap: true,
        controller: ModalScrollController.of(context),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('custom_theme',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline2)
                .tr(),
          ),
          ColorPicker(),
        ],
      ),
    ),
  );
}

class ThemePicker extends StatefulWidget {
  ThemePicker({Key key}) : super(key: key);

  @override
  _ThemePickerState createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  bool loading = true;
  bool donator = false;

  void runBeforeBuild() async {
    var purchaserInfo = await Purchases.getPurchaserInfo();
    setState(() {
      loading = false;
      donator = purchaserInfo.entitlements.all['donor'].isActive;
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 18,
        bottom: 18,
      ),
      height: 56.0,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: BicolorButton(
                childA: Text(
                  'system',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: lightTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  softWrap: false,
                ).tr(),
                childB: Text(
                  'system',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: darkTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  softWrap: false,
                ).tr(),
                height: 48,
                width: 96,
                colorA: lightTheme.scaffoldBackgroundColor,
                colorB: darkTheme.scaffoldBackgroundColor,
                onPressed: () {
                  CustomTheme.instanceOf(context).changeTheme(
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? ThemeType.Dark
                          : ThemeType.Light);
                },
                context: context),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 7, top: 1),
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide.none),
              child: FlatButton(
                  height: 48,
                  color: lightTheme.scaffoldBackgroundColor,
                  textColor: lightTheme.accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide.none),
                  onPressed: () {
                    CustomTheme.instanceOf(context)
                        .changeTheme(ThemeType.Light);
                  },
                  child: Text('light').tr()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 1, bottom: 7),
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide.none),
              child: FlatButton(
                height: 48,
                color: darkTheme.scaffoldBackgroundColor,
                textColor: darkTheme.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide.none),
                onPressed: () {
                  CustomTheme.instanceOf(context).changeTheme(ThemeType.Dark);
                },
                child: Text('dark').tr(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 1, bottom: 7),
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide.none),
              child: FlatButton(
                height: 48,
                color: trueDarkTheme.scaffoldBackgroundColor,
                textColor: trueDarkTheme.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide.none),
                onPressed: () {
                  if (!loading) {
                    if (donator) {
                      CustomTheme.instanceOf(context)
                          .changeTheme(ThemeType.TrueDark);
                    } else {
                      final snackBar = SnackBar(
                        content: Text('theme_locked_donation_msg').tr(),
                        duration: const Duration(seconds: 6),
                      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
                      showSnackBar(snackBar, forceOneContext: true);
                    }
                  }
                },
                child: loading
                    ? CupertinoActivityIndicator()
                    : (donator ? Text('AMOLED') : Icon(Icons.lock_outlined)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: BicolorButton(
                childA: loading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness: Brightness.light)),
                        child: CupertinoActivityIndicator())
                    : (donator
                        ? Text(
                            'ESILV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: lightEsilvTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            softWrap: false,
                          )
                        : Icon(
                            Icons.lock_outlined,
                            color: lightEsilvTheme.accentColor,
                          )),
                childB: loading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness: Brightness.dark)),
                        child: CupertinoActivityIndicator())
                    : (donator
                        ? Text(
                            'ESILV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: darkEsilvTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            softWrap: false,
                          )
                        : Icon(
                            Icons.lock_outlined,
                            color: darkEsilvTheme.accentColor,
                          )),
                height: 48,
                width: 90,
                colorA: lightEsilvTheme.scaffoldBackgroundColor,
                colorB: darkEsilvTheme.scaffoldBackgroundColor,
                onPressed: () {
                  if (!loading) {
                    if (donator) {
                      CustomTheme.instanceOf(context).changeTheme(
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? ThemeType.EsilvDark
                              : ThemeType.EsilvLight);
                    } else {
                      final snackBar = SnackBar(
                        content: Text('theme_locked_donation_msg').tr(),
                        duration: const Duration(seconds: 6),
                      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
                      showSnackBar(snackBar, forceOneContext: true);
                    }
                  }
                },
                context: context),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: BicolorButton(
                childA: loading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness: Brightness.light)),
                        child: CupertinoActivityIndicator())
                    : (donator
                        ? Text(
                            'IIM',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: lightIimTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            softWrap: false,
                          )
                        : Icon(
                            Icons.lock_outlined,
                            color: lightIimTheme.accentColor,
                          )),
                childB: loading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness: Brightness.dark)),
                        child: CupertinoActivityIndicator())
                    : (donator
                        ? Text(
                            'IIM',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: darkIimTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            softWrap: false,
                          )
                        : Icon(
                            Icons.lock_outlined,
                            color: darkIimTheme.accentColor,
                          )),
                height: 48,
                width: 90,
                colorA: lightIimTheme.scaffoldBackgroundColor,
                colorB: darkIimTheme.scaffoldBackgroundColor,
                onPressed: () {
                  if (!loading) {
                    if (donator) {
                      CustomTheme.instanceOf(context).changeTheme(
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? ThemeType.IimDark
                              : ThemeType.IimLight);
                    } else {
                      final snackBar = SnackBar(
                        content: Text('theme_locked_donation_msg').tr(),
                        duration: const Duration(seconds: 6),
                      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
                      showSnackBar(snackBar, forceOneContext: true);
                    }
                  }
                },
                context: context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BicolorButton(
                childA: loading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness: Brightness.light)),
                        child: CupertinoActivityIndicator())
                    : (donator
                        ? Text(
                            'EMLV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: lightEmlvTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            softWrap: false,
                          )
                        : Icon(
                            Icons.lock_outlined,
                            color: lightEmlvTheme.accentColor,
                          )),
                childB: loading
                    ? Theme(
                        data: ThemeData(
                            cupertinoOverrideTheme: CupertinoThemeData(
                                brightness: Brightness.dark)),
                        child: CupertinoActivityIndicator())
                    : (donator
                        ? Text(
                            'EMLV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: darkEmlvTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            softWrap: false,
                          )
                        : Icon(
                            Icons.lock_outlined,
                            color: darkEmlvTheme.accentColor,
                          )),
                height: 48,
                width: 90,
                colorA: lightEmlvTheme.scaffoldBackgroundColor,
                colorB: darkEmlvTheme.scaffoldBackgroundColor,
                onPressed: () {
                  if (!loading) {
                    if (donator) {
                      CustomTheme.instanceOf(context).changeTheme(
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? ThemeType.EmlvDark
                              : ThemeType.EmlvLight);
                    } else {
                      final snackBar = SnackBar(
                        content: Text('theme_locked_donation_msg').tr(),
                        duration: const Duration(seconds: 6),
                      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
                      showSnackBar(snackBar, forceOneContext: true);
                    }
                  }
                },
                context: context),
          ),
        ],
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        shape: SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(40.0),
          ),
        ),
        child: Container(
          height: 300,
          child: Stack(children: [
            Positioned.fill(
              child: MaterialColorPicker(
                  onColorChange: (Color color) {
                    // Handle color changes
                  },
                  selectedColor: Colors.red),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 6.0,
                      sigmaY: 6.0,
                    ),
                    child: Scaffold(
                      // Your usual Scaffold for content
                      backgroundColor: Colors.black26,
                      body: Container(),
                    )),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

Color getTheTeal(BuildContext context) {
  return CustomTheme.instanceOf(context).isDark()
      ? darkTheme.accentColor
      : lightTheme.accentColor;
}
