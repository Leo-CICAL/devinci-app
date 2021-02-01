// imports
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:devinci/extra/globals.dart' as globals;

import '../mainPage.dart';

// variables

final myControllerUsername = TextEditingController();
final myControllerPassword = TextEditingController();
final FocusNode usernameFocus = FocusNode();
final FocusNode passwordFocus = FocusNode();
final formKey = GlobalKey<FormState>();
ButtonState buttonState = ButtonState.normal;
bool show = false;

//methods

String validator(String value) {
  if (globals.user != null) {
    if (globals.user.error) {
      return 'wrong_id'.tr();
    }
  }
  if (value.isEmpty) {
    return 'no_empty'.tr();
  }
  return null;
}

void submit([String value]) async {
  passwordFocus.unfocus();

  if (globals.user != null) {
    globals.user.error = false;
  }
  if (formKey.currentState.validate()) {
    if (globals.user != null) {
      globals.user.error = false;
    }
    if (formKey.currentState.validate()) {
      l('valid');
      setState(() {
        buttonState = ButtonState.inProgress;
      });
      globals.user = Student(
          myControllerUsername.text.replaceAll(RegExp(r'\s+'), '') +
              '@edu.devinci.fr',
          myControllerPassword.text);
      try {
        await globals.user.init(getContext());

        await Navigator.push(
          getContext(),
          CupertinoPageRoute(
            builder: (context) => MainPage(key: globals.mainPageKey),
          ),
        );
      } catch (exception, stacktrace) {
        l(exception);
        setState(() {
          buttonState = ButtonState.error;
        });
        Timer(
            Duration(milliseconds: 500),
            () => setState(() {
                  buttonState = ButtonState.normal;
                }));
        //user.init() throw error if credentials are wrong or if an error occurred during the process
        if (globals.user.code == 401) {
          //credentials are wrong
          myControllerPassword.text = '';
        } else {
          await reportError(
              'main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception',
              stacktrace);

          await showDialog(
            context: getContext(),
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: Text('error').tr(),
                content: Text(
                  'unknown_error'.tr(namedArgs: {
                    'code': globals.user.code.toString(),
                    'exception': exception
                  }),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('close').tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }

        formKey.currentState.validate();
      }
    } else {
      l('invalid');
      setState(() {
        buttonState = ButtonState.error;
      });
      Timer(
          Duration(milliseconds: 500),
          () => setState(() {
                buttonState = ButtonState.normal;
              }));
    }
  } else {
    l('invalid');
    setState(() {
      buttonState = ButtonState.error;
    });
    Timer(
        Duration(milliseconds: 500),
        () => setState(() {
              buttonState = ButtonState.normal;
            }));
  }
}

void runBeforeBuild() async {
  String username;
  String password;
  //analytics will only be used as much as right now during test phase to have access to the full context of any error.

  var connectivityResult = await (Connectivity().checkConnectivity());
  if (!globals.isConnected) {
    l('shortcut set offline');
  } else {
    globals.isConnected = globals.prefs.getBool('isConnected') ?? true;
    if (!globals.isConnected) l('prefs set offline');
    if (globals.isConnected) {
      l('no pref nor shortcut set to offline');
      globals.isConnected = connectivityResult != ConnectivityResult.none;
    }
  }
  username = await globals.storage.read(key: 'username');
  password = await globals.storage.read(key: 'password');

  if (username != null && password != null) {
    l('credentials_exists');
    globals.user = Student(username, password);
    try {
      await globals.user.init(getContext());
    } catch (exception, stacktrace) {
      setState(() {
        show = true;
      });

      l(exception.toString());

      //user.init() throw error if credentials are wrong or if an error occurred during the process
      if (globals.user.code == 401) {
        //credentials are wrong
        myControllerPassword.text = '';
      } else {
        await reportError(
            'main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception',
            stacktrace);

        await showDialog(
          context: getContext(),
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('error').tr(),
              content: Text(
                'unknown_error'.tr(namedArgs: {
                  'code': globals.user.code.toString(),
                  'exception': exception.toString()
                }),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('close').tr(),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      formKey.currentState.validate();
    }
    try {
      await Navigator.push(
        getContext(),
        CupertinoPageRoute(
          builder: (context) => MainPage(key: globals.mainPageKey),
        ),
      );
      // ignore: empty_catches
    } catch (e) {}
  } else {
    setState(() {
      show = true;
    });
  }

  //here we shall have valid tokens and basic data about the user such as name, badge id, etc
}

void didChangeAppLifecycle(AppLifecycleState state) async {
  String username;
  String password;

  var connectivityResult = await (Connectivity().checkConnectivity());
  if (!globals.isConnected) {
    l('shortcut set offline');
  } else {
    globals.isConnected = globals.prefs.getBool('isConnected') ?? true;
    if (!globals.isConnected) l('prefs set offline');
    if (globals.isConnected) {
      l('no pref nor shortcut set to offline');
      globals.isConnected = connectivityResult != ConnectivityResult.none;
    }
  }
  username = await globals.storage.read(key: 'username');
  password = await globals.storage.read(key: 'password');

  if (username != null && password != null) {
    l('credentials_exists');
    globals.user = Student(username, password);
    try {
      await globals.user.init(getContext());
    } catch (exception, stacktrace) {
      setState(() {
        show = true;
      });
      l(exception);

      //user.init() throw error if credentials are wrong or if an error occurred during the process
      if (globals.user.code == 401) {
        //credentials are wrong
        myControllerPassword.text = '';
      } else {
        await reportError(
            'main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception',
            stacktrace);
        await showDialog(
          context: getContext(),
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('error').tr(),
              content: Text(
                'unknown_error'.tr(namedArgs: {
                  'code': globals.user.code.toString(),
                  'exception': exception
                }),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('close').tr(),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }

      formKey.currentState.validate();
    }
    await Navigator.push(
      getContext(),
      CupertinoPageRoute(
        builder: (context) => MainPage(key: globals.mainPageKey),
      ),
    );
  } else {
    setState(() {
      show = true;
    });
  }
}

void setState(void Function() fun, {bool condition = true}) {
  if (globals.loginPageKey.currentState != null) {
    if (globals.loginPageKey.currentState.mounted && condition) {
      // ignore: invalid_use_of_protected_member
      globals.loginPageKey.currentState.setState(fun);
    }
  }
}

BuildContext getContext() {
  if (globals.loginPageKey.currentState != null) {
    return globals.loginPageKey.currentState.context;
  } else {
    return globals.getScaffold();
  }
}
