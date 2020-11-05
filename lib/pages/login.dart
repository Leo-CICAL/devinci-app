import 'dart:async';
import 'package:about/about.dart';
import 'package:connectivity/connectivity.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'mainPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final myControllerUsername = TextEditingController();
  final myControllerPassword = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  ButtonState buttonState = ButtonState.normal;
  bool show = false;

  void runBeforeBuild() async {
    String username;
    String password;
    //analytics will only be used as much as right now during test phase to have access to the full context of any error.

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!globals.isConnected) {
      print("shortcut set offline");
    } else {
      globals.isConnected = globals.prefs.getBool("isConnected") ?? true;
      if (!globals.isConnected) print("prefs set offline");
      if (globals.isConnected) {
        print("no pref nor shortcut set to offline");
        globals.isConnected = connectivityResult != ConnectivityResult.none;
      }
    }
    username = await globals.storage.read(key: "username");
    password = await globals.storage.read(key: "password");

    if (username != null && password != null) {
      print("credentials_exists");
      globals.user = new User(username, password);
      try {
        await globals.user.init();
      } catch (exception, stacktrace) {
        if (mounted)
          setState(() {
            show = true;
          });
        print(exception);

        //user.init() throw error if credentials are wrong or if an error occurred during the process
        if (globals.user.code == 401) {
          //credentials are wrong
          myControllerPassword.text = "";
        } else {
          await reportError(
              "main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception",
              stacktrace);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Erreur"),
                content: new Text(
                    "Une erreur inconnue est survenue.\n\nCode : ${globals.user.code}\nInformation: $exception"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Fermer"),
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
      try{
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => MainPage(),
        ),
      );
      }catch(e){
        
      }
    } else {
      if (mounted)
        setState(() {
          show = true;
        });
    }

    //here we shall have valid tokens and basic data about the user such as name, badge id, etc
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("changed");
    String username;
    String password;
    //analytics will only be used as much as right now during test phase to have access to the full context of any error.

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!globals.isConnected) {
      print("shortcut set offline");
    } else {
      globals.isConnected = globals.prefs.getBool("isConnected") ?? true;
      if (!globals.isConnected) print("prefs set offline");
      if (globals.isConnected) {
        print("no pref nor shortcut set to offline");
        globals.isConnected = connectivityResult != ConnectivityResult.none;
      }
    }
    username = await globals.storage.read(key: "username");
    password = await globals.storage.read(key: "password");

    if (username != null && password != null) {
      print("credentials_exists");
      globals.user = new User(username, password);
      try {
        await globals.user.init();
      } catch (exception, stacktrace) {
        setState(() {
          show = true;
        });
        print(exception);

        //user.init() throw error if credentials are wrong or if an error occurred during the process
        if (globals.user.code == 401) {
          //credentials are wrong
          myControllerPassword.text = "";
        } else {
          await reportError(
              "main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception",
              stacktrace);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Erreur"),
                content: new Text(
                    "Une erreur inconnue est survenue.\n\nCode : ${globals.user.code}\nInformation: $exception"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Fermer"),
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
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    } else {
      setState(() {
        show = true;
      });
    }
  }

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerUsername.dispose();
    myControllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        globals.currentTheme.isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        globals.currentTheme.isDark());
    globals.currentContext = context;

    return new WillPopScope(
        onWillPop: () async => false,
        child: new Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                statusBarIconBrightness: globals.currentTheme.isDark()
                    ? Brightness.light
                    : Brightness.dark),
            child: !show
                ? Center(
                    child: CupertinoActivityIndicator(
                    animating: true,
                  ))
                : new Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 28.0, right: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            "Bienvenue",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Roboto',
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
                                key: Key('login_username'),
                                textInputAction: TextInputAction.next,
                                focusNode: _usernameFocus,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Utilisateur',
                                ),
                                controller: myControllerUsername,
                                onFieldSubmitted: (term) {
                                  fieldFocusChange(
                                      context, _usernameFocus, _passwordFocus);
                                },
                                validator: (value) {
                                  if (globals.user != null) {
                                    if (globals.user.error) {
                                      return 'Identifiants incorrects';
                                    }
                                  }
                                  if (value.isEmpty) {
                                    return 'Ne peut être vide';
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
                                  key: Key('login_password'),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mot de passe',
                                  ),
                                  controller: myControllerPassword,
                                  onFieldSubmitted: (value) async {
                                    _passwordFocus.unfocus();

                                    if (globals.user != null)
                                      globals.user.error = false;
                                    if (_formKey.currentState.validate()) {
                                      if (globals.user != null)
                                        globals.user.error = false;
                                      if (_formKey.currentState.validate()) {
                                        print("valid");
                                        setState(() {
                                          buttonState = ButtonState.inProgress;
                                        });
                                        globals.user = new User(
                                            myControllerUsername.text,
                                            myControllerPassword.text);
                                        try {
                                          await globals.user.init();

                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => MainPage(),
                                            ),
                                          );
                                        } catch (exception, stacktrace) {
                                          print(exception);
                                          setState(() {
                                            buttonState = ButtonState.error;
                                          });
                                          Timer(
                                              Duration(milliseconds: 500),
                                              () => setState(() {
                                                    buttonState =
                                                        ButtonState.normal;
                                                  }));
                                          //user.init() throw error if credentials are wrong or if an error occurred during the process
                                          if (globals.user.code == 401) {
                                            //credentials are wrong
                                            myControllerPassword.text = "";
                                          } else {
                                            await reportError(
                                                'main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception',
                                                stacktrace);

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // return object of type Dialog
                                                return AlertDialog(
                                                  title: new Text("Erreur"),
                                                  content: new Text(
                                                      "Une erreur inconnue est survenue.\n\nCode : ${globals.user.code}\nInformation: $exception"),
                                                  actions: <Widget>[
                                                    // usually buttons at the bottom of the dialog
                                                    new FlatButton(
                                                      child: new Text("Fermer"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
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
                                        print("invalid");
                                        setState(() {
                                          buttonState = ButtonState.error;
                                        });
                                        Timer(
                                            Duration(milliseconds: 500),
                                            () => setState(() {
                                                  buttonState =
                                                      ButtonState.normal;
                                                }));
                                      }
                                    } else {
                                      print("invalid");
                                      setState(() {
                                        buttonState = ButtonState.error;
                                      });
                                      Timer(
                                          Duration(milliseconds: 500),
                                          () => setState(() {
                                                buttonState =
                                                    ButtonState.normal;
                                              }));
                                    }
                                  },
                                  validator: (value) {
                                    if (globals.user != null) {
                                      if (globals.user.error) {
                                        return null;
                                      }
                                    }
                                    if (value.isEmpty) {
                                      return 'Ne peut être vide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: ProgressButton(
                                  key: Key('login_connect'),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    child: Text(
                                      "Connexion".toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: globals.currentTheme.isDark()
                                              ? Colors.black
                                              : Colors.white),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (globals.user != null)
                                      globals.user.error = false;
                                    if (_formKey.currentState.validate()) {
                                      print("valid");
                                      setState(() {
                                        buttonState = ButtonState.inProgress;
                                      });
                                      globals.user = new User(
                                          myControllerUsername.text,
                                          myControllerPassword.text);
                                      try {
                                        await globals.user.init();

                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => MainPage(),
                                          ),
                                        );
                                      } catch (exception, stacktrace) {
                                        print(exception);
                                        setState(() {
                                          buttonState = ButtonState.error;
                                        });
                                        Timer(
                                            Duration(milliseconds: 500),
                                            () => setState(() {
                                                  buttonState =
                                                      ButtonState.normal;
                                                }));
                                        //user.init() throw error if credentials are wrong or if an error occurred during the process
                                        if (globals.user.code == 401) {
                                          //credentials are wrong
                                          myControllerPassword.text = "";
                                        } else {
                                          await reportError(
                                              'main.dart | _LoginPageState | runBeforeBuild() | user.init() | else => $exception',
                                              stacktrace);

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // return object of type Dialog
                                              return AlertDialog(
                                                title: new Text("Erreur"),
                                                content: new Text(
                                                    "Une erreur inconnue est survenue.\n\nCode : ${globals.user.code}\nInformation: $exception"),
                                                actions: <Widget>[
                                                  // usually buttons at the bottom of the dialog
                                                  new FlatButton(
                                                    child: new Text("Fermer"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                      print("invalid");
                                      setState(() {
                                        buttonState = ButtonState.error;
                                      });
                                      Timer(
                                          Duration(milliseconds: 500),
                                          () => setState(() {
                                                buttonState =
                                                    ButtonState.normal;
                                              }));
                                    }
                                  },
                                  buttonState: buttonState,
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  progressColor: globals.currentTheme.isDark()
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          persistentFooterButtons: show
              ? [
                  FlatButton(
                      key: Key('login_cgu'),
                      child: Text('CGU'),
                      onPressed: () {
                        showMarkdownPage(
                          applicationIcon: SizedBox(
                            width: 100,
                            height: 100,
                            child: Container(
                              child: Center(
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/icon_blanc_a.png'),
                                  radius: 50,
                                ),
                              ),
                            ),
                          ),
                          context: context,
                          applicationName: 'Devinci',
                          filename: 'assets/tos.md',
                          title: Text("Conditions générales d'utilisation"),
                          useMustache: false,
                          mustacheValues: null,
                        );
                      }),
                  FlatButton(
                      key: Key('login_privacy'),
                      child: Text('Politique de confidentialité'),
                      onPressed: () {
                        showMarkdownPage(
                          applicationIcon: SizedBox(
                            width: 100,
                            height: 100,
                            child: Container(
                              child: Center(
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/icon_blanc_a.png'),
                                  radius: 50,
                                ),
                              ),
                            ),
                          ),
                          context: context,
                          applicationName: 'Devinci',
                          filename: 'assets/privacy.md',
                          title: Text('Politique de confidentialité'),
                          useMustache: false,
                          mustacheValues: null,
                        );
                      })
                ]
              : null,
        ));
  }
}
