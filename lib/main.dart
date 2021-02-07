import 'dart:async';
import 'package:devinci/libraries/feedback/feedback.dart';
import 'package:devinci/pages/ui/login.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'extra/classes.dart';
import 'extra/translations.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Remove this method to stop OneSignal Debugging
  await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  await OneSignal.shared.setRequiresUserPrivacyConsent(true);
  await OneSignal.shared.init('0a91d723-8929-46ec-9ce7-5e72c59708e5',
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false
      });
  await OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  globals.prefs = await SharedPreferences.getInstance();
  var setTheme = globals.prefs.getString('theme') ?? 'system';
  if (setTheme != 'system') {
    globals.currentTheme.setDark(setTheme == 'dark');
  } else {
    globals.currentTheme.setDark(
        SchedulerBinding.instance.window.platformBrightness == Brightness.dark);
  }
  var packageInfo = await PackageInfo.fromPlatform();
  var appVersion = 'devinci@' + packageInfo.version;
  appVersion += '+' + packageInfo.buildNumber;
  globals.crashConsent = globals.prefs.getString('crashConsent') ??
      'true'; //default to true to catch errors between now and the gdpr popup
  print('clearing logs');
  await FLog.clearLogs();
  if (globals.crashConsent == 'true') {
    await SentryFlutter.init(
      (options) => options
        ..dsn =
            'https://3b05859b04544f1fa982a411db5f1991@sentry.antoineraulin.com/2'
        ..release = appVersion
        ..environment = 'prod',
      appRunner: () => runApp(
        // EasyLocalization(
        //   supportedLocales: [
        //     Locale('fr'),
        //     Locale('en'),
        //     Locale('de'),
        //   ],
        //   path: 'assets/translations', // <-- change patch to your
        //   fallbackLocale: Locale('fr'),
        //   child: BetterFeedback(
        //       // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
        //       child: Phoenix(
        //         // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
        //         child: MyApp(),
        //       ),
        //       onFeedback: betterFeedbackOnFeedback),
        // ),
        BetterFeedback(
            // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
            child: Phoenix(
              // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
              child: MyApp(),
            ),
            onFeedback: betterFeedbackOnFeedback),
      ),
    );
  } else {
    runApp(
      // EasyLocalization(
      //   supportedLocales: [
      //     Locale('fr'),
      //     Locale('en'),
      //     Locale('de'),
      //   ],
      //   path: 'assets/translations', // <-- change patch to your
      //   fallbackLocale: Locale('fr'),
      //   child: BetterFeedback(
      //       // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
      //       child: Phoenix(
      //         // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
      //         child: MyApp(),
      //       ),
      //       onFeedback: betterFeedbackOnFeedback),
      // ),
      BetterFeedback(
          // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
          child: Phoenix(
            // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
            child: MyApp(),
          ),
          onFeedback: betterFeedbackOnFeedback),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    globals.currentTheme.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    var setTheme = globals.prefs.getString('theme') ?? 'Système';
    if (setTheme == 'Système') {
      globals.currentTheme.setDark(brightness == Brightness.dark);
    }
  }

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    //globals.currentContext = context;
    var res = <LocalizationsDelegate<dynamic>>[
      RefreshLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      SfGlobalLocalizations.delegate,
    ];
    //res.addAll(context.localizationDelegates);

    return GetMaterialApp(
      translations: DevinciTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en'),
      navigatorKey: navigatorKey,
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
      localizationsDelegates: res,
      // supportedLocales: context.supportedLocales,
      // locale: context.locale,
      title: 'Devinci',
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
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      themeMode: globals.currentTheme.currentTheme(),
      home: LoginPage(title: 'Devinci', key: globals.loginPageKey),
      debugShowCheckedModeBanner: false,
    );
  }
}
