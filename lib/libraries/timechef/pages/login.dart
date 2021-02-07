import 'dart:async';

import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
//import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:f_logs/f_logs.dart';
import '../timechef.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final myControllerUsername = TextEditingController();
  final myControllerPassword = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  ButtonState buttonState = ButtonState.normal;
  bool show = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerUsername.dispose();
    myControllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (show) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 28.0, right: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Elior - TimeChef',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    focusNode: _usernameFocus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'user'.tr,
                    ),
                    controller: myControllerUsername,
                    onFieldSubmitted: (term) {
                      fieldFocusChange(context, _usernameFocus, _passwordFocus);
                    },
                    validator: (value) {
                      if (globals.timeChefUser != null) {
                        if (globals.timeChefUser.error) {
                          return 'wrong_id'.tr;
                        }
                      }
                      if (value.isEmpty) {
                        return 'no_empty'.tr;
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: TextFormField(
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      focusNode: _passwordFocus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'password'.tr,
                      ),
                      controller: myControllerPassword,
                      onFieldSubmitted: (value) async {
                        _passwordFocus.unfocus();

                        if (globals.timeChefUser != null) {
                          globals.timeChefUser.error = false;
                        }
                        if (_formKey.currentState.validate()) {
                          FLog.info(
                              className: '_LoginPageState',
                              methodName: 'build',
                              text: 'valid');
                          setState(() {
                            buttonState = ButtonState.inProgress;
                          });
                          globals.timeChefUser = TimeChefUser(
                              myControllerUsername.text,
                              myControllerPassword.text);
                          try {
                            await globals.timeChefUser.init();
                            globals.pageChanger.setPage(1);
                          } catch (exception, stacktrace) {
                            FLog.logThis(
                                className: '_LoginPageState',
                                methodName: 'build',
                                text: 'exception',
                                type: LogLevel.ERROR,
                                exception: Exception(exception),
                                stacktrace: stacktrace);
                            setState(() {
                              buttonState = ButtonState.error;
                            });
                            Timer(
                                Duration(milliseconds: 500),
                                () => setState(() {
                                      buttonState = ButtonState.normal;
                                    }));
                            //user.init() throw error if credentials are wrong or if an error occurred during the process
                            if (globals.timeChefUser.code == 401) {
                              //credentials are wrong
                              myControllerPassword.text = '';
                            } else {
                              await reportError(exception, stacktrace);

                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: Text('error'.tr),
                                    content: Text(
                                      'unknown_error'.trArgs([
                                        globals.user.code.toString(),
                                        exception
                                      ]),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('close'.tr),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            _formKey.currentState.validate();
                          }
                        } else {
                          setState(() {
                            buttonState = ButtonState.error;
                          });
                          Timer(
                              Duration(milliseconds: 500),
                              () => setState(() {
                                    buttonState = ButtonState.normal;
                                  }));
                        }
                      },
                      validator: (value) {
                        if (globals.timeChefUser != null) {
                          if (globals.timeChefUser.error) {
                            return null;
                          }
                        }
                        if (value.isEmpty) {
                          return 'no_empty'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ProgressButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'login'.tr.toUpperCase(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: globals.currentTheme.isDark()
                                  ? Colors.black
                                  : Colors.white),
                        ),
                      ),
                      onPressed: () async {
                        if (globals.timeChefUser != null) {
                          globals.timeChefUser.error = false;
                        }
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            buttonState = ButtonState.inProgress;
                          });
                          globals.timeChefUser = TimeChefUser(
                              myControllerUsername.text,
                              myControllerPassword.text);
                          try {
                            await globals.timeChefUser.init();
                            globals.pageChanger.setPage(1);
                          } catch (exception, stacktrace) {
                            FLog.logThis(
                                className: '_LoginPageState',
                                methodName: 'build',
                                text: 'exception',
                                type: LogLevel.ERROR,
                                exception: Exception(exception),
                                stacktrace: stacktrace);
                            setState(() {
                              buttonState = ButtonState.error;
                            });
                            Timer(
                                Duration(milliseconds: 500),
                                () => setState(() {
                                      buttonState = ButtonState.normal;
                                    }));
                            //user.init() throw error if credentials are wrong or if an error occurred during the process
                            if (globals.timeChefUser.code == 401) {
                              //credentials are wrong
                              myControllerPassword.text = '';
                            } else {
                              await reportError(exception, stacktrace);

                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: Text('error'.tr),
                                    content: Text(
                                      'unknown_error'.trArgs([
                                        globals.user.code.toString(),
                                        exception
                                      ]),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('close'.tr),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            _formKey.currentState.validate();
                          }
                        } else {
                          setState(() {
                            buttonState = ButtonState.error;
                          });
                          Timer(
                              Duration(milliseconds: 500),
                              () => setState(() {
                                    buttonState = ButtonState.normal;
                                  }));
                        }
                      },
                      buttonState: buttonState,
                      backgroundColor: Theme.of(context).accentColor,
                      progressColor: globals.currentTheme.isDark()
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                          onPressed: () async {
                            const url = 'https://timechef.elior.com/#/register';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text('no_account'.tr,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor))))
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return TitleSection('self_balance',
          iconButton: OutlinedButton(
              onPressed: () {
                setState(() {
                  show = true;
                });
              },
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith((states) {
                return Theme.of(context).accentColor.withOpacity(0.2);
              })),
              child: Text('login'.tr,
                  style: TextStyle(color: Theme.of(context).accentColor))),
          padding: EdgeInsets.only(left: 16));
    }
  }
}
