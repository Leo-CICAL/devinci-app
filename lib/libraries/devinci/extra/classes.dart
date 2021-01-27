import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:devinci/extra/classes.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/material.dart' as material;
import 'package:html/parser.dart' show parse;
import 'package:matomo/matomo.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<void> init(material.BuildContext context) async {
    //fetch notesConfig
    try {
      var client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      var req = await client.getUrl(
        Uri.parse(
          'https://devinci.araulin.tech/nc.json',
        ),
      );
      var res = await req.close();
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        notesConfig = json.decode(body);
      }
      // ignore: empty_catches
    } catch (exception) {
      l(exception.toString());
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
    l('h2');
    this.notes = cloneList(notes);
    //retrieve tokens from secure storage (if they exist)
    tokens['SimpleSAML'] = await globals.storage.read(key: 'SimpleSAML') ??
        ''; //try to get token SimpleSAML from secure storage, if secure storage send back null (because the token does't exist yet) '??' means : if null, so if the token doesn't exist replace null by an empty string.
    tokens['alv'] = await globals.storage.read(key: 'alv') ?? '';
    tokens['uids'] = await globals.storage.read(key: 'uids') ?? '';
    tokens['SimpleSAMLAuthToken'] =
        await globals.storage.read(key: 'SimpleSAMLAuthToken') ?? '';
    
    //retrieve data from secure storage
    l('h3');
    globals.notifConsent = globals.prefs.getBool('notifConsent') ?? false;
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
    l('h5');
    if (data['edtUrl'] != '') {
      await setICal(data['edtUrl']);
    }
    data['name'] = await globals.storage.read(key: 'name') ?? '';
    if (globals.isConnected) {
      try {
        l('test tokens');
        await testTokens().timeout(Duration(seconds: 8), onTimeout: () {
          globals.isConnected = false;
        }).catchError((exception) async {
          l('test tokens exception : $exception');
          //testTokens throw an exception if tokens don't exist or if they aren't valid
          //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
          try {
            await getTokens();
          } catch (exception) {
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
      } catch (exception) {
        l('test tokens exception : $exception');

        //testTokens throw an exception if tokens don't exist or if they aren't valid
        //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
        try {
          await getTokens();
        } catch (exception) {
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
      l('edt : ' + globals.user.data['edtUrl']);
      if (globals.user.data['ecole'] == '' ||
          globals.user.data['edtUrl'] == '') {
        //edtUrl being the last information we retrieve from the getData() function, if it doesn't exist it means that the getData() function didn't work or was never run and must be run at least once.
        try {
          l("let's go try");
          await globals.user.getData();
        } catch (exception) {
          l(exception);
        }
      }
    }
    if (globals.crashConsent == 'true') {
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
      } catch (e, stacktrace) {
        Sentry.configureScope(
          (scope) {
            scope.setTag('app.language', 'locale'.tr());
            scope.user = User(email: username, id: tokens['uids']);
          },
        );
      }
    }
    DevinciApi().register();
    l('done init');
    return;
  }

  Future<void> getTokens() async {
    var client = HttpClient();

    if (username != '' && password != '') {
      var req = await client.getUrl(
        Uri.parse('https://www.leonard-de-vinci.net/'),
      );
      var res = await req.close();

      l('statusCode : ${res.statusCode}');
      l('headers : ${res.headers}');
      l('STEP 1 : HEADERS - SET-COOKIE : ${res.headers.value("set-cookie")}');
      var regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
      tokens['alv'] = regExp
          .firstMatch(
            res.headers.value('set-cookie'),
          )
          .group(2);
      l('ALV : "${tokens['alv']}"');
      if (res.statusCode == 200) {
        req = await client.postUrl(
            Uri.parse('https://www.leonard-de-vinci.net/ajax.inc.php'));
        req.headers.set(
            'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
        req.headers.set('Cookie', 'alv=${tokens["alv"]}');
        req.write('act=ident_analyse&login=' + Uri.encodeComponent(username));
        l('[STEP 2] REQ HEADERS : ${req.headers}');
        res = await req.close();
        l('[STEP 2] statusCode : ${res.statusCode}');
        l('[STEP 2] RES headers : ${res.headers}');
        var body = await res.transform(utf8.decoder).join();
        //l('[STEP 2] BODY : $body');
        if (body.contains('location')) {
          l('username correct');

          req = await client.getUrl(
            Uri.parse(
                'https://www.leonard-de-vinci.net/login.sso.php?username=' +
                    Uri.encodeComponent(username)),
          );
          req.followRedirects = false;
          req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
          req.headers.set('Cookie', 'alv=${tokens["alv"]}');
          l('[STEP 3] REQ HEADERS : ${req.headers}');
          res = await req.close();
          l('[STEP 3] statusCode : ${res.statusCode}');
          l('[STEP 3] RES headers : ${res.headers}');
          tokens['SimpleSAML'] = regExp
              .firstMatch(
                res.headers.value('set-cookie'),
              )
              .group(2);
          l('SimpleSAML : "${tokens['SimpleSAML']}"');

          var redUrl = res.headers.value('location');

          req = await client.getUrl(
            Uri.parse(redUrl),
          );
          res = await req.close();
          l('[STEP 4] statusCode : ${res.statusCode}');
          l('[STEP 4] RES headers : ${res.headers}');
          body = await res.transform(utf8.decoder).join();
          //l('[STEP 4] BODY : $body');
          regExp = RegExp(r'action="\/adfs(.*?)"');
          var url =
              'https://adfs.devinci.fr/adfs' + regExp.firstMatch(body).group(1);
          l('[STEP 4] url : $url');

          req = await client.postUrl(
            Uri.parse(url),
          );

          req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
          req.write('UserName=' +
              Uri.encodeComponent(username) +
              '&Password=' +
              Uri.encodeComponent(password) +
              '&AuthMethod=FormsAuthentication');
          l('[STEP 5] REQ HEADERS : ${req.headers}');
          res = await req.close();
          l('[STEP 5] statusCode : ${res.statusCode}');
          l('[STEP 5] RES headers : ${res.headers}');

          if (res.headers.value('set-cookie') != null &&
              res.statusCode == 302) {
            l('connected');
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
            l('[STEP 6] REQ HEADERS : ${req.headers}');
            res = await req.close();
            l('[STEP 6] statusCode : ${res.statusCode}');
            l('[STEP 6] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            regExp = RegExp(r'value="(.*?)"');
            var value = regExp.firstMatch(body).group(1);

            l('value : $value');
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
            l('[STEP 7] REQ HEADERS : ${req.headers}');
            res = await req.close();
            l('[STEP 7] statusCode : ${res.statusCode}');
            l('[STEP 7] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            l("set-cookie : ${res.headers['set-cookie']}");
            if (res.statusCode == 303) {
              redUrl = res.headers.value('location');
              regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
              tokens['SimpleSAMLAuthToken'] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][1],
                  )
                  .group(2);
              l('SimpleSAMLAuthToken : "${tokens["SimpleSAMLAuthToken"]}"');

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
              l('[STEP 8] REQ HEADERS : ${req.headers}');
              res = await req.close();
              l('[STEP 8] statusCode : ${res.statusCode}');
              l('[STEP 8] RES headers : ${res.headers}');
              //body = await res.transform(utf8.decoder).join();
              tokens['uids'] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][2],
                  )
                  .group(2);
              l('uids : "${tokens["uids"]}"');
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
              throw Exception('unhandled error');
            }
          } else {
            error = true;
            code = 401;
            throw Exception('wrong credentials');
          }
        } else {
          l('username incorrect');
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
      l('statusCode : ${response.statusCode}');
      l('headers : ${response.headers}');
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        l(body);
        if (body.contains("('#password').hide();")) {
          l('error');
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
    l('getData');
    var response = await devinciRequest(
        replacementUrl: 'https://www.leonard-de-vinci.net/', log: true);
    l(response);
    if (response != null) {
      l('statusCode : ${response.statusCode}');
      l('headers : ${response.headers}');
      var body = await response.transform(utf8.decoder).join();
      l('get Data');
      if (response.statusCode == 200) {
        l(body);

        var doc = parse(body);
        l(doc.outerHtml);
        var ns = doc.querySelectorAll('#main > div > .row-fluid');
        var n = ns[ns.length - 1].querySelector(
            'div.social-box.social-blue.social-bordered > header > h4');
        l('n : "${n.innerHtml}"');
        var regExp = RegExp(r': (.*?)\t');
        data['name'] = regExp.firstMatch(n.text).group(1);
        l("name : '${data["name"]}'");

        var ds = ns[ns.length - 1].querySelectorAll(
            'div.social-box.social-blue.social-bordered > div > div');
        l(ds);
        l('ds 0 : ' + ds[0].innerHtml);
        l('ds 1 : ' + ds[1].innerHtml);
        l('ds 2 : ' + ds[2].innerHtml);
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
            l('ds1 choosen');
            l(ds[1].querySelector('div'));
            d = ds[1]
                .querySelector('div > div > div.span4 > div > div > address')
                .text;
            l('d : $d');
          } else if (ds[2]
              .innerHtml
              .contains(french ? 'Identifiant' : 'User ID')) {
            d = ds[2]
                .querySelector('div > div > div.span4 > div > div > address')
                .text;
            l('d : $d');
          } else {
            d = ds[3]
                .querySelector('div > div > div.span4 > div > div > address')
                .text;
            l('d : $d');
          }
          //detect language of the portail
          if (globals.crashConsent == 'true') {
            try {
              Sentry.configureScope(
                (scope) =>
                    scope.setTag('portail.language', french ? 'fr' : 'en'),
              );
            } catch (e, stacktrace) {
              l(e);
              l(stacktrace);
            }
          }

          if (french) {
            data['badge'] = RegExp(r'badge : (.*?)\n').firstMatch(d).group(1);
            data['client'] = RegExp(r'client (.*?)\n').firstMatch(d).group(1);
            data['idAdmin'] =
                RegExp(r'Administratif (.*?)\n').firstMatch(d).group(1);
          } else {
            data['badge'] =
                RegExp(r'Badge Number : (.*?)\n').firstMatch(d).group(1);
            data['client'] =
                RegExp(r'Customer number (.*?)\n').firstMatch(d).group(1);
            data['idAdmin'] =
                RegExp(r'Administrative ID (.*?)\n').firstMatch(d).group(1);
          }
          data['ine'] = RegExp(r'INE/BEA : (.*?)\n').firstMatch(d).group(1);
          l("data : ${data["badge"]}|${data["client"]}|${data["idAdmin"]}|${data["ine"]}");
          // ignore: empty_catches
        } catch (e, stacktrace) {
          l(e);
          l(stacktrace);
        }
        response = await devinciRequest(endpoint: '?my=edt');

        l('statusCode : ${response.statusCode}');
        l('headers : ${response.headers}');
        body = await response.transform(utf8.decoder).join();
        if (response.statusCode == 200) {
          data['edtUrl'] = 'https://ical.devinci.me/' +
              RegExp(r'ical.devinci.me\/(.*?)"').firstMatch(body).group(1);
          l("ical url : ${data["edtUrl"]}");
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
          throw Exception('unhandled exception');
        }
      } else {
        error = true;
        code = response.statusCode;
        throw Exception('unhandled exception');
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
          l('got absences');
          var body = await res.transform(utf8.decoder).join();
          if (!body.contains('Validation des règlements')) {
            var doc = parse(body);
            l(doc.outerHtml);
            var spans = doc.querySelectorAll('.tab-pane > header > span');
            var nTB = doc
                .querySelector('.tab-pane > header > span.label.label-warning');
            l(nTB);
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
            l(absences['liste']);
          } else if (body.contains('Validation des règlements')) {
            final snackBar = material.SnackBar(
              content: material.Text('school_rules_validation').tr(),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
          }
          absences['done'] = true;
          await globals.store.record('absences').put(globals.db, absences);
        } else {
          error = true;
          code = res.statusCode;
          throw Exception('unhandled exception');
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

  Future<void> getNotesList() async {
    // l('test tokens');
    // try {
    //   await testTokens();
    // } catch (e) {
    //   l('need to reconnect');
    //   await getTokens();
    // }
    l(tokens);
    var res = await devinciRequest(endpoint: '?my=notes');
    if (res != null) {
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        if (!body.contains('Validation des règlements')) {
          var doc = parse(body);
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
          material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
        }
      } else {
        error = true;
        code = res.statusCode;
        throw Exception('unhandled exception');
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
        l('NOTES - STATUS CODE : ${res.statusCode}');
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
                    // ignore: empty_catches
                  } catch (e) {}
                  try {
                    elem['nf'] = double.parse(
                        RegExp(notesConfig['modules']['item']['!e']['nf']['r'])
                            .firstMatch(texts[notesConfig['modules']['item']
                                    ['!e']['nf']['i']] +
                                notesConfig['modules']['item']['!e']['nf']['+'])
                            .group(1));
                    // ignore: empty_catches
                  } catch (e) {}
                  try {
                    elem['moyP'] = double.parse(RegExp(
                            notesConfig['modules']['item']['!e']['moyP']['r'])
                        .firstMatch(texts[notesConfig['modules']['item']['!e']
                                ['moyP']['i']] +
                            notesConfig['modules']['item']['!e']['moyP']['+'])
                        .group(1));
                    // ignore: empty_catches
                  } catch (e) {}
                }
                nn['s'][y].add(elem);

                //nn["s${y + 1}"].add(elem);

                var ddlist = li.querySelector('ol');
                var j = 0;
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
                      .replaceAllMapped(
                          RegExp(notesConfig['matieres']['mr']), (match) => '');
                  elem['moy'] = null;
                  elem['moyP'] = null;
                  if (!texts[notesConfig['matieres']['ei']]
                      .contains(notesConfig['matieres']['eStr'])) {
                    try {
                      elem['moy'] = double.parse(texts[notesConfig['matieres']
                              ['!e']['moy']['i']]
                          .replaceAllMapped(
                              RegExp(notesConfig['matieres']['!e']['moy']['r']),
                              (match) => '')
                          .split(notesConfig['matieres']['!e']['moy']
                              ['s'])[notesConfig['matieres']['!e']['moy']
                          ['si']]);
                      // ignore: empty_catches
                    } catch (e) {
                      try {
                        if (texts[notesConfig['matieres']['!e']['moy']['i']]
                                .replaceAllMapped(
                                    RegExp(notesConfig['matieres']['!e']['moy']
                                        ['r']),
                                    (match) => '')
                                .split(notesConfig['matieres']['!e']['moy']
                                    ['s'])[notesConfig['matieres']['!e']['moy']
                                ['si']] ==
                            'Validé') {
                          elem['moy'] = 100.0;
                        }
                      } catch (e) {}
                    }
                    l(elem['moy']);
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
                        } catch (e) {
                          elem['moyP'] = null;
                        }
                      } else {
                        var noteR = double.parse(RegExp(notesConfig['matieres']
                                ['!e']['r']['noteR']['r'])
                            .firstMatch(texts[notesConfig['matieres']['!e']['r']
                                    ['noteR']['i']] +
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
                                notesConfig['matieres']['!e']['r']['moyP']['r'])
                            .firstMatch(texts[notesConfig['matieres']['!e']['r']
                                    ['moyP']['i']] +
                                notesConfig['matieres']['!e']['r']['moyP']['+'])
                            .group(1));
                      }
                      // ignore: empty_catches
                    } catch (e) {}
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
                          elem['note'] = double.parse(texts[notesConfig['notes']
                                      ['note']['i']]
                                  .replaceAllMapped(
                                      RegExp(notesConfig['notes']['note']['r']),
                                      (match) => '')
                                  .split(notesConfig['notes']['note']['s'])[
                              notesConfig['notes']['note']['si']]);
                        }
                        elem['noteP'] = null;
                        try {
                          elem['noteP'] = double.parse(
                              RegExp(notesConfig['notes']['nP']['r'])
                                  .firstMatch(
                                      texts[notesConfig['notes']['nP']['i']] +
                                          notesConfig['notes']['nP']['+'])
                                  .group(1));
                          // ignore: empty_catches
                        } catch (e) {}
                      }
                      nn['s'][y][i]['matieres'][j]['notes'].add(elem);
                      //nn["s${y + 1}"][i]["matieres"][j]["notes"].add(elem);
                    });
                  }
                  j++;
                });
                i++;
              }
            }
          } else if (body.contains('Validation des règlements')) {
            final snackBar = material.SnackBar(
              content: material.Text('school_rules_validation').tr(),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
          }
        } else {
          error = true;
          code = res.statusCode;
          throw Exception('unhandled exception');
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
      l('db updated');
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
                l('[1]' +
                    doc
                        .querySelectorAll(
                            '.social-box.social-bordered.span6')[1]
                        .querySelectorAll('tr')[i]
                        .querySelectorAll('td')[1]
                        .text);
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

              l('[2]' + documents['certificat']['annee']);
              l('[3]' + documents['certificat']['fr_url']);
              l('[4]' + documents['certificat']['en_url']);

              var imaginrElements = doc
                  .querySelectorAll('.social-box.social-bordered.span6')[1]
                  .querySelectorAll('tr')[imaginrIndex]
                  .querySelectorAll('td');

              documents['imaginr']['annee'] = imaginrElements[1].text;
              documents['imaginr']['url'] = 'https://www.leonard-de-vinci.net' +
                  imaginrElements[2]
                      .querySelectorAll('a')[0]
                      .attributes['href'];
            } catch (e) {
              if (globals.crashConsent == 'true') {
                await Sentry.captureException(
                  e,
                  stackTrace: e.stackTrace,
                );
              }
            }
            var calendrierIndex = 4;
            for (var i = 0;
                i <
                    doc
                        .querySelectorAll(
                            '.social-box.social-bordered.span6')[0]
                        .querySelectorAll('a')
                        .length;
                i++) {
              if (doc
                      .querySelectorAll('.social-box.social-bordered.span6')[0]
                      .querySelectorAll('a')[i]
                      .text
                      .contains('CALENDRIER ACADEMIQUE') &&
                  !doc
                      .querySelectorAll('.social-box.social-bordered.span6')[0]
                      .querySelectorAll('a')[i]
                      .text
                      .contains('APPRENTISSAGE')) {
                calendrierIndex = i;
              }
            }

            documents['calendrier']['url'] =
                'https://www.leonard-de-vinci.net' +
                    doc
                        .querySelectorAll(
                            '.social-box.social-bordered.span6')[0]
                        .querySelectorAll('a')[calendrierIndex]
                        .attributes['href'];
            documents['calendrier']['annee'] = RegExp(r'\d{4}-\d{4}')
                .firstMatch(doc
                    .querySelectorAll('.social-box.social-bordered.span6')[0]
                    .querySelectorAll('a')[calendrierIndex]
                    .text)
                .group(0);

            l('[5] calendrier : ${documents["calendrier"]["annee"]}|${documents["calendrier"]["url"]}');
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
                  l('[6]' + filesA.toString());
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
                l('[7]' + documents['bulletins'].toString());
              }
            }
            //res = await devinciRequest(endpoint: '?my=notes');

          } else if (body.contains('Validation des règlements')) {
            final snackBar = material.SnackBar(
              content: material.Text('school_rules_validation').tr(),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
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
      var res = await devinciRequest(endpoint: 'student/presences/');
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
              } catch (e) {
                l(e);
              }
              var nextLink = tds[3].querySelector('a').attributes['href'];
              res = await devinciRequest(endpoint: nextLink.substring(1));
              if (res.statusCode == 200) {
                l('go');
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
          throw Exception('unhandled exception');
        }
      } else {
        throw Exception(400); //missing parameters
      }
    } else {
      throw Exception(503); //service unavailable
    }
    l(presence);
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
      throw Exception(503); //service unavailable
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
        l(sallesStr.join(' | '));
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
              l(td.outerHtml);
            }
            if (td.outerHtml.contains('slp_stab_cell')) {
              try {
                var collspan = td.attributes['colspan'];
                var coll = int.parse(collspan);
                for (var j = 0; j < coll; j++) {
                  oc.add(true);
                }
                // ignore: empty_catches
              } catch (e) {}
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
