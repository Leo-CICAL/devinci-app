import 'dart:async';
import 'package:devinci/pages/login.dart';
import 'package:devinci/libraries/feedback/feedback.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:syncfusion_flutter_core/core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:quick_actions/quick_actions.dart';
//import './config.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MyApp());

  globals.prefs = await SharedPreferences.getInstance();
  String setTheme = globals.prefs.getString("theme") ?? "Système";
  if (setTheme != "Système") {
    globals.currentTheme.setDark(setTheme == "Sombre");
  } else {
    globals.currentTheme.setDark(
        SchedulerBinding.instance.window.platformBrightness == Brightness.dark);
  }
  //init quick_actions
  final QuickActions quickActions = new QuickActions();
  quickActions.initialize(quickActionsCallback);
  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
        type: 'action_edt', localizedTitle: 'EDT', icon: 'icon_edt'),
    const ShortcutItem(
        type: 'action_notes', localizedTitle: 'Notes', icon: 'icon_notes'),
    const ShortcutItem(
        type: 'action_presence',
        localizedTitle: 'Présence',
        icon: 'icon_presence'),
    const ShortcutItem(
        type: 'action_offline',
        localizedTitle: 'Hors connexion',
        icon: 'icon_offline'),
  ]);
  // initialisation du système de notifications.
  globals.notificationAppLaunchDetails = await globals
      .flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();
  // Note: Les permissions pour les notifications ne sont pas demandées à ce niveau parce qu'elles sont déjà demandées en bas niveau, en swift dans AppDelegate.swift pour iOS et en Kotlin dans MainActivity.kt lors du premier démarrage de l'app
  await globals.flutterLocalNotificationsPlugin.initialize(
      globals.initializationSettings,
      onSelectNotification: onSelectNotification);

  // SyncfusionLicense.registerLicense(
  //     Config.syncfusionLicense); //initialisation des widgets

  // Fin init notifications

  runApp(
    BetterFeedback(
        // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
        child: Phoenix(
          // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
          child: MyApp(),
        ),
        onFeedback: betterFeedbackOnFeedback),
  );
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    globals.currentTheme.addListener(() {
      if (mounted) setState(() {});
    });
    globals.analytics = FirebaseAnalytics();
    globals.observer = FirebaseAnalyticsObserver(analytics: globals.analytics);
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    String setTheme = globals.prefs.getString("theme") ?? "Système";
    if (setTheme == "Système") {
      globals.currentTheme.setDark(brightness == Brightness.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;
    return MaterialApp(
      localizationsDelegates: [
        RefreshLocalizations.delegate,
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
      navigatorObservers: <NavigatorObserver>[globals.observer],
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Colors.teal,
        accentColor: Colors.teal[800],
        textSelectionColor: Colors.teal[900],
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
      ),
      darkTheme: ThemeData(
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
      ),
      themeMode: globals.currentTheme.currentTheme(),
      home: LoginPage(title: 'Devinci'),
      debugShowCheckedModeBanner: false,
    );
  }
}
