import 'dart:async';
import 'package:devinci/pages/ui/login.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:one_context/one_context.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:wiredash/wiredash.dart';

import 'config.dart';
import 'extra/classes.dart';
import 'libraries/feedback/src/better_feedback.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //init donation processor
  await Purchases.setDebugLogsEnabled(true);

  //Remove this method to stop OneSignal Debugging
  globals.prefs = await SharedPreferences.getInstance();
  await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  globals.notifConsent = globals.prefs.getBool('notifConsent') ?? false;
  await OneSignal.shared.setRequiresUserPrivacyConsent(!globals.notifConsent);
  await OneSignal.shared.init('0a91d723-8929-46ec-9ce7-5e72c59708e5',
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false
      });
  await OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  //init quick_actions
  var defaultTheme = ThemeType.Light;
  var setTheme = globals.prefs.getString('theme') ?? 'system';
  if (setTheme != 'system') {
    defaultTheme = DevinciTheme.getThemeTypeFromString(setTheme);
  } else {
    defaultTheme =
        SchedulerBinding.instance.window.platformBrightness == Brightness.dark
            ? ThemeType.Dark
            : ThemeType.Light;
  }
  var packageInfo = await PackageInfo.fromPlatform();
  globals.release = 'devinci@' + packageInfo.version;
  globals.release += '+' + packageInfo.buildNumber;
  globals.crashConsent = globals.prefs.getString('crashConsent') ??
      'true'; //default to true to catch errors between now and the gdpr popup
  print('clearing logs');
  await FLog.clearLogs();
  if (globals.crashConsent == 'true') {
    await SentryFlutter.init(
      (options) => options
        ..dsn =
            'https://3b05859b04544f1fa982a411db5f1991@sentry.antoineraulin.com/2'
        ..release = globals.release
        ..beforeSend = beforeSend
        ..environment = 'prod',
      appRunner: () => runApp(
        EasyLocalization(
          supportedLocales: [
            Locale('fr'),
            Locale('en'),
            Locale('de'),
          ],
          path: 'assets/translations', // <-- change patch to your
          fallbackLocale: Locale('fr'),
          child: BetterFeedback(
              // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
              child: Phoenix(
                // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
                child: CustomTheme(
                  initialThemeType: defaultTheme,
                  child: MyApp(),
                ),
              ),
              onFeedback: betterFeedbackOnFeedback),
        ),
      ),
    );
  } else {
    runApp(
      EasyLocalization(
        supportedLocales: [
          Locale('fr'),
          Locale('en'),
          Locale('de'),
        ],
        path: 'assets/translations', // <-- change patch to your
        fallbackLocale: Locale('fr'),
        child: BetterFeedback(
            // BetterFeedback est une librairie qui permet d'envoyer un feedback avec une capture d'écran de l'app, c'est pourquoi on lance l'app dans BetterFeedback pour qu'il puisse se lancer par dessus et prendre la capture d'écran.
            child: Phoenix(
              // Phoenix permet de redémarrer l'app sans vraiment en sortir, c'est utile si l'utilisateur se déconnecte afin de lui représenter la page de connexion.
              child: CustomTheme(
                initialThemeType: defaultTheme,
                child: MyApp(),
              ),
            ),
            onFeedback: betterFeedbackOnFeedback),
      ),
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
    // Provider.of<DevinciTheme>(context).addListener(() {
    //   if (mounted) setState(() {});
    // });
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
      // Provider.of<DevinciTheme>(context).setTheme(
      //     brightness == Brightness.dark ? ThemeType.Dark : ThemeType.Light);
      //Provider.of<DevinciTheme>(context).setDark(brightness == Brightness.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    var res = <LocalizationsDelegate<dynamic>>[
      RefreshLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      SfGlobalLocalizations.delegate,
    ];
    res.addAll(context.localizationDelegates);

    return Wiredash(
      projectId: 'devinci-q5z3r2m',
      secret: Config.wiredash_key,
      navigatorKey: OneContext().key,
      child: MaterialApp(
        navigatorKey: OneContext().key,
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
        localizationsDelegates: res,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Devinci',
        theme: CustomTheme.of(context),
        builder: OneContext().builder,
        home: LoginPage(title: 'Devinci', key: globals.loginPageKey),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
