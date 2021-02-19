import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:devinci/extra/classes.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart' as material;
import 'package:html/parser.dart' show parse;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sentry/sentry.dart';

import 'api.dart';

class Student {
  //constructor
  Student(String username, String password) {
    this.username = username;
    this.password = password;
  }

  //values
  String username;
  String password;

  bool error = false;
  int code = 200;

  Map<String, String> tokens = {
    'SimpleSAML': '',
    'alv': '',
    'uids': '',
    'SimpleSAMLAuthToken': '',
  };

  void reset() async {
    tokens['SimpleSAML'] = '';
    tokens['alv'] = '';
    tokens['SimpleSAMLAuthToken'] = '';
    await globals.storage.deleteAll();
  }

  Map<String, String> data = {
    'badge': '',
    'client': '',
    'idAdmin': '',
    'ine': '',
    'edtUrl': '',
    'name': '',
    'ecole': '',
  };

  Map<String, dynamic> absences = {
    'nT': 0,
    's1': 0,
    's2': 0,
    'seances': 0,
    'liste': [],
    'done': false
  };

  List<dynamic> notes = [
    // {
    //   "name": "", //ESILV A1
    //   "s":[
    //     [], //S1
    //     []  //S2
    //   ]
    // }
  ];
  List<List<String>> notesList = [];
  double bonus = 0.0;
  List<String> years = [];

  bool notesFetched = false;

  var promotion = {};

  List<Map<String, dynamic>> presence = [
    // {
    //   'type': 'none', //5 types : ongoing / done / notOpen / none / closed
    //   'title': '',
    //   'horaires': '',
    //   'prof': '',
    //   'seance_pk': '',
    //   'zoom': '',
    //   'zoom_pwd': '',
    // }
  ];

  int presenceIndex = 0;

  Map<String, dynamic> documents = {
    'certificat': {
      'annee': '',
      'fr_url': '',
      'en_url': '',
    },
    'imaginr': {
      'annee': '',
      'url': '',
    },
    'calendrier': {
      'annee': '',
      'url': '',
    },
    'bulletins': []
  };

  List<Salle> salles = [];
  List<String> sallesStr = [];

  Map<String, dynamic> notesConfig = {
    //note : cette config est téléchargée depuis github a chaque démarrage de l'app pour s'assurer que les notes soient toujours bien parsé, cette map doit donc etre la plus petite possible pour ne pas impacter le chargement de l'app. Actuellement le json associé à cette map fait 751 Bytes
    'mainDivs': '#main > div > div',
    'modules': {
      'ols':
          'div > div > div.social-box.social-bordered > div > div > div.dd > ol',
      'olsBis': 'li',
      'item': {
        'm': 2,
        'mR': r'\s\s+',
        'eI': 5,
        'eStr': 'Vous devez compléter toutes les évaluations',
        '!e': {
          'moy': {
            'i': 6,
            'r': r'\s\s+',
            's': '/',
            'si': 0,
          },
          'nf': {
            'r': r': (.*?)"',
            'i': 7,
            '+': '"',
          },
          'moyP': {
            'r': r': (.*?)"',
            'i': 9,
            '+': '"',
          },
        },
      },
    },
    'matieres': {
      'mi': 2,
      'mr': r'\s\s+',
      'ei': 3,
      'eStr': 'Evaluer',
      '!e': {
        'moy': {
          'i': 6,
          'r': r'\s\s+',
          's': '/',
          'si': 0,
        },
        'ri': 9,
        'rStr': 'Rattrapage',
        '!r': {
          'moyP': {
            'r': r': (.*?)"',
            'i': 10,
            '+': '"',
          },
        },
        'r': {
          'noteR': {
            'r': r': (.*?)"',
            'i': 9,
            '+': '"',
          },
          'moyP': {
            'r': r': (.*?)"',
            'i': 11,
            '+': '"',
          },
        },
      },
    },
    'notes': {
      'n': {
        'i': 2,
        'r': r'\s\s+',
      },
      'tl': 7,
      'note': {
        'i': 6,
        'r': r'\s\s+',
        's': '/',
        'si': 0,
      },
      'nP': {
        'r': r': (.*?)"',
        'i': 10,
        '+': '"',
      }
    },
  };

  Future<void> init() async {
    //fetch notesConfig
    try {
      var client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      var req = await client.getUrl(
        Uri.parse(
          'https://devinci.raulin.tech/nc.json',
        ),
      );
      var res = await req.close();
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        notesConfig = json.decode(body);
      }
    } catch (exception, stacktrace) {
      FLog.logThis(
          className: 'Student',
          methodName: 'init',
          text: 'error while retrieving notesConfig from GitHub',
          type: LogLevel.ERROR,
          exception: Exception(exception),
          stacktrace: stacktrace);
    }
    //init sembast db
    var directory = await getApplicationDocumentsDirectory();

    final path = directory.path;

    // File path to a file in the current directory
    var dbPath = path + '/data/data.db';
    var dbFactory = databaseFactoryIo;
// We use the database factory to open the database
    globals.db = await dbFactory.openDatabase(dbPath);
    var notes =
        await globals.store.record('notes').get(globals.db) as List<dynamic>;

    if (notes == null) {
      notes = [];
      await globals.store.record('notes').put(globals.db, notes);
    }
    FLog.info(className: 'Student', methodName: 'init', text: 'h2');
    //l('h2');
    this.notes = cloneList(notes);
    //retrieve tokens from secure storage (if they exist)
    tokens['SimpleSAML'] = await globals.storage.read(key: 'SimpleSAML') ??
        ''; //try to get token SimpleSAML from secure storage, if secure storage send back null (because the token does't exist yet) '??' means : if null, so if the token doesn't exist replace null by an empty string.
    tokens['alv'] = await globals.storage.read(key: 'alv') ?? '';
    tokens['uids'] = await globals.storage.read(key: 'uids') ?? '';
    tokens['SimpleSAMLAuthToken'] =
        await globals.storage.read(key: 'SimpleSAMLAuthToken') ?? '';

    //retrieve data from secure storage
    FLog.info(className: 'Student', methodName: 'init', text: 'h3');
    //l('h3');
    globals.notifConsent = globals.prefs.getBool('notifConsent') ?? false;
    await OneSignal.shared.consentGranted(globals.notifConsent);
    if (globals.notifConsent) {
      await OneSignal.shared
          .promptUserForPushNotificationPermission(fallbackToSettings: true);
    }
    globals.showSidePanel = globals.prefs.getBool('showSidePanel') ?? false;
    globals.crashConsent = globals.prefs.getString('crashConsent') ?? 'true';
    globals.analyticsConsent =
        globals.prefs.getBool('analyticsConsent') ?? false;
    var calendarViewDay = globals.prefs.getBool('calendarViewDay') ?? true;
    globals.calendarView =
        calendarViewDay ? CalendarView.day : CalendarView.workWeek;
    data['badge'] = await globals.storage.read(key: 'badge') ?? '';
    data['client'] = await globals.storage.read(key: 'client') ?? '';
    data['idAdmin'] = await globals.storage.read(key: 'idAdmin') ?? '';
    data['ine'] = await globals.storage.read(key: 'ine') ?? '';
    data['edtUrl'] = await globals.storage.read(key: 'edtUrl') ?? '';
    FLog.info(className: 'Student', methodName: 'init', text: 'h5');
    //l('h5');
    if (data['edtUrl'] != '') {
      await setICal(data['edtUrl']);
    }
    data['name'] = await globals.storage.read(key: 'name') ?? '';
    if (globals.isConnected) {
      try {
        FLog.info(
            className: 'Student', methodName: 'init', text: 'test tokens');
        //l('test tokens');
        await testTokens().timeout(Duration(seconds: 8), onTimeout: () {
          globals.isConnected = false;
        }).catchError((exception, stacktrace) async {
          FLog.logThis(
              className: 'Student',
              methodName: 'init',
              text: 'test tokens exception',
              type: LogLevel.ERROR,
              exception: Exception(exception),
              stacktrace: stacktrace);
          //l('test tokens exception : $exception');
          //testTokens throw an exception if tokens don't exist or if they aren't valid
          //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
          try {
            await getTokens();
          } catch (exception, stacktrace) {
            FLog.logThis(
                className: 'Student',
                methodName: 'init',
                text: 'get tokens exception',
                type: LogLevel.ERROR,
                exception: Exception(exception),
                stacktrace: stacktrace);
            //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
            if (code == 500) {
              //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

            } else if (code == 401) {
              await globals.storage
                  .deleteAll(); //remove all sensitive data from the phone if the user can't connect
              //the exception was thrown because credentials are wrong
              throw Exception(
                  'wrong credentials : $exception'); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
            } else {
              throw Exception(exception); //we don't know what happened here
            }
          }
        }); //test if tokens exist and if so, test if they are still valid
      } catch (exception, stacktrace) {
        FLog.logThis(
            className: 'Student',
            methodName: 'init',
            text: 'test tokens exception',
            type: LogLevel.ERROR,
            exception: Exception(exception),
            stacktrace: stacktrace);
        //l('test tokens exception : $exception');

        //testTokens throw an exception if tokens don't exist or if they aren't valid
        //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
        try {
          await getTokens();
        } catch (exception, stacktrace) {
          FLog.logThis(
              className: 'Student',
              methodName: 'init',
              text: 'get tokens exception',
              type: LogLevel.ERROR,
              exception: Exception(exception),
              stacktrace: stacktrace);
          //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
          if (code == 500) {
            //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

          } else if (code == 401) {
            await globals.storage
                .deleteAll(); //remove all sensitive data from the phone if the user can't connect
            //the exception was thrown because credentials are wrong
            throw Exception(
                'wrong credentials : $exception'); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
          } else {
            throw Exception(exception); //we don't know what happened here
          }
        }
      }
      //if we manage to arrive here it means that we have valid tokens and that credentials are good
      await globals.storage.write(
          key: 'username',
          value:
              username); //save credentials in secure storage if user specified "remember me"
      await globals.storage.write(key: 'password', value: password);
      FLog.info(
          className: 'Student',
          methodName: 'init',
          text: 'edt : ' + globals.user.data['edtUrl']);
      //l('edt : ' + globals.user.data['edtUrl']);
      if (globals.user.data['ecole'] == '' ||
          globals.user.data['edtUrl'] == '') {
        //edtUrl being the last information we retrieve from the getData() function, if it doesn't exist it means that the getData() function didn't work or was never run and must be run at least once.
        try {
          FLog.info(
              className: 'Student', methodName: 'init', text: "let's go try");
          //l("let's go try");
          await globals.user.getData();
        } catch (exception, stacktrace) {
          FLog.logThis(
              className: 'Student',
              methodName: 'init',
              text: 'getData exception',
              type: LogLevel.ERROR,
              exception: Exception(exception),
              stacktrace: stacktrace);
          //l(exception);
        }
      }
    }
    await Purchases.setup('abVHNSbIPgVJOcqxFbCKdUdxTLPzcagC',
        appUserId: tokens['uids']);
    if (globals.notifConsent) {
      try {
        var sub = await OneSignal.shared.getPermissionSubscriptionState();
        var sub2 = sub.subscriptionStatus;
        var id = sub2.userId;
        Sentry.configureScope(
          (scope) {
            scope.setTag('app.language', 'locale'.tr());
            scope.user =
                User(email: username, username: tokens['uids'], id: id);
          },
        );
      } catch (e) {
        Sentry.configureScope(
          (scope) {
            scope.setTag('app.language', 'locale'.tr());
            scope.user = User(email: username, id: tokens['uids']);
          },
        );
      }
    }
    DevinciApi().register();
    FLog.info(className: 'Student', methodName: 'init', text: 'done init');
    //l('done init');
    return;
  }

  Future<void> getTokens() async {
    var client = HttpClient();

    if (username != '' && password != '') {
      var req = await client.getUrl(
        Uri.parse('https://www.leonard-de-vinci.net/'),
      );
      var res = await req.close();
      FLog.info(
          className: 'Student',
          methodName: 'getTokens',
          text: 'statusCode : ${res.statusCode}');
      //l('statusCode : ${res.statusCode}');
      FLog.info(
          className: 'Student',
          methodName: 'getTokens',
          text: 'headers : ${res.headers}');
      //l('headers : ${res.headers}');
      FLog.info(
          className: 'Student',
          methodName: 'getTokens',
          text:
              'STEP 1 : HEADERS - SET-COOKIE : ${res.headers.value("set-cookie")}');
      //l('STEP 1 : HEADERS - SET-COOKIE : ${res.headers.value("set-cookie")}');
      var regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
      tokens['alv'] = regExp
          .firstMatch(
            res.headers.value('set-cookie'),
          )
          .group(2);
      FLog.info(
          className: 'Student',
          methodName: 'getTokens',
          text: 'ALV : "${tokens['alv']}"');
      //l('ALV : "${tokens['alv']}"');
      if (res.statusCode == 200) {
        req = await client.postUrl(
            Uri.parse('https://www.leonard-de-vinci.net/ajax.inc.php'));
        req.headers.set(
            'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
        req.headers.set('Cookie', 'alv=${tokens["alv"]}');
        req.write('act=ident_analyse&login=' + Uri.encodeComponent(username));
        FLog.info(
            className: 'Student',
            methodName: 'getTokens',
            text: '[STEP 2] REQ HEADERS : ${req.headers}');
        //l('[STEP 2] REQ HEADERS : ${req.headers}');
        res = await req.close();
        FLog.info(
            className: 'Student',
            methodName: 'getTokens',
            text: '[STEP 2] statusCode : ${res.statusCode}');
        //l('[STEP 2] statusCode : ${res.statusCode}');
        FLog.info(
            className: 'Student',
            methodName: 'getTokens',
            text: '[STEP 2] RES headers : ${res.headers}');
        //l('[STEP 2] RES headers : ${res.headers}');
        var body = await res.transform(utf8.decoder).join();
        FLog.info(
            className: 'Student',
            methodName: 'getTokens',
            text: '[STEP 2] BODY : $body');
        //l('[STEP 2] BODY : $body');
        if (body.contains('location')) {
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: 'username correct');
          //l('username correct');

          req = await client.getUrl(
            Uri.parse(
                'https://www.leonard-de-vinci.net/login.sso.php?username=' +
                    Uri.encodeComponent(username)),
          );
          req.followRedirects = false;
          req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
          req.headers.set('Cookie', 'alv=${tokens["alv"]}');
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 3] REQ HEADERS : ${req.headers}');
          //l('[STEP 3] REQ HEADERS : ${req.headers}');
          res = await req.close();
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 3] statusCode : ${res.statusCode}');
          //l('[STEP 3] statusCode : ${res.statusCode}');
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 3] RES headers : ${res.headers}');
          //l('[STEP 3] RES headers : ${res.headers}');
          tokens['SimpleSAML'] = regExp
              .firstMatch(
                res.headers.value('set-cookie'),
              )
              .group(2);
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: 'SimpleSAML : "${tokens['SimpleSAML']}"');
          //l('SimpleSAML : "${tokens['SimpleSAML']}"');

          var redUrl = res.headers.value('location');

          req = await client.getUrl(
            Uri.parse(redUrl),
          );
          res = await req.close();
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 4] statusCode : ${res.statusCode}');
          //l('[STEP 4] statusCode : ${res.statusCode}');
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 4] statusCode : ${res.statusCode}');
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 4] RES headers : ${res.headers}');
          body = await res.transform(utf8.decoder).join();
          //l('[STEP 4] BODY : $body');
          regExp = RegExp(r'action="\/adfs(.*?)"');
          var url =
              'https://adfs.devinci.fr/adfs' + regExp.firstMatch(body).group(1);
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 4] url : $url');

          req = await client.postUrl(
            Uri.parse(url),
          );

          req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
          req.write('UserName=' +
              Uri.encodeComponent(username) +
              '&Password=' +
              Uri.encodeComponent(password) +
              '&AuthMethod=FormsAuthentication');
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 5] REQ HEADERS : ${req.headers}');
          res = await req.close();
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 5] statusCode : ${res.statusCode}');
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: '[STEP 5] RES headers : ${res.headers}');

          if (res.headers.value('set-cookie') != null &&
              res.statusCode == 302) {
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: 'connected');
            regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
            // ignore: non_constant_identifier_names
            var MSISAuth = regExp
                .firstMatch(
                  res.headers.value('set-cookie'),
                )
                .group(2);
            redUrl = res.headers.value('location');

            req = await client.getUrl(
              Uri.parse(redUrl),
            );
            req.headers.set('Cookie', 'MSISAuth=' + MSISAuth);
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: '[STEP 6] REQ HEADERS : ${req.headers}');
            res = await req.close();
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: '[STEP 6] statusCode : ${res.statusCode}');
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: '[STEP 6] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            regExp = RegExp(r'value="(.*?)"');
            var value = regExp.firstMatch(body).group(1);

            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: 'value : $value');
            req = await client.postUrl(
              Uri.parse(
                  'https://www.leonard-de-vinci.net/include/SAML/module.php/saml/sp/saml2-acs.php/devinci-sp'),
            );
            req.headers
                .set('Content-Type', 'application/x-www-form-urlencoded');
            req.headers.set('Cookie',
                "alv=${tokens["alv"]}; SimpleSAML=${tokens["SimpleSAML"]}");
            req.followRedirects = false;
            var b = 'SAMLResponse=' +
                Uri.encodeComponent(value) +
                '&RelayState=https://www.leonard-de-vinci.net/login.sso.php';
            req.write(b);
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: '[STEP 7] REQ HEADERS : ${req.headers}');
            res = await req.close();
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: '[STEP 7] statusCode : ${res.statusCode}');
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: '[STEP 7] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            FLog.info(
                className: 'Student',
                methodName: 'getTokens',
                text: "set-cookie : ${res.headers['set-cookie']}");
            if (res.statusCode == 303) {
              redUrl = res.headers.value('location');
              regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
              tokens['SimpleSAMLAuthToken'] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][1],
                  )
                  .group(2);
              FLog.info(
                  className: 'Student',
                  methodName: 'getTokens',
                  text:
                      'SimpleSAMLAuthToken : "${tokens["SimpleSAMLAuthToken"]}"');

              req = await client.getUrl(
                Uri.parse(redUrl),
              );
              req.followRedirects = false;
              req.headers.set(
                  'Cookie',
                  'alv=' +
                      tokens['alv'] +
                      '; SimpleSAML=' +
                      tokens['SimpleSAML'] +
                      '; SimpleSAMLAuthToken=' +
                      tokens['SimpleSAMLAuthToken']);
              FLog.info(
                  className: 'Student',
                  methodName: 'getTokens',
                  text: '[STEP 8] REQ HEADERS : ${req.headers}');
              res = await req.close();
              FLog.info(
                  className: 'Student',
                  methodName: 'getTokens',
                  text: '[STEP 8] statusCode : ${res.statusCode}');
              FLog.info(
                  className: 'Student',
                  methodName: 'getTokens',
                  text: '[STEP 8] RES headers : ${res.headers}');
              //body = await res.transform(utf8.decoder).join();
              tokens['uids'] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][2],
                  )
                  .group(2);
              FLog.info(
                  className: 'Student',
                  methodName: 'getTokens',
                  text: 'uids : "${tokens["uids"]}"');
              await globals.storage.write(
                key: 'SimpleSAML',
                value: tokens['SimpleSAML'],
              );
              await globals.storage.write(
                key: 'alv',
                value: tokens['alv'],
              );
              await globals.storage.write(
                key: 'SimpleSAMLAuthToken',
                value: tokens['SimpleSAMLAuthToken'],
              );
              await globals.storage.write(
                key: 'uids',
                value: tokens['uids'],
              );
              error = false;
              code = 200;
            } else {
              error = true;
              code = res.statusCode;
              throw Exception({
                'code': code,
                'message': 'unhandled exception, ' + res.reasonPhrase
              });
            }
          } else {
            error = true;
            code = 401;
            throw Exception('wrong credentials');
          }
        } else {
          FLog.info(
              className: 'Student',
              methodName: 'getTokens',
              text: 'username incorrect');
          error = true;
          code = 401;
          throw Exception('wrong credentials');
        }
      } else {
        error = true;
        code = res.statusCode;
        throw Exception('Error while retrieving alv token');
      }
    } else {
      error = true;
      code = 400;
      throw Exception('missing parameters');
    }
    return;
  }

  Future<void> testTokens() async {
    var response = await devinciRequest();
    if (response != null) {
      FLog.info(
          className: 'Student',
          methodName: 'testTokens',
          text: 'statusCode : ${response.statusCode}');
      FLog.info(
          className: 'Student',
          methodName: 'testTokens',
          text: 'headers : ${response.headers}');
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        FLog.info(className: 'Student', methodName: 'testTokens', text: body);
        if (body.contains("('#password').hide();")) {
          FLog.info(
              className: 'Student', methodName: 'testTokens', text: 'error');
          throw Exception('wrong tokens');
        } else {
          error = false;
          code = 200;
        }
      } else {
        throw Exception('wrong tokens -> statuscode : ${response.statusCode}');
      }
    } else {
      error = true;
      code = 400;
      throw Exception('missing tokens or user as error');
    }
    return;
  }

  Future<void> getData() async {
    FLog.info(className: 'Student', methodName: 'getData', text: 'getData');
    var response = await devinciRequest(
        replacementUrl: 'https://www.leonard-de-vinci.net/', log: true);
    FLog.info(
        className: 'Student', methodName: 'getData', text: response.toString());
    if (response != null) {
      FLog.info(
          className: 'Student',
          methodName: 'getData',
          text: 'statusCode : ${response.statusCode}');
      FLog.info(
          className: 'Student',
          methodName: 'getData',
          text: 'headers : ${response.headers}');
      var body = await response.transform(utf8.decoder).join();
      FLog.info(className: 'Student', methodName: 'getData', text: 'get Data');
      if (response.statusCode == 200) {
        FLog.info(className: 'Student', methodName: 'getData', text: body);

        var doc = parse(body);
        FLog.info(
            className: 'Student', methodName: 'getData', text: doc.outerHtml);
        var ns = doc.querySelectorAll('#main > div > .row-fluid');
        var n = ns[ns.length - 1].querySelector(
            'div.social-box.social-blue.social-bordered > header > h4');
        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: 'n : "${n.innerHtml}"');
        var regExp = RegExp(r': (.*?)\t');
        data['name'] = regExp.firstMatch(n.text).group(1);
        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: "name : '${data["name"]}'");

        var ds = ns[ns.length - 1].querySelectorAll(
            'div.social-box.social-blue.social-bordered > div > div');
        FLog.info(
            className: 'Student', methodName: 'getData', text: ds.toString());
        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: 'ds 0 : ' + ds[0].innerHtml);
        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: 'ds 1 : ' + ds[1].innerHtml);
        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: 'ds 2 : ' + ds[2].innerHtml);
        String d;
        var french = true;
        if (doc
            .querySelectorAll('.dropdown-toggle')[1]
            .querySelector('img')
            .attributes['src']
            .contains('en.png')) {
          french = false;
        }
        try {
          if (ds[1].innerHtml.contains(french ? 'Identifiant' : 'User ID')) {
            FLog.info(
                className: 'Student',
                methodName: 'getData',
                text: 'ds1 choosen');
            FLog.info(
                className: 'Student',
                methodName: 'getData',
                text: ds[1].querySelector('div').toString());
            d = ds[1]
                .querySelector('div > div > div.span4 > div > div > address')
                .text;
            FLog.info(
                className: 'Student', methodName: 'getData', text: 'd : $d');
          } else if (ds[2]
              .innerHtml
              .contains(french ? 'Identifiant' : 'User ID')) {
            d = ds[2]
                .querySelector('div > div > div.span4 > div > div > address')
                .text;
            FLog.info(
                className: 'Student', methodName: 'getData', text: 'd : $d');
          } else {
            d = ds[3]
                .querySelector('div > div > div.span4 > div > div > address')
                .text;
            FLog.info(
                className: 'Student', methodName: 'getData', text: 'd : $d');
          }
          //detect language of the portail
          if (globals.crashConsent == 'true') {
            try {
              Sentry.configureScope(
                (scope) =>
                    scope.setTag('portail.language', french ? 'fr' : 'en'),
              );
            } catch (e, stacktrace) {
              FLog.logThis(
                  className: 'Student',
                  methodName: 'getData',
                  text: 'Sentry.configureScope exception',
                  type: LogLevel.ERROR,
                  exception: Exception(e),
                  stacktrace: stacktrace);
            }
          }

          if (french) {
            data['badge'] = RegExp(r'badge : (.*?)\n').firstMatch(d).group(1);
            try {
              data['client'] = RegExp(r'client (.*?)\n').firstMatch(d).group(1);

              data['idAdmin'] =
                  RegExp(r'Administratif (.*?)\n').firstMatch(d).group(1);
            } catch (e, stacktrace) {
              FLog.logThis(
                  className: 'Student',
                  methodName: 'getData',
                  text: 'exception',
                  type: LogLevel.SEVERE,
                  exception: Exception(e),
                  stacktrace: stacktrace);
            }
          } else {
            data['badge'] =
                RegExp(r'Badge Number : (.*?)\n').firstMatch(d).group(1);
            data['client'] =
                RegExp(r'Customer number (.*?)\n').firstMatch(d).group(1);
            data['idAdmin'] =
                RegExp(r'Administrative ID (.*?)\n').firstMatch(d).group(1);
          }
          data['ine'] = RegExp(r'INE/BEA : (.*?)\n').firstMatch(d).group(1);
          FLog.info(
              className: 'Student',
              methodName: 'getData',
              text:
                  "data : ${data["badge"]}|${data["client"]}|${data["idAdmin"]}|${data["ine"]}");
        } catch (e, stacktrace) {
          FLog.logThis(
              className: 'Student',
              methodName: 'getData',
              text: 'exception',
              type: LogLevel.SEVERE,
              exception: Exception(e),
              stacktrace: stacktrace);
          await reportError(e, stacktrace);
        }
        response = await devinciRequest(endpoint: '?my=edt');

        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: 'statusCode : ${response.statusCode}');
        FLog.info(
            className: 'Student',
            methodName: 'getData',
            text: 'headers : ${response.headers}');
        body = await response.transform(utf8.decoder).join();
        if (response.statusCode == 200) {
          data['edtUrl'] = 'https://ical.devinci.me/' +
              RegExp(r'ical.devinci.me\/(.*?)"').firstMatch(body).group(1);
          FLog.info(
              className: 'Student',
              methodName: 'getData',
              text: "ical url : ${data["edtUrl"]}");
          await globals.storage.write(
            key: 'badge',
            value: data['badge'],
          );
          await globals.storage.write(
            key: 'client',
            value: data['client'],
          );
          await globals.storage.write(
            key: 'idAdmin',
            value: data['idAdmin'],
          );
          await globals.storage.write(
            key: 'ine',
            value: data['ine'],
          );
          await globals.storage.write(
            key: 'edtUrl',
            value: data['edtUrl'],
          );
          await globals.storage.write(
            key: 'name',
            value: data['name'],
          );
        } else {
          error = true;
          code = response.statusCode;
          throw Exception({
            'code': code,
            'message': 'unhandled exception, ' + response.reasonPhrase
          });
        }
      } else {
        error = true;
        code = response.statusCode;
        throw Exception({
          'code': code,
          'message': 'unhandled exception, ' + response.reasonPhrase
        });
      }
    } else {
      error = true;
      code = 400;
      throw Exception('missing parameters');
    }
    return;
  }

  Future<void> getAbsences() async {
    if (globals.isConnected) {
      var res = await devinciRequest(
        endpoint: '?my=abs',
      );
      if (res != null) {
        if (res.statusCode == 200) {
          FLog.info(
              className: 'Student',
              methodName: 'getAbsences',
              text: 'got absences');
          var body = await res.transform(utf8.decoder).join();
          if (!body.contains('Validation des règlements')) {
            var doc = parse(body);
            FLog.info(
                className: 'Student',
                methodName: 'getAbsences',
                text: doc.outerHtml);
            var spans = doc.querySelectorAll('.tab-pane > header > span');
            var nTB = doc
                .querySelector('.tab-pane > header > span.label.label-warning');
            FLog.info(
                className: 'Student',
                methodName: 'getAbsences',
                text: nTB.toString());
            var nTM = RegExp(r': (.*?)"').firstMatch(nTB.text + '"').group(1);
            absences['nT'] = int.parse(nTM);

            var s1M =
                RegExp(r': (.*?)"').firstMatch(spans[0].text + '"').group(1);
            absences['s1'] = int.parse(s1M);

            var s2B = doc
                .querySelector('.tab-pane > header > span.label.label-success');
            var s2M = RegExp(r': (.*?)"').firstMatch(s2B.text + '"').group(1);
            absences['s2'] = int.parse(s2M);

            var seanceM = RegExp(r'"(.*?) séance')
                .firstMatch('"' + spans[3].text)
                .group(1);
            absences['seances'] = int.parse(seanceM);
            var trs =
                doc.querySelectorAll('.tab-pane.active > table > tbody > tr');
            absences['liste'].clear();
            trs.forEach((tr) {
              var elem = <String, String>{
                'cours': '',
                'type': '',
                'jour': '',
                'creneau': '',
                'duree': '',
                'modalite': ''
              };

              var tds = tr.querySelectorAll('td');
              elem['cours'] = tds[1]
                  .text
                  .replaceAll(tds[1].querySelector('span').text, '')
                  .replaceAllMapped(RegExp(r'\s\s+'), (match) => '');
              elem['type'] =
                  tds[2].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => '');
              elem['jour'] =
                  tds[3].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => '');
              elem['creneau'] =
                  tds[4].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => '');
              elem['duree'] =
                  tds[5].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => '');
              elem['modalite'] =
                  tds[6].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => '');
              absences['liste'].add(elem);
            });
            FLog.info(
                className: 'Student',
                methodName: 'getAbsences',
                text: absences['liste'].toString());
          } else if (body.contains('Validation des règlements')) {
            final snackBar = material.SnackBar(
              content: material.Text('school_rules_validation').tr(),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            await showSnackBar(snackBar);
          }
          absences['done'] = true;
          await globals.store.record('absences').put(globals.db, absences);
        } else {
          error = true;
          code = res.statusCode;
          throw Exception({
            'code': code,
            'message': 'unhandled exception, ' + res.reasonPhrase
          });
        }
      } else {
        error = true;
        code = 400;

        throw Exception('missing parameters => ' +
            tokens['SimpleSAML'] +
            ' | ' +
            tokens['alv'] +
            ' | ' +
            tokens['SimpleSAMLAuthToken'] +
            ' | ' +
            tokens['uids'] +
            ' | ' +
            error.toString());
      }
    } else {
      absences = await globals.store.record('absences').get(globals.db) as Map;
    }

    return;
  }

  Future<void> getBonus(String p) async {
    if (globals.isConnected) {
      var res = await devinciRequest(
          endpoint: 'student/upload.php',
          method: 'POST',
          headers: [
            ['Connection', 'keep-alive'],
            ['Accept', '*/*'],
            ['DNT', '1'],
            ['X-Requested-With', 'XMLHttpRequest'],
            [
              'User-Agent',
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36 Edg/81.0.416.64'
            ],
            [
              'Content-Type',
              'application/x-www-form-urlencoded; charset=UTF-8'
            ],
            ['Origin', 'https://www.leonard-de-vinci.net'],
            ['Sec-Fetch-Site', 'same-origin'],
            ['Sec-Fetch-Mode', 'cors'],
            ['Sec-Fetch-Dest', 'empty'],
            ['Referer', 'https://www.leonard-de-vinci.net/?my=notes&p=' + p],
            ['Pragma', 'no-cache'],
            ['Cache-Control', 'no-cache'],
            [
              'Accept-Language',
              'fr,fr-FR;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6'
            ],
          ],
          data: 'act=bonus_tab&programme_pk=' + p);
      if (res != null) {
        var body = await res.transform(utf8.decoder).join();
        if (!body.contains('Validation des règlements')) {
          var doc = parse(body);
          bonus =
              double.parse(doc.querySelector('.text-info').text.split(': ')[1]);
        }
      } else {
        throw Exception({'code': 400, 'message': 'missing parameters'});
      }
    } else {
      throw HttpException({
        'code': 503,
        'message': 'service unavailable, globals.isConnected == false'
      }.toString()); //service unavailable
    }
    return;
  }

  Future<void> getNotesList() async {
    var res = await devinciRequest(endpoint: '?my=notes');
    if (res != null) {
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        if (!body.contains('Validation des règlements')) {
          var doc = parse(body);
          FLog.info(
              className: 'Student', methodName: 'getNotesList', text: 'body');
          FLog.info(
              className: 'Student',
              methodName: 'getNotesList',
              text: body.contains('Notes').toString());
          var tbody = doc.querySelector('tbody');
          var trs = tbody.querySelectorAll('tr');
          notesList.clear();
          years.clear();
          for (var tr in trs) {
            notes.add({});
            var tds = tr.querySelectorAll('td');
            var name = tds[1].text;
            years.add(name);
            var link = tr.querySelector('a');
            var href = link.attributes['href'];
            var p = href.split('p=')[1];
            notesList.add([name, p]);
          }
        } else {
          final snackBar = material.SnackBar(
            content: material.Text('school_rules_validation').tr(),
            duration: const Duration(seconds: 10),
          );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
          await showSnackBar(snackBar);
        }
      } else {
        error = true;
        code = res.statusCode;
        throw Exception({
          'code': code,
          'message': 'unhandled exception, ' + res.reasonPhrase
        });
      }
    } else {
      error = true;
      code = 400;

      throw Exception('missing parameters => ' +
          tokens['SimpleSAML'] +
          ' | ' +
          tokens['alv'] +
          ' | ' +
          tokens['SimpleSAMLAuthToken'] +
          ' | ' +
          tokens['uids'] +
          ' | ' +
          error.toString());
    }
    return;
  }

  Future<void> getNotes(String p, int index) async {
    if (globals.isConnected) {
      var nn = <String, dynamic>{
        'name': 1,
        's': [
          [],
          [],
        ],
      };
      var res = await devinciRequest(endpoint: '?my=notes&p=' + p);
      if (res != null) {
        FLog.info(
            className: 'Student',
            methodName: 'getNotes',
            text: 'NOTES - STATUS CODE : ${res.statusCode}');
        if (res.statusCode == 200) {
          var body = await res.transform(utf8.decoder).join();
          if (!body.contains('Aucune note') &&
              !body.contains('Validation des règlements')) {
            var doc = parse(body);
            var headers = doc.querySelectorAll('header');
            var header = headers[headers.length - 1].text;
            nn['name'] =
                int.tryParse(RegExp(r'\d').firstMatch(header).group(0));

            var divs = doc.querySelectorAll(notesConfig['mainDivs']);
            for (var y = 0; y < 2; y++) {
              var i = 0;
              var ols1 =
                  divs[5].querySelectorAll(notesConfig['modules']['ols']);
              var ols = ols1[y]
                  .querySelector(notesConfig['modules']['olsBis'])
                  .children;
              for (var yy = 1; yy < ols.length; yy++) {
                var ol = ols[yy];
                var elem = <String, dynamic>{
                  'module': '',
                  'moy': 0.0,
                  'nf': 0.0,
                  'moyP': 0.0,
                  'matieres': []
                };
                var li = ol.querySelector('li');
                var ddhandle = ol.querySelector('div');
                var texts = ddhandle.text.split('\n');
                elem['module'] = texts[notesConfig['modules']['item']['m']]
                    .replaceAllMapped(
                        RegExp(notesConfig['modules']['item']['mR']),
                        (match) => '');

                elem['moy'] = null;
                elem['nf'] = null;
                elem['moyP'] = null;
                if (!texts[notesConfig['modules']['item']['eI']]
                    .contains(notesConfig['modules']['item']['eStr'])) {
                  try {
                    elem['moy'] = double.parse(
                        texts[notesConfig['modules']['item']['!e']['moy']['i']]
                                .replaceAllMapped(
                                    RegExp(notesConfig['modules']['item']['!e']
                                        ['moy']['r']),
                                    (match) => '')
                                .split(
                                    notesConfig['modules']['item']['!e']['moy']['s'])[
                            notesConfig['modules']['item']['!e']['moy']['si']]);
                  } catch (e, stacktrace) {
                    FLog.logThis(
                        className: 'Student',
                        methodName: 'getNotes',
                        text: 'module moy exception',
                        type: LogLevel.ERROR,
                        exception: Exception(e),
                        stacktrace: stacktrace);
                  }
                  try {
                    elem['nf'] = double.parse(
                        RegExp(notesConfig['modules']['item']['!e']['nf']['r'])
                            .firstMatch(texts[notesConfig['modules']['item']
                                    ['!e']['nf']['i']] +
                                notesConfig['modules']['item']['!e']['nf']['+'])
                            .group(1));
                  } catch (e, stacktrace) {
                    FLog.logThis(
                        className: 'Student',
                        methodName: 'getNotes',
                        text: 'module nf exception',
                        type: LogLevel.ERROR,
                        exception: Exception(e),
                        stacktrace: stacktrace);
                  }
                  try {
                    elem['moyP'] = double.parse(RegExp(
                            notesConfig['modules']['item']['!e']['moyP']['r'])
                        .firstMatch(texts[notesConfig['modules']['item']['!e']
                                ['moyP']['i']] +
                            notesConfig['modules']['item']['!e']['moyP']['+'])
                        .group(1));
                  } catch (e, stacktrace) {
                    FLog.logThis(
                        className: 'Student',
                        methodName: 'getNotes',
                        text: 'module moyP exception',
                        type: LogLevel.ERROR,
                        exception: Exception(e),
                        stacktrace: stacktrace);
                  }
                }
                nn['s'][y].add(elem);

                //nn["s${y + 1}"].add(elem);

                var ddlist = li.querySelector('ol');
                var j = 0;
                try {
                  ddlist.children.forEach((lii) {
                    ddhandle = lii.querySelector('div');
                    texts = ddhandle.text.split('\n');
                    //String prettyprint = encoder.convert(texts);
                    //l(prettyprint);
                    elem = {
                      'matiere': '',
                      'moy': 0.0,
                      'moyP': 0.0,
                      'notes': [],
                      'c': true
                    };

                    elem['matiere'] = texts[notesConfig['matieres']['mi']]
                        .replaceAllMapped(RegExp(notesConfig['matieres']['mr']),
                            (match) => '');
                    elem['moy'] = null;
                    elem['moyP'] = null;
                    if (!texts[notesConfig['matieres']['ei']]
                        .contains(notesConfig['matieres']['eStr'])) {
                      try {
                        elem['moy'] = double.parse(
                            texts[notesConfig['matieres']['!e']['moy']['i']]
                                .replaceAllMapped(
                                    RegExp(notesConfig['matieres']['!e']['moy']
                                        ['r']),
                                    (match) => '')
                                .split(notesConfig['matieres']['!e']['moy']
                                    ['s'])[notesConfig['matieres']['!e']['moy']
                                ['si']]);
                      } catch (e) {
                        try {
                          if (texts[notesConfig['matieres']['!e']['moy']['i']]
                                  .replaceAllMapped(
                                      RegExp(notesConfig['matieres']['!e']
                                          ['moy']['r']),
                                      (match) => '')
                                  .split(notesConfig['matieres']['!e']['moy']
                                      ['s'])[notesConfig['matieres']['!e']
                                  ['moy']['si']] ==
                              'Validé') {
                            elem['moy'] = 100.0;
                          }
                        } catch (e, stacktrace) {
                          FLog.logThis(
                              className: 'Student',
                              methodName: 'getNotes',
                              text: 'matiere moy exception v2',
                              type: LogLevel.ERROR,
                              exception: Exception(e),
                              stacktrace: stacktrace);
                        }
                      }
                      FLog.info(
                          className: 'Student',
                          methodName: 'getNotes',
                          text: elem['moy'].toString());
                      try {
                        if (!texts[notesConfig['matieres']['!e']['ri']]
                            .contains(notesConfig['matieres']['!e']['rStr'])) {
                          try {
                            elem['moyP'] = double.parse(RegExp(
                                    notesConfig['matieres']['!e']['!r']['moyP']
                                        ['r'])
                                .firstMatch(texts[notesConfig['matieres']['!e']
                                        ['!r']['moyP']['i']] +
                                    notesConfig['matieres']['!e']['!r']['moyP']
                                        ['+'])
                                .group(1));
                          } catch (e, stacktrace) {
                            FLog.logThis(
                                className: 'Student',
                                methodName: 'getNotes',
                                text: 'matiere moyP exception',
                                type: LogLevel.ERROR,
                                exception: Exception(e),
                                stacktrace: stacktrace);
                            elem['moyP'] = null;
                          }
                        } else {
                          var noteR = double.parse(RegExp(
                                  notesConfig['matieres']['!e']['r']['noteR']
                                      ['r'])
                              .firstMatch(texts[notesConfig['matieres']['!e']
                                      ['r']['noteR']['i']] +
                                  notesConfig['matieres']['!e']['r']['noteR']
                                      ['+'])
                              .group(1));
                          if (noteR > elem['moy']) {
                            if (noteR > 10) {
                              elem['moy'] = 10.0;
                            } else {
                              elem['moy'] = noteR;
                            }
                          }
                          var e = {
                            'nom':
                                'MESIMF120419-CC-1 Rattrapage' + 're_take'.tr(),
                            'note': noteR,
                            'noteP': null,
                            //"date": timestamp
                          };

                          elem['notes'].add(e);

                          elem['moyP'] = double.parse(RegExp(
                                  notesConfig['matieres']['!e']['r']['moyP']
                                      ['r'])
                              .firstMatch(texts[notesConfig['matieres']['!e']
                                      ['r']['moyP']['i']] +
                                  notesConfig['matieres']['!e']['r']['moyP']
                                      ['+'])
                              .group(1));
                        }
                      } catch (e, stacktrace) {
                        FLog.logThis(
                            className: 'Student',
                            methodName: 'getNotes',
                            text: 'exception',
                            type: LogLevel.ERROR,
                            exception: Exception(e),
                            stacktrace: stacktrace);
                      }
                    }
                    nn['s'][y][i]['matieres'].add(elem);
                    //nn["s${y + 1}"][i]["matieres"].add(elem);
                    ddlist = lii.querySelector('ol');
                    if (ddlist != null) {
                      ddlist.children.forEach((liii) {
                        ddhandle = liii.querySelector('div');
                        texts = ddhandle.text.split('\n');
                        elem = {
                          'nom': '',
                          'note': 0.0,
                          'noteP': 0.0,
                          //"date": timestamp
                        };
                        elem['nom'] = texts[notesConfig['notes']['n']['i']]
                            .replaceAllMapped(
                                RegExp(notesConfig['notes']['n']['r']),
                                (match) => '');
                        if (texts.length < notesConfig['notes']['tl']) {
                          elem['note'] = null;
                          elem['noteP'] = null;
                        } else {
                          var temp = texts[notesConfig['notes']['note']['i']]
                                  .replaceAllMapped(
                                      RegExp(notesConfig['notes']['note']['r']),
                                      (match) => '')
                                  .split(notesConfig['notes']['note']['s'])[
                              notesConfig['notes']['note']['si']];
                          if (temp.contains('Absence')) {
                            elem['note'] = 0.12345;
                          } else {
                            try {
                              elem['note'] = double.parse(texts[
                                      notesConfig['notes']['note']['i']]
                                  .replaceAllMapped(
                                      RegExp(notesConfig['notes']['note']['r']),
                                      (match) => '')
                                  .split(notesConfig['notes']['note']
                                      ['s'])[notesConfig['notes']['note']
                                  ['si']]);
                            } catch (e, stacktrace) {
                              FLog.logThis(
                                  className: 'Student',
                                  methodName: 'getNotes',
                                  text: 'exception',
                                  type: LogLevel.ERROR,
                                  exception: Exception(e),
                                  stacktrace: stacktrace);
                            }
                          }
                          elem['noteP'] = null;
                          try {
                            elem['noteP'] = double.parse(
                                RegExp(notesConfig['notes']['nP']['r'])
                                    .firstMatch(
                                        texts[notesConfig['notes']['nP']['i']] +
                                            notesConfig['notes']['nP']['+'])
                                    .group(1));
                          } catch (e, stacktrace) {
                            FLog.logThis(
                                className: 'Student',
                                methodName: 'getNotes',
                                text: 'exception',
                                type: LogLevel.ERROR,
                                exception: Exception(e),
                                stacktrace: stacktrace);
                          }
                        }
                        nn['s'][y][i]['matieres'][j]['notes'].add(elem);
                        //nn["s${y + 1}"][i]["matieres"][j]["notes"].add(elem);
                      });
                    }
                    j++;
                  });
                } catch (e, stacktrace) {
                  FLog.logThis(
                      className: 'Student',
                      methodName: 'getNotes',
                      text: 'error',
                      type: LogLevel.ERROR,
                      exception: Exception(e),
                      stacktrace: stacktrace);
                }
                i++;
              }
            }
          } else if (body.contains('Validation des règlements')) {
            final snackBar = material.SnackBar(
              content: material.Text('school_rules_validation').tr(),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            await showSnackBar(snackBar);
          }
        } else {
          error = true;
          code = res.statusCode;
          throw Exception({
            'code': code,
            'message': 'unhandled exception, ' + res.reasonPhrase
          });
        }
      } else {
        error = true;
        code = 400;

        throw Exception('missing parameters => ' +
            tokens['SimpleSAML'] +
            ' | ' +
            tokens['alv'] +
            ' | ' +
            tokens['SimpleSAMLAuthToken'] +
            ' | ' +
            tokens['uids'] +
            ' | ' +
            error.toString());
      }

      notes[index] = nn;
      await globals.store.record('notes').put(globals.db, notes);
      notesFetched = true;
      FLog.info(
          className: 'Student', methodName: 'getNotes', text: 'db updated');
    } else {
      notesFetched = true;
    }
    return;
  }

  Future<void> getDocuments() async {
    if (globals.isConnected) {
      var res = await devinciRequest(endpoint: '?my=docs');
      if (res != null) {
        if (res.statusCode == 200) {
          var body = await res.transform(utf8.decoder).join();
          if (!body.contains('Validation des règlements')) {
            try {
              var doc = parse(body);
              //Element cert = doc.querySelector("#main > div > div:nth-child(5) > div:nth-child(2) > div > table > tbody > tr > td:nth-child(2)");
              try {
                var certIndex = 1;
                var imaginrIndex = 1;
                for (var i = 1;
                    i <
                        doc
                            .querySelectorAll(
                                '.social-box.social-bordered.span6')[1]
                            .querySelectorAll('tr')
                            .length;
                    i++) {
                  if (doc
                      .querySelectorAll('.social-box.social-bordered.span6')[1]
                      .querySelectorAll('tr')[i]
                      .querySelectorAll('td')[0]
                      .text
                      .contains('scolarité')) {
                    certIndex = i;
                  } else if (doc
                      .querySelectorAll('.social-box.social-bordered.span6')[1]
                      .querySelectorAll('tr')[i]
                      .querySelectorAll('td')[0]
                      .text
                      .contains('ImaginR')) {
                    imaginrIndex = i;
                  }
                }
                var certElements = doc
                    .querySelectorAll('.social-box.social-bordered.span6')[1]
                    .querySelectorAll('tr')[certIndex]
                    .querySelectorAll('td');

                documents['certificat']['annee'] = certElements[1].text;
                documents['certificat']['fr_url'] =
                    'https://www.leonard-de-vinci.net' +
                        certElements[2]
                            .querySelectorAll('a')[0]
                            .attributes['href'];
                documents['certificat']['en_url'] =
                    'https://www.leonard-de-vinci.net' +
                        certElements[2]
                            .querySelectorAll('a')[1]
                            .attributes['href'];

                FLog.info(
                    className: 'Student',
                    methodName: 'getDocuments',
                    text: '[2]' + documents['certificat']['annee']);
                FLog.info(
                    className: 'Student',
                    methodName: 'getDocuments',
                    text: '[3]' + documents['certificat']['fr_url']);
                FLog.info(
                    className: 'Student',
                    methodName: 'getDocuments',
                    text: '[4]' + documents['certificat']['en_url']);

                var imaginrElements = doc
                    .querySelectorAll('.social-box.social-bordered.span6')[1]
                    .querySelectorAll('tr')[imaginrIndex]
                    .querySelectorAll('td');

                documents['imaginr']['annee'] = imaginrElements[1].text;
                documents['imaginr']['url'] =
                    'https://www.leonard-de-vinci.net' +
                        imaginrElements[2]
                            .querySelectorAll('a')[0]
                            .attributes['href'];
              } catch (e, stacktrace) {
                FLog.logThis(
                    className: 'Student',
                    methodName: 'getDocuments',
                    text: 'exception',
                    type: LogLevel.ERROR,
                    exception: Exception(e),
                    stacktrace: stacktrace);
                await reportError(e, stacktrace);
              }
              var calendrierIndex = 4;
              try {
                for (var i = 0;
                    i <
                        doc
                            .querySelectorAll(
                                '.social-box.social-bordered.span6')[0]
                            .querySelectorAll('a')
                            .length;
                    i++) {
                  if (doc
                          .querySelectorAll(
                              '.social-box.social-bordered.span6')[0]
                          .querySelectorAll('a')[i]
                          .text
                          .contains('CALENDRIER ACADEMIQUE') &&
                      !doc
                          .querySelectorAll(
                              '.social-box.social-bordered.span6')[0]
                          .querySelectorAll('a')[i]
                          .text
                          .contains('APPRENTISSAGE')) {
                    calendrierIndex = i;
                  }
                }
              } catch (e, stacktrace) {
                FLog.logThis(
                    className: 'Student',
                    methodName: 'getDocuments',
                    text: 'exception',
                    type: LogLevel.ERROR,
                    exception: Exception(e),
                    stacktrace: stacktrace);
                await reportError(e, stacktrace);
              }

              try {
                documents['calendrier']['url'] =
                    'https://www.leonard-de-vinci.net' +
                        doc
                            .querySelectorAll(
                                '.social-box.social-bordered.span6')[0]
                            .querySelectorAll('a')[calendrierIndex]
                            .attributes['href'];
                documents['calendrier']['annee'] = RegExp(r'\d{4}-\d{4}')
                    .firstMatch(doc
                        .querySelectorAll(
                            '.social-box.social-bordered.span6')[0]
                        .querySelectorAll('a')[calendrierIndex]
                        .text)
                    .group(0);
              } catch (e, stacktrace) {
                FLog.logThis(
                    className: 'Student',
                    methodName: 'getDocuments',
                    text: 'exception',
                    type: LogLevel.SEVERE,
                    exception: Exception(e),
                    stacktrace: stacktrace);
              }

              FLog.info(
                  className: 'Student',
                  methodName: 'getDocuments',
                  text:
                      '[5] calendrier : ${documents["calendrier"]["annee"]}|${documents["calendrier"]["url"]}');
              //documents liés aux notes :
              await getNotesList();
              for (var item in notesList) {
                res = await devinciRequest(endpoint: '?my=notes&p=' + item[1]);
                if (res.statusCode == 200) {
                  body = await res.transform(utf8.decoder).join();
                  doc = parse(body);
                  if (doc.querySelectorAll('div.body').length > 1) {
                    var filesA = doc
                        .querySelectorAll('div.body')[
                            doc.querySelectorAll('div.body').length - 2]
                        .querySelectorAll('a:not(.label)');
                    FLog.info(
                        className: 'Student',
                        methodName: 'getDocuments',
                        text: '[6]' + filesA.toString());
                    documents['bulletins'].clear();
                    for (var i = 0; i < filesA.length; i += 2) {
                      documents['bulletins'].add({
                        'name': filesA[i]
                            .text
                            .substring(1, filesA[i].text.length - 1),
                        'fr_url': 'https://www.leonard-de-vinci.net' +
                            filesA[i].attributes['href'],
                        'en_url': 'https://www.leonard-de-vinci.net' +
                            filesA[i + 1].attributes['href'],
                        'sub': RegExp(r'\s\s+(.*?)\s\s+')
                            .firstMatch(doc
                                .querySelectorAll('div.body')[
                                    doc.querySelectorAll('div.body').length - 2]
                                .querySelector('header')
                                .text
                                .split('\n')
                                .last)
                            .group(1)
                      });
                    }
                  }
                  FLog.info(
                      className: 'Student',
                      methodName: 'getDocuments',
                      text: '[7]' + documents['bulletins'].toString());
                }
              }
              //res = await devinciRequest(endpoint: '?my=notes');
            } catch (e, stacktrace) {
              FLog.logThis(
                  className: 'Student',
                  methodName: 'getDocuments',
                  text: 'exception',
                  type: LogLevel.ERROR,
                  exception: Exception(e),
                  stacktrace: stacktrace);
              await reportError(e, stacktrace);
            }
          } else if (body.contains('Validation des règlements')) {
            final snackBar = material.SnackBar(
              content: material.Text('school_rules_validation').tr(),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            await showSnackBar(snackBar);
          }
        }
      }
      await globals.store.record('documents').put(globals.db, documents);
    } else {
      documents =
          await globals.store.record('documents').get(globals.db) as Map;
    }
    return;
  }

  Future<void> getPresence({bool force = false}) async {
    if (globals.isConnected || force) {
      var res = await devinciRequest(
          endpoint: 'student/presences/', followRedirects: true);
      if (res != null) {
        if (res.statusCode == 200) {
          var body = await res.transform(utf8.decoder).join();
          if (body.contains('Pas de cours de prévu')) {
            //this.presence[0]['type'] = 'none';
          } else {
            var doc = parse(body);
            var trs = doc.querySelectorAll('table > tbody > tr');
            presenceIndex = trs.length - 1;
            presence.clear();
            for (var i = 0; i < trs.length; i++) {
              presence.add({
                'type':
                    'none', //5 types : ongoing / done / notOpen / none / closed
                'title': '',
                'horaires': '',
                'prof': '',
                'seance_pk': '',
                'zoom': '',
                'zoom_pwd': '',
                'validation_date': '',
              });
            }
            for (var i = 0; i < trs.length; i++) {
              var tr = trs[i];
              var classe = tr.attributes['class'];
              if (classe == '' || classe == 'warning') {
                presenceIndex = i;
                break;
              }
            }

            for (var i = 0; i < trs.length; i++) {
              var tds = trs[i].querySelectorAll('td');
              presence[i]['horaires'] =
                  tds[0].text.replaceAllMapped(RegExp(r' '), (match) {
                return '';
              });
              presence[i]['title'] = tds[1].text;
              presence[i]['prof'] = tds[2].text;
              try {
                presence[i]['zoom'] =
                    tds[4].querySelector('a').attributes['href'];
                presence[i]['zoom_pwd'] = tds[4]
                    .querySelector('span')
                    .attributes['title']
                    .split(': ')[1];
              } catch (e, stacktrace) {
                FLog.logThis(
                    className: 'Student',
                    methodName: 'getPresence',
                    text: 'exception',
                    type: LogLevel.ERROR,
                    exception: Exception(e),
                    stacktrace: stacktrace);
              }
              var nextLink = tds[3].querySelector('a').attributes['href'];
              res = await devinciRequest(endpoint: nextLink.substring(1));
              if (res.statusCode == 200) {
                FLog.info(
                    className: 'Student',
                    methodName: 'getPresence',
                    text: 'go');
                var body = await res.transform(utf8.decoder).join();
                if (body.contains('pas encore ouvert')) {
                  presence[i]['type'] = 'notOpen';
                } else {
                  if (body.contains('Valider')) {
                    presence[i]['type'] = 'ongoing';
                    presence[i]['seance_pk'] = RegExp(r"seance_pk : '(.*?)'")
                        .firstMatch(body)
                        .group(1);
                  } else if (body.contains('Vous avez été noté présent')) {
                    presence[i]['type'] = 'done';
                    try {
                      var doc = parse(body);
                      var validationText = doc
                          .querySelector(
                              '#body_presence > div.alert.alert-success')
                          .text;
                      presence[i]['validation_date'] = RegExp(r'à (.*?) ')
                          .firstMatch(validationText)
                          .group(1);
                    } catch (e, stacktrace) {
                      FLog.logThis(
                          className: 'Student',
                          methodName: 'getPresence',
                          text: 'exception',
                          type: LogLevel.ERROR,
                          exception: Exception(e),
                          stacktrace: stacktrace);
                    }
                  } else if (body.contains('clôturé')) {
                    presence[i]['type'] = 'closed';
                  }
                }
              } else {
                presence[i]['type'] = 'none';
              }
            }
          }
        } else {
          error = true;
          code = res.statusCode;
          throw Exception({
            'code': code,
            'message': 'unhandled exception, ' + res.reasonPhrase,
            'url': res.redirects
          });
        }
      } else {
        throw Exception(400); //missing parameters
      }
    } else {
      throw HttpException(503.toString()); //service unavailable
    }
    FLog.info(
        className: 'Student',
        methodName: 'getPresence',
        text: presence.toString());
    return;
  }

  Future<void> setPresence(int index, {bool force = false}) async {
    if (globals.isConnected || force) {
      var res = await devinciRequest(
          endpoint: 'student/presences/upload.php',
          method: 'POST',
          headers: [
            ['Connection', 'keep-alive'],
            ['Accept', '*/*'],
            ['DNT', '1'],
            ['X-Requested-With', 'XMLHttpRequest'],
            [
              'User-Agent',
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36 Edg/81.0.416.64'
            ],
            [
              'Content-Type',
              'application/x-www-form-urlencoded; charset=UTF-8'
            ],
            ['Origin', 'https://www.leonard-de-vinci.net'],
            ['Sec-Fetch-Site', 'same-origin'],
            ['Sec-Fetch-Mode', 'cors'],
            ['Sec-Fetch-Dest', 'empty'],
            [
              'Referer',
              'https://www.leonard-de-vinci.net/student/presences/' +
                  Uri.encodeComponent(presence[index]['seance_pk'])
            ],
            [
              'Accept-Language',
              'fr,fr-FR;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6'
            ],
          ],
          data: 'act=set_present&seance_pk=' +
              Uri.encodeComponent(presence[index]['seance_pk']));
      if (res != null) {
        if (res.statusCode == 200) {
          presence[index]['type'] = 'done';
          var bytes = utf8.encode(presence[index]['title'] +
              presence[index]['prof'] +
              presence[index]['horaires']); // data being hashed
          var digest = sha256.convert(bytes);
          DevinciApi().call(digest.toString());
        } else {
          throw Exception(res.statusCode);
        }
      } else {
        throw Exception(400); //missing parameters
      }
    } else {
      throw HttpException(503.toString()); //service unavailable
    }
    return;
  }

  Future<void> getSallesLibres() async {
    var res = await devinciRequest(endpoint: 'student/salles/');
    if (res != null) {
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        var doc = parse(body);
        var table = doc.querySelector('table');
        var tbody = table.querySelector('tbody');
        var thead = table.querySelector('thead > tr');
        var headers = thead.querySelectorAll('td');
        sallesStr.clear();
        for (var header in headers) {
          sallesStr.add(header.text);
        }
        FLog.info(
            className: 'Student',
            methodName: 'getSallesLibres',
            text: sallesStr.join(' | '));
        var bodyTrs = tbody.querySelectorAll('tr');
        for (var tr in bodyTrs) {
          var name = tr.querySelector('a').text;
          name = name
              .replaceAll('ALDV - ', '')
              .replaceAll('Learning Center', 'LC')
              .replaceAll('Formeret', 'F');
          if (name.contains('[')) {
            name = name.split('[')[0];
          }
          if (name.contains('(')) {
            name = name.split('(')[0];
          }
          var oc = <bool>[];
          var tds = tr.querySelectorAll('td');
          for (var i = 0; i < tds.length; i++) {
            var td = tds[i];
            if (name.contains('103')) {
              FLog.info(
                  className: 'Student',
                  methodName: 'getSallesLibres',
                  text: td.outerHtml);
            }
            if (td.outerHtml.contains('slp_stab_cell')) {
              try {
                var collspan = td.attributes['colspan'];
                var coll = int.parse(collspan);
                for (var j = 0; j < coll; j++) {
                  oc.add(true);
                }
              } catch (e, stacktrace) {
                FLog.logThis(
                    className: 'Student',
                    methodName: 'getSallesLibres',
                    text: 'exception',
                    type: LogLevel.ERROR,
                    exception: Exception(e),
                    stacktrace: stacktrace);
              }
            } else {
              oc.add(false);
            }
          }
          salles.add(Salle(name, oc));
        }
      }
    }
    return;
  }
}
