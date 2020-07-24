import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:devinci/extra/devinci_icons_icons.dart';
import 'package:devinci/pages/absences.dart';
import 'package:devinci/pages/settings.dart';
import 'package:devinci/pages/user.dart';
import 'package:devinci/libraries/feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:devinci/pages/agenda.dart';
import 'package:devinci/pages/notes.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import './config.dart'; //ce fichier est créé par CodeMagic lors du build car il contient des clé de license

Future<Null> main() async {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  // This creates a [Zone] that contains the Flutter application and stablishes
  // an error handler that captures errors and reports them.
  //
  // Using a zone makes sure that as many errors as possible are captured,
  // including those thrown from [Timer]s, microtasks, I/O, and those forwarded
  // from the `FlutterError` handler.
  //
  // More about zones:
  //
  // - https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
  // - https://www.dartlang.org/articles/libraries/zones
  runZonedGuarded<Future<Null>>(() async {
    SyncfusionLicense.registerLicense(
        Config.syncfusionLicense); // vous pouvez obtenir une clé d'activitation gratuitement sur https://www.syncfusion.com, ici $SyncfusionLicense est une variable environnement pour le système de build
    runApp(
      BetterFeedback(
        //backgroundColor: getColor("background", context),
        child: Phoenix(
          //Phoenix allow to "restart" the app, i use it to restart the app when the user sign out.
          child: MyApp(),
        ),
        onFeedback: (
          BuildContext context,
          String feedbackText, // the feedback from the user
          Uint8List feedbackScreenshot, // raw png encoded image data
        ) async {
          final Directory directory = await getExternalStorageDirectory();
          final String path = directory.path;
          File attachment = new File(path + "/devinci_f.png");
          File attachmentNotes = new File(path + "/devinci_n.txt");
          await attachment.writeAsBytes(feedbackScreenshot);
          await attachmentNotes.writeAsString(globals.feedbackNotes);
          //print(attachment.path);
          final Email email = Email(
            body:
                '$feedbackText\n\n Erreur:${globals.feedbackError}\n StackTrace:${globals.feedbackStackTrace.toString()}\n eventId : ${globals.eventId}',
            subject: 'Devinci - Erreur',
            recipients: ['antoine@araulin.eu'],
            attachmentPaths: [attachment.path, attachmentNotes.path],
            isHTML: false,
          );

          await FlutterEmailSender.send(email);
        },
      ),
    );
  }, (error, stackTrace) async {
    await reportError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('fr'),
      ],
      locale: const Locale('fr'),
      title: 'Devinci',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Colors.teal,
        accentColor: Colors.teal[800],
        textSelectionColor: Colors.teal[900],
        textSelectionHandleColor: Colors.teal[800],
        cursorColor: Colors.teal,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.teal,
          accentColor: Colors.tealAccent[200],
          textSelectionColor: Colors.tealAccent[700],
          textSelectionHandleColor: Colors.tealAccent[200],
          cursorColor: Colors.teal,
          backgroundColor: Color(0xff121212),
          scaffoldBackgroundColor: Color(0xff121212)),
      home: LoginPage(title: 'Devinci'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final myControllerUsername = TextEditingController();
  final myControllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ButtonState buttonState = ButtonState.normal;

  bool show = false;

  void runBeforeBuild() async {
    String username = await globals.storage.read(key: "username");
    String password = await globals.storage.read(key: "password");
    if (username != null && password != null) {
      print("credentials exists");
      globals.user = new User(username, password);
      try {
        await globals.user.init();
      } catch (exception, stacktrace) {
        setState(() {
          show = true;
        });
        print(exception);

        //user.init() throw error if credentials are wrong or if an error occured during the process
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
                    "Une erreur inconnue est survenue.\n\nCode : ${globals.user.code}\nInformation: ${exception}"),
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

    //here we shall have valid tokens and basic data about the user such as name, badge id, etc
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
    FlutterStatusbarcolor.setNavigationBarColor(getColor("top", context));
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        MediaQuery.of(context).platformBrightness == Brightness.dark);
    globals.currentContext = context;
    return new WillPopScope(
        onWillPop: () async => false,
        child: new Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: getColor("top", context),
                statusBarIconBrightness:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
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
                                color: getColor("text", context)),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Utilisateur',
                                ),
                                controller: myControllerUsername,
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
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mot de passe',
                                  ),
                                  controller: myControllerPassword,
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
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    child: Text(
                                      "Connexion".toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
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
                                        //user.init() throw error if credentials are wrong or if an error occured during the process
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
                                              // return object of type Dialog
                                              return AlertDialog(
                                                title: new Text("Erreur"),
                                                content: new Text(
                                                    "Une erreur inconnue est survenue.\n\nCode : ${globals.user.code}\nInformation: ${exception}"),
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
                                  backgroundColor: getColor("primary", context),
                                  progressColor: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
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
        ));
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  CalendarView calendarView = CalendarView.month;

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;
    FlutterStatusbarcolor.setStatusBarColor(getColor("top", context));
    FlutterStatusbarcolor.setNavigationBarColor(getColor("top", context));
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        MediaQuery.of(context).platformBrightness == Brightness.dark);
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            elevation: 0.0,
            brightness: MediaQuery.of(context).platformBrightness,
            centerTitle: false,
            backgroundColor: getColor("top", context),
            title: Text(globals.user.data["name"],
                style: TextStyle(
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 36)),
            actions: <Widget>[
              <Widget>[
                IconButton(
                  icon: Icon(globals.agendaView.calendarView == CalendarView.day
                      ? OMIcons.dateRange
                      : Icons.date_range),
                  color: getColor("text", context),
                  onPressed: () {
                    setState(() {
                      if (globals.agendaView.calendarView == CalendarView.day)
                        globals.agendaView.calendarView = CalendarView.month;
                      else
                        globals.agendaView.calendarView = CalendarView.day;
                    });
                  },
                ),
                Text(""),
                Text(""),
                Text(""),
                IconButton(
                  icon: Icon(OMIcons.settings),
                  color: getColor("text", context),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context, scrollController) => SettingsPage(
                              scrollController: scrollController,
                            ));
                  },
                ),
              ].elementAt(_selectedIndex)
            ],
            automaticallyImplyLeading: false),
        body: <Widget>[
          AgendaPage(),
          NotesPage(),
          AbsencesPage(),
          Container(
            child: Center(
              child: Text("Non disponible pour le moment"),
            ),
          ),
          UserPage()
        ].elementAt(_selectedIndex),
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: getColor("top", context),
          ),
          child: new BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 0 ? Icons.today : OMIcons.today),
                  title: Text('EDT'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 1
                      ? Icons.assignment
                      : OMIcons.assignment),
                  title: Text('Notes'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 2
                      ? Icons.watch_later
                      : OMIcons.watchLater),
                  title: Text('Absences'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 3
                      ? DevinciIcons.megaphone_filled
                      : DevinciIcons.megaphone_outlined),
                  title: Text('Présence'),
                ),
                BottomNavigationBarItem(
                  icon:
                      Icon(_selectedIndex == 4 ? Icons.person : OMIcons.person),
                  title: Text(globals.user.data["name"]),
                ),
              ],
              currentIndex: _selectedIndex,
              //showUnselectedLabels: false,
              backgroundColor: getColor("top", context),
              selectedItemColor: getColor("primary", context),
              //type: BottomNavigationBarType.shifting,
              unselectedItemColor: getColor("text", context),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              }),
        ),
      ),
    );
  }
}
