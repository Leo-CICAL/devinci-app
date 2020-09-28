import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart' as material;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class User {
  //constructor
  User(String username, String password) {
    this.username = username;
    this.password = password;
  }

  //values
  String username;
  String password;

  bool error = false;
  int code = 200;

  Map<String, String> tokens = {
    "SimpleSAML": "",
    "alv": "",
    "uids": "",
    "SimpleSAMLAuthToken": "",
  };

  void reset() async {
    this.tokens["SimpleSAML"] = "";
    this.tokens["alv"] = "";
    this.tokens["SimpleSAMLAuthToken"] = "";
    await globals.storage.deleteAll();
  }

  Map<String, String> data = {
    "badge": "",
    "client": "",
    "idAdmin": "",
    "ine": "",
    "edtUrl": "",
    "name": "",
  };

  Map<String, dynamic> absences = {
    "nT": 0,
    "s1": 0,
    "s2": 0,
    "seances": 0,
    "liste": [],
    "done": false
  };

  Map<String, dynamic> notes = {
    "s1": [],
    "s2": [],
  };

  Map notesEvolution = {
    "added": [],
    "changed": [],
  };

  bool notesFetched = false;

  var promotion = {};

  Map<String, dynamic> presence = {
    'type': 'none', //5 types : ongoing / done / notOpen / none / closed
    'title': '',
    'horaires': '',
    'prof': '',
    'seance_pk': '',
    'zoom': '',
    'zoom_pwd': '',
  };

  Map<String, dynamic> documents = {
    "certificat": {
      "annee": "",
      "fr_url": "",
      "en_url": "",
    },
    "imaginr": {
      "annee": "",
      "url": "",
    },
    "calendrier": {
      "annee": "",
      "url": "",
    },
    "bulletins": []
  };

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
    print(json.encode(this.notesConfig));
    try {
      HttpClient client = new HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      HttpClientRequest req = await client.getUrl(
        Uri.parse(
          "https://devinci.araulin.tech/nc.json",
        ),
      );
      HttpClientResponse res = await req.close();
      if (res.statusCode == 200) {
        String body = await res.transform(utf8.decoder).join();
        this.notesConfig = json.decode(body);
      }
    } catch (exception) {}
    //init sembast db
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final String path = directory.path;
    // File path to a file in the current directory
    String dbPath = path + '/data/db.db';
    DatabaseFactory dbFactory = databaseFactoryIo;

// We use the database factory to open the database
    globals.db = await dbFactory.openDatabase(dbPath);
    Map<String, dynamic> notes = await globals.store
        .record('notes')
        .get(globals.db) as Map<String, dynamic>;
    if (notes == null) {
      notes = {
        "s1": [],
        "s2": [],
      };
      await globals.store.record('notes').put(globals.db, notes);
    }
    //this.notes.copy(notes);
    //retrieve tokens from secure storage (if they exist)
    this.tokens["SimpleSAML"] = await globals.storage.read(key: "SimpleSAML") ??
        ""; //try to get token SimpleSAML from secure storage, if secure storage send back null (because the token does't exist yet) '??' means : if null, so if the token doesn't exist replace null by an empty string.
    this.tokens["alv"] = await globals.storage.read(key: "alv") ?? "";
    this.tokens["uids"] = await globals.storage.read(key: "uids") ?? "";
    this.tokens["SimpleSAMLAuthToken"] =
        await globals.storage.read(key: "SimpleSAMLAuthToken") ?? "";

    //retrieve data from secure storage
    globals.crashConsent = globals.prefs.getString('crashConsent') ?? 'true';
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(globals.crashConsent == 'true');
    globals.analyticsConsent =
        globals.prefs.getBool('analyticsConsent') ?? true;
    await globals.analytics
        .setAnalyticsCollectionEnabled(globals.analyticsConsent);
    bool calendarViewDay = globals.prefs.getBool('calendarViewDay') ?? true;
    globals.agendaView.calendarView =
        calendarViewDay ? CalendarView.day : CalendarView.workWeek;
    this.data["badge"] = await globals.storage.read(key: "badge") ?? "";
    this.data["client"] = await globals.storage.read(key: "client") ?? "";
    this.data["idAdmin"] = await globals.storage.read(key: "idAdmin") ?? "";
    this.data["ine"] = await globals.storage.read(key: "ine") ?? "";
    this.data["edtUrl"] = await globals.storage.read(key: "edtUrl") ?? "";
    this.data["name"] = await globals.storage.read(key: "name") ?? "";
    if (globals.isConnected) {
      try {
        l("test tokens");
        await this.testTokens().timeout(Duration(seconds: 8), onTimeout: () {
          globals.isConnected = false;
        }).catchError((exception) async {
          l("test tokens exception : $exception");
          //testTokens throw an exception if tokens don't exist or if they aren't valid
          //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
          try {
            await this.getTokens();
          } catch (exception) {
            //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
            if (this.code == 500) {
              //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

            } else if (this.code == 401) {
              await globals.storage
                  .deleteAll(); //remove all sensitive data from the phone if the user can't connect
              //the exception was thrown because credentials are wrong
              throw Exception(
                  "wrong credentials : $exception"); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
            } else {
              throw Exception(exception); //we don't know what happened here
            }
          }
        }); //test if tokens exist and if so, test if they are still valid
      } catch (exception) {
        l("test tokens exception : $exception");

        //testTokens throw an exception if tokens don't exist or if they aren't valid
        //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
        try {
          await this.getTokens();
        } catch (exception) {
          //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
          if (this.code == 500) {
            //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

          } else if (this.code == 401) {
            await globals.storage
                .deleteAll(); //remove all sensitive data from the phone if the user can't connect
            //the exception was thrown because credentials are wrong
            throw Exception(
                "wrong credentials : $exception"); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
          } else {
            throw Exception(exception); //we don't know what happened here
          }
        }
      }
      //if we manage to arrive here it means that we have valid tokens and that credentials are good
      await globals.storage.write(
          key: "username",
          value: this
              .username); //save credentials in secure storage if user specified "remember me"
      await globals.storage.write(key: "password", value: this.password);
      this.password =
          null; //if tokens are still valid we'll never need the password again in this session, so it is useless to keep it in the object and risk it to be leaked or displayed
      print('edt : ' + globals.user.data["edtUrl"]);
      if (globals.user.data["edtUrl"] == "") {
        //edtUrl being the last information we retrieve from the getData() function, if it doesn't exist it means that the getData() function didn't work or was never run and must be run at least once.
        try {
          print("let's go try");
          await globals.user.getData();
        } catch (exception) {
          //print(exception);
        }
      }
    }
    //print("done init");
    return;
  }

  Future<void> getTokens() async {
    HttpClient client = new HttpClient();

    if (this.username != "" && this.password != "") {
      HttpClientRequest req = await client.getUrl(
        Uri.parse('https://www.leonard-de-vinci.net/'),
      );
      HttpClientResponse res = await req.close();

      l('statusCode : ${res.statusCode}');
      l('headers : ${res.headers}');
      l('STEP 1 : HEADERS - SET-COOKIE : ${res.headers.value("set-cookie")}');
      RegExp regExp = new RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
      this.tokens["alv"] = regExp
          .firstMatch(
            res.headers.value("set-cookie"),
          )
          .group(2);
      l('ALV : "${this.tokens['alv']}"');
      if (res.statusCode == 200) {
        req = await client.postUrl(
            Uri.parse('https://www.leonard-de-vinci.net/ajax.inc.php'));
        req.headers.set(
            'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
        req.headers.set('Cookie', 'alv=${this.tokens["alv"]}');
        req.write(
            "act=ident_analyse&login=" + Uri.encodeComponent(this.username));
        l("[STEP 2] REQ HEADERS : ${req.headers}");
        res = await req.close();
        l('[STEP 2] statusCode : ${res.statusCode}');
        l('[STEP 2] RES headers : ${res.headers}');
        String body = await res.transform(utf8.decoder).join();
        l('[STEP 2] BODY : $body');
        if (body.indexOf("location") > -1) {
          l('username correct');

          req = await client.getUrl(
            Uri.parse(
                'https://www.leonard-de-vinci.net/login.sso.php?username=' +
                    Uri.encodeComponent(this.username)),
          );
          req.followRedirects = false;
          req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
          req.headers.set('Cookie', 'alv=${this.tokens["alv"]}');
          l("[STEP 3] REQ HEADERS : ${req.headers}");
          res = await req.close();
          l('[STEP 3] statusCode : ${res.statusCode}');
          l('[STEP 3] RES headers : ${res.headers}');
          this.tokens["SimpleSAML"] = regExp
              .firstMatch(
                res.headers.value("set-cookie"),
              )
              .group(2);
          l('SimpleSAML : "${this.tokens['SimpleSAML']}"');

          String redUrl = res.headers.value("location");

          req = await client.getUrl(
            Uri.parse(redUrl),
          );
          res = await req.close();
          l('[STEP 4] statusCode : ${res.statusCode}');
          l('[STEP 4] RES headers : ${res.headers}');
          body = await res.transform(utf8.decoder).join();
          //l('[STEP 4] BODY : $body');
          regExp = new RegExp(r'action="\/adfs(.*?)"');
          String url =
              "https://adfs.devinci.fr/adfs" + regExp.firstMatch(body).group(1);
          l('[STEP 4] url : $url');

          req = await client.postUrl(
            Uri.parse(url),
          );
          req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
          req.write("UserName=" +
              Uri.encodeComponent(this.username) +
              "&Password=" +
              Uri.encodeComponent(this.password) +
              "&AuthMethod=FormsAuthentication");
          l("[STEP 5] REQ HEADERS : ${req.headers}");
          res = await req.close();
          l('[STEP 5] statusCode : ${res.statusCode}');
          l('[STEP 5] RES headers : ${res.headers}');

          if (res.headers.value("set-cookie") != null &&
              res.statusCode == 302) {
            l('connected');
            regExp = new RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
            // ignore: non_constant_identifier_names
            String MSISAuth = regExp
                .firstMatch(
                  res.headers.value("set-cookie"),
                )
                .group(2);
            redUrl = res.headers.value("location");

            req = await client.getUrl(
              Uri.parse(redUrl),
            );
            req.headers.set("Cookie", "MSISAuth=" + MSISAuth);
            l("[STEP 6] REQ HEADERS : ${req.headers}");
            res = await req.close();
            l('[STEP 6] statusCode : ${res.statusCode}');
            l('[STEP 6] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            regExp = new RegExp(r'value="(.*?)"');
            String value = regExp.firstMatch(body).group(1);

            //l('value : $value');
            req = await client.postUrl(
              Uri.parse(
                  "https://www.leonard-de-vinci.net/include/SAML/module.php/saml/sp/saml2-acs.php/devinci-sp"),
            );
            req.headers
                .set("Content-Type", "application/x-www-form-urlencoded");
            req.headers.set("Cookie",
                "alv=${this.tokens["alv"]}; SimpleSAML=${this.tokens["SimpleSAML"]}");
            req.followRedirects = false;
            String b = "SAMLResponse=" +
                Uri.encodeComponent(value) +
                "&RelayState=https://www.leonard-de-vinci.net/login.sso.php";
            req.write(b);
            l("[STEP 7] REQ HEADERS : ${req.headers}");
            res = await req.close();
            l('[STEP 7] statusCode : ${res.statusCode}');
            l('[STEP 7] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            l("set-cookie : ${res.headers['set-cookie']}");
            if (res.statusCode == 303) {
              redUrl = res.headers.value("location");
              regExp = new RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
              this.tokens["SimpleSAMLAuthToken"] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][1],
                  )
                  .group(2);
              l('SimpleSAMLAuthToken : "${this.tokens["SimpleSAMLAuthToken"]}"');

              req = await client.getUrl(
                Uri.parse(redUrl),
              );
              req.followRedirects = false;
              req.headers.set(
                  "Cookie",
                  "alv=" +
                      this.tokens["alv"] +
                      "; SimpleSAML=" +
                      this.tokens["SimpleSAML"] +
                      "; SimpleSAMLAuthToken=" +
                      this.tokens["SimpleSAMLAuthToken"]);
              l("[STEP 8] REQ HEADERS : ${req.headers}");
              res = await req.close();
              l('[STEP 8] statusCode : ${res.statusCode}');
              l('[STEP 8] RES headers : ${res.headers}');
              //body = await res.transform(utf8.decoder).join();
              this.tokens["uids"] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][2],
                  )
                  .group(2);
              l('uids : "${this.tokens["uids"]}"');
              await globals.storage.write(
                key: "SimpleSAML",
                value: this.tokens["SimpleSAML"],
              );
              await globals.storage.write(
                key: "alv",
                value: this.tokens["alv"],
              );
              await globals.storage.write(
                key: "SimpleSAMLAuthToken",
                value: this.tokens["SimpleSAMLAuthToken"],
              );
              await globals.storage.write(
                key: "uids",
                value: this.tokens["uids"],
              );
              this.error = false;
              this.code = 200;
            } else {
              this.error = true;
              this.code = res.statusCode;
              throw Exception("unhandled error");
            }
          } else {
            this.error = true;
            this.code = 401;
            throw Exception("wrong credentials");
          }
        } else {
          l('username incorrect');
          this.error = true;
          this.code = 401;
          throw Exception("wrong credentials");
        }
      } else {
        this.error = true;
        this.code = res.statusCode;
        throw Exception("Error while retrieving alv token");
      }
    } else {
      this.error = true;
      this.code = 400;
      throw Exception("missing parameters");
    }
    return;
  }

  Future<void> testTokens() async {
    HttpClient client = new HttpClient();

    //check if all tokens are still valid:
    if (this.tokens["SimpleSAML"] != "" &&
        this.tokens["alv"] != "" &&
        this.tokens["uids"] != "" &&
        this.tokens["SimpleSAMLAuthToken"] != "" &&
        this.error == false) {
      this.error = true;
      this.code = 400;

      HttpClientRequest request = await client.getUrl(
        Uri.parse('https://www.leonard-de-vinci.net/'),
      );
      request.followRedirects = false;
      // request.cookies.addAll([
      //   new Cookie('alv', this.tokens["alv"]),
      //   new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
      //   new Cookie('uids', this.tokens["uids"]),
      //   new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
      // ]);
      request.headers.set("Cookie",
          "alv=${this.tokens["alv"]}; SimpleSAML=${this.tokens["SimpleSAML"]}; SimpleSAMLAuthToken=${this.tokens["SimpleSAMLAuthToken"]}; uids=${this.tokens["uids"]}");
      //request.headers.add("set",
      //"Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.2 Mobile/15E148 Safari/604.1");
      //print(request.headers);
      HttpClientResponse response = await request.close();

      l('statusCode : ${response.statusCode}');
      l('headers : ${response.headers}');
      String body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        //print(body);
        if (body.indexOf("('#password').hide();") > -1) {
          l("error");
          throw Exception("wrong tokens");
        } else {
          this.error = false;
          this.code = 200;
        }
      } else {
        throw Exception("wrong tokens -> statuscode : ${response.statusCode}");
      }
    } else {
      this.error = true;
      this.code = 400;
      throw Exception("missing tokens or user as error");
    }
    return;
  }

  Future<void> getData() async {
    HttpClient client = new HttpClient();
    if (this.tokens["SimpleSAML"] != "" &&
        this.tokens["alv"] != "" &&
        this.tokens["uids"] != "" &&
        this.tokens["SimpleSAMLAuthToken"] != "" &&
        this.error == false) {
      this.error = true;
      this.code = 400;

      HttpClientRequest request = await client.getUrl(
        Uri.parse('https://www.leonard-de-vinci.net/'),
      );
      request.followRedirects = false;
      request.cookies.addAll([
        new Cookie('alv', this.tokens["alv"]),
        new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
        new Cookie('uids', this.tokens["uids"]),
        new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
      ]);
      HttpClientResponse response = await request.close();

      l('statusCode : ${response.statusCode}');
      l('headers : ${response.headers}');
      String body = await response.transform(utf8.decoder).join();
      //print("get Data");
      if (response.statusCode == 200) {
        //print(body);

        var doc = parse(body);
        //print(doc.outerHtml);
        List<Element> ns = doc.querySelectorAll("#main > div > .row-fluid");
        Element n = ns[ns.length - 1].querySelector(
            "div.social-box.social-blue.social-bordered > header > h4");
        //print('n : "${n.innerHtml}"');
        RegExp regExp = new RegExp(r": (.*?)\t");
        this.data["name"] = regExp.firstMatch(n.text).group(1);
        l("name : '${this.data["name"]}'");

        List<Element> ds = ns[ns.length - 1].querySelectorAll(
            "div.social-box.social-blue.social-bordered > div > div");
        print(ds);
        print("ds 0 : " + ds[0].innerHtml);
        print("ds 1 : " + ds[1].innerHtml);
        print("ds 2 : " + ds[2].innerHtml);
        String d;
        if (ds[1].innerHtml.indexOf("Identifiant") > -1) {
          print("ds1 choosen");
          print(ds[1].querySelector("div"));
          d = ds[1]
              .querySelector("div > div > div.span4 > div > div > address")
              .text;
          l("d : $d");
        } else if (ds[2].innerHtml.indexOf("Identifiant") > -1) {
          d = ds[2]
              .querySelector("div > div > div.span4 > div > div > address")
              .text;
          l("d : $d");
        } else {
          d = ds[3]
              .querySelector("div > div > div.span4 > div > div > address")
              .text;
          l("d : $d");
        }
        this.data["badge"] =
            new RegExp(r"badge : (.*?)\n").firstMatch(d).group(1);
        this.data["client"] =
            new RegExp(r"client (.*?)\n").firstMatch(d).group(1);
        this.data["idAdmin"] =
            new RegExp(r"Administratif (.*?)\n").firstMatch(d).group(1);
        this.data["ine"] =
            new RegExp(r"INE/BEA : (.*?)\n").firstMatch(d).group(1);
        l("data : ${this.data["badge"]}|${this.data["client"]}|${this.data["idAdmin"]}|${this.data["ine"]}");

        request = await client
            .getUrl(Uri.parse("https://www.leonard-de-vinci.net/?my=edt"));
        request.followRedirects = false;
        request.cookies.addAll([
          new Cookie('alv', this.tokens["alv"]),
          new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
          new Cookie('uids', this.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
        ]);
        response = await request.close();

        l('statusCode : ${response.statusCode}');
        l('headers : ${response.headers}');
        body = await response.transform(utf8.decoder).join();
        if (response.statusCode == 200) {
          this.data["edtUrl"] = "https://ical.devinci.me/" +
              new RegExp(r'ical.devinci.me\/(.*?)"').firstMatch(body).group(1);
          l("ical url : ${this.data["edtUrl"]}");
          await globals.storage.write(
            key: "badge",
            value: this.data["badge"],
          );
          await globals.storage.write(
            key: "client",
            value: this.data["client"],
          );
          await globals.storage.write(
            key: "idAdmin",
            value: this.data["idAdmin"],
          );
          await globals.storage.write(
            key: "ine",
            value: this.data["ine"],
          );
          await globals.storage.write(
            key: "edtUrl",
            value: this.data["edtUrl"],
          );
          await globals.storage.write(
            key: "name",
            value: this.data["name"],
          );
        } else {
          this.error = true;
          this.code = response.statusCode;
          throw Exception("unhandled exception");
        }
      } else {
        this.error = true;
        this.code = response.statusCode;
        throw Exception("unhandled exception");
      }
    } else {
      this.error = true;
      this.code = 400;
      throw Exception("missing parameters");
    }
    return;
  }

  Future<void> getAbsences() async {
    if (globals.isConnected) {
      HttpClient client = new HttpClient();
      if (this.tokens["SimpleSAML"] != "" &&
          this.tokens["alv"] != "" &&
          this.tokens["uids"] != "" &&
          this.tokens["SimpleSAMLAuthToken"] != "") {
        HttpClientRequest req = await client.getUrl(
          Uri.parse("https://www.leonard-de-vinci.net/?my=abs"),
          //Uri.parse("https://www.araulin.tech/devinci/absences.html"),
        );
        req.followRedirects = false;
        req.cookies.addAll([
          new Cookie('alv', this.tokens["alv"]),
          new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
          new Cookie('uids', this.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
        ]);
        HttpClientResponse res = await req.close();
        if (res.statusCode == 200) {
          print("got absences");
          String body = await res.transform(utf8.decoder).join();
          if (body.indexOf('Validation des règlements') < 0) {
            var doc = parse(body);
            //print(doc.outerHtml);
            List<Element> spans =
                doc.querySelectorAll(".tab-pane > header > span");
            Element nTB = doc
                .querySelector(".tab-pane > header > span.label.label-warning");
            //print(nTB);
            String nTM =
                new RegExp(r': (.*?)"').firstMatch(nTB.text + '"').group(1);
            this.absences["nT"] = int.parse(nTM);

            String s1M = new RegExp(r': (.*?)"')
                .firstMatch(spans[0].text + '"')
                .group(1);
            this.absences["s1"] = int.parse(s1M);

            Element s2B = doc
                .querySelector(".tab-pane > header > span.label.label-success");
            String s2M =
                new RegExp(r': (.*?)"').firstMatch(s2B.text + '"').group(1);
            this.absences["s2"] = int.parse(s2M);

            String seanceM = new RegExp(r'"(.*?) séance')
                .firstMatch('"' + spans[3].text)
                .group(1);
            this.absences["seances"] = int.parse(seanceM);
            List<Element> trs =
                doc.querySelectorAll(".tab-pane.active > table > tbody > tr");
            this.absences["liste"].clear();
            trs.forEach((tr) {
              Map<String, String> elem = {
                "cours": "",
                "type": "",
                "jour": "",
                "creneau": "",
                "duree": "",
                "modalite": ""
              };

              List<Element> tds = tr.querySelectorAll("td");
              elem["cours"] = tds[1]
                  .text
                  .replaceAll(tds[1].querySelector("span").text, "")
                  .replaceAllMapped(RegExp(r'\s\s+'), (match) => "");
              elem["type"] =
                  tds[2].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => "");
              elem["jour"] =
                  tds[3].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => "");
              elem["creneau"] =
                  tds[4].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => "");
              elem["duree"] =
                  tds[5].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => "");
              elem["modalite"] =
                  tds[6].text.replaceAllMapped(RegExp(r'\s\s+'), (match) => "");
              this.absences["liste"].add(elem);
            });
            print(this.absences["liste"]);
          } else if (body.indexOf('Validation des règlements') > -1) {
            final snackBar = material.SnackBar(
              content: material.Text(
                  "Validation des règlements requise sur le portail."),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
          }
          this.absences["done"] = true;
          await globals.store.record('absences').put(globals.db, this.absences);
        } else {
          this.error = true;
          this.code = res.statusCode;
          throw Exception("unhandled exception");
        }
      } else {
        this.error = true;
        this.code = 400;

        throw Exception("missing parameters => " +
            this.tokens["SimpleSAML"] +
            " | " +
            this.tokens["alv"] +
            " | " +
            this.tokens["SimpleSAMLAuthToken"] +
            " | " +
            this.tokens["uids"] +
            " | " +
            this.error.toString());
      }
    } else {
      this.absences =
          await globals.store.record('absences').get(globals.db) as Map;
    }

    return;
  }

  Future<void> getNotes({bool load = false}) async {
    if (globals.isConnected) {
      List added = [];
      List changed = [];
      Map<String, dynamic> nn = {"s1": [], "s2": []};
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> before = {"s1": [], "s2": []};
      before.copy(this.notes);
      HttpClient client = new HttpClient();
      if (this.tokens["SimpleSAML"] != "" &&
          this.tokens["alv"] != "" &&
          this.tokens["uids"] != "" &&
          this.tokens["SimpleSAMLAuthToken"] != "") {
        int timestamp = DateTime.now().millisecondsSinceEpoch;

        HttpClientRequest req = await client.getUrl(
          Uri.parse(
            //'http://172.24.112.1:5500/corentin.html',
            'https://www.leonard-de-vinci.net/?my=notes',
          ),
        );
        req.followRedirects = false;
        req.cookies.addAll([
          new Cookie('alv', this.tokens["alv"]),
          new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
          new Cookie('uids', this.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
        ]);
        HttpClientResponse res = await req.close();
        l("NOTES - STATUS CODE : ${res.statusCode}");
        if (res.statusCode == 200) {
          String body = await res.transform(utf8.decoder).join();
          if (body.indexOf('Aucune note') < 0 &&
              body.indexOf('Validation des règlements') < 0) {
            var doc = parse(body);

            List<Element> divs =
                doc.querySelectorAll(this.notesConfig['mainDivs']);
            for (int y = 0; y < 2; y++) {
              int i = 0;
              List<Element> ols1 =
                  divs[5].querySelectorAll(this.notesConfig['modules']['ols']);
              List<Element> ols = ols1[y]
                  .querySelector(this.notesConfig['modules']['olsBis'])
                  .children;
              for (int yy = 1; yy < ols.length; yy++) {
                Element ol = ols[yy];
                Map<String, dynamic> elem = {
                  "module": "",
                  "moy": 0.0,
                  "nf": 0.0,
                  "moyP": 0.0,
                  "matieres": []
                };
                Element li = ol.querySelector("li");
                Element ddhandle = ol.querySelector("div");
                List<String> texts = ddhandle.text.split("\n");
                elem["module"] = texts[this.notesConfig['modules']['item']['m']]
                    .replaceAllMapped(
                        RegExp(this.notesConfig['modules']['item']['mR']),
                        (match) => "");

                elem["moy"] = null;
                elem["nf"] = null;
                elem["moyP"] = null;
                if (texts[this.notesConfig['modules']['item']['eI']]
                        .indexOf(this.notesConfig['modules']['item']['eStr']) <
                    0) {
                  elem["moy"] = double.parse(
                      texts[this.notesConfig['modules']['item']['!e']['moy']['i']]
                              .replaceAllMapped(
                                  RegExp(this.notesConfig['modules']['item']
                                      ['!e']['moy']['r']),
                                  (match) => "")
                              .split(this.notesConfig['modules']['item']['!e']['moy']['s'])[
                          this.notesConfig['modules']['item']['!e']['moy']
                              ['si']]);
                  elem["nf"] = double.parse(RegExp(
                          this.notesConfig['modules']['item']['!e']['nf']['r'])
                      .firstMatch(texts[this.notesConfig['modules']['item']
                              ['!e']['nf']['i']] +
                          this.notesConfig['modules']['item']['!e']['nf']['+'])
                      .group(1));
                  elem["moyP"] = double.parse(RegExp(this.notesConfig['modules']
                          ['item']['!e']['moyP']['r'])
                      .firstMatch(texts[this.notesConfig['modules']['item']
                              ['!e']['moyP']['i']] +
                          this.notesConfig['modules']['item']['!e']['moyP']
                              ['+'])
                      .group(1));
                }

                nn["s${y + 1}"].add(elem);

                Element ddlist = li.querySelector("ol");
                int j = 0;
                ddlist.children.forEach((lii) {
                  ddhandle = lii.querySelector("div");
                  texts = ddhandle.text.split("\n");
                  //String prettyprint = encoder.convert(texts);
                  // print(prettyprint);
                  elem = {
                    "matiere": "",
                    "moy": 0.0,
                    "moyP": 0.0,
                    "notes": [],
                    "c": true
                  };

                  elem["matiere"] = texts[this.notesConfig['matieres']['mi']]
                      .replaceAllMapped(
                          RegExp(this.notesConfig['matieres']['mr']),
                          (match) => "");
                  elem["moy"] = null;
                  elem["moyP"] = null;
                  if (texts[this.notesConfig['matieres']['ei']]
                          .indexOf(this.notesConfig['matieres']['eStr']) <
                      0) {
                    elem["moy"] = double.parse(texts[
                                this.notesConfig['matieres']['!e']['moy']['i']]
                            .replaceAllMapped(
                                RegExp(this.notesConfig['matieres']['!e']['moy']
                                    ['r']),
                                (match) => "")
                            .split(this.notesConfig['matieres']['!e']['moy']['s'])[
                        this.notesConfig['matieres']['!e']['moy']['si']]);
                    //print(elem["moy"]);

                    if (texts[this.notesConfig['matieres']['!e']['ri']].indexOf(
                            this.notesConfig['matieres']['!e']['rStr']) <
                        0) {
                      try {
                        elem["moyP"] = double.parse(RegExp(
                                this.notesConfig['matieres']['!e']['!r']['moyP']
                                    ['r'])
                            .firstMatch(texts[this.notesConfig['matieres']['!e']
                                    ['!r']['moyP']['i']] +
                                this.notesConfig['matieres']['!e']['!r']['moyP']
                                    ['+'])
                            .group(1));
                      } catch (e) {
                        elem["moyP"] = null;
                      }
                    } else {
                      double noteR = double.parse(RegExp(this
                              .notesConfig['matieres']['!e']['r']['noteR']['r'])
                          .firstMatch(texts[this.notesConfig['matieres']['!e']
                                  ['r']['noteR']['i']] +
                              this.notesConfig['matieres']['!e']['r']['noteR']
                                  ['+'])
                          .group(1));
                      if (noteR > elem["moy"]) {
                        if (noteR > 10) {
                          elem["moy"] = 10.0;
                        } else {
                          elem["moy"] = noteR;
                        }
                      }
                      var e = {
                        "nom": "MESIMF120419-CC-1 Rattrapage",
                        "note": noteR,
                        "noteP": null,
                        "date": timestamp
                      };

                      elem["notes"].add(e);

                      elem["moyP"] = double.parse(RegExp(this
                              .notesConfig['matieres']['!e']['r']['moyP']['r'])
                          .firstMatch(texts[this.notesConfig['matieres']['!e']
                                  ['r']['moyP']['i']] +
                              this.notesConfig['matieres']['!e']['r']['moyP']
                                  ['+'])
                          .group(1));
                    }
                  }

                  nn["s${y + 1}"][i]["matieres"].add(elem);
                  ddlist = lii.querySelector("ol");
                  if (ddlist != null) {
                    ddlist.children.forEach((liii) {
                      ddhandle = liii.querySelector("div");
                      texts = ddhandle.text.split("\n");
                      elem = {
                        "nom": "",
                        "note": 0.0,
                        "noteP": 0.0,
                        "date": timestamp
                      };
                      elem["nom"] = texts[this.notesConfig['notes']['n']['i']]
                          .replaceAllMapped(
                              RegExp(this.notesConfig['notes']['n']['r']),
                              (match) => "");
                      if (texts.length < this.notesConfig['notes']['tl']) {
                        elem["note"] = null;
                        elem["noteP"] = null;
                      } else {
                        String temp = texts[this.notesConfig['notes']['note']
                                ['i']]
                            .replaceAllMapped(
                                RegExp(this.notesConfig['notes']['note']['r']),
                                (match) => "")
                            .split(this.notesConfig['notes']['note']
                                ['s'])[this.notesConfig['notes']['note']['si']];
                        if (temp.indexOf('Absence') > -1) {
                          elem["note"] = 0.12345;
                        } else {
                          elem["note"] = double.parse(
                              texts[this.notesConfig['notes']['note']['i']]
                                  .replaceAllMapped(
                                      RegExp(this.notesConfig['notes']['note']
                                          ['r']),
                                      (match) => "")
                                  .split(this.notesConfig['notes']['note']
                                      ['s'])[this.notesConfig['notes']['note']
                                  ['si']]);
                        }
                        elem["noteP"] = null;
                        try {
                          elem["noteP"] = double.parse(RegExp(
                                  this.notesConfig['notes']['nP']['r'])
                              .firstMatch(
                                  texts[this.notesConfig['notes']['nP']['i']] +
                                      this.notesConfig['notes']['nP']['+'])
                              .group(1));
                        } catch (e) {}
                      }

                      nn["s${y + 1}"][i]["matieres"][j]["notes"].add(elem);
                    });
                  }
                  j++;
                });
                i++;
              }
            }
          } else if (body.indexOf('Validation des règlements') > -1) {
            final snackBar = material.SnackBar(
              content: material.Text(
                  "Validation des règlements requise sur le portail."),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
          }
        } else {
          this.error = true;
          this.code = res.statusCode;
          throw Exception("unhandled exception");
        }
      } else {
        this.error = true;
        this.code = 400;

        throw Exception("missing parameters => " +
            this.tokens["SimpleSAML"] +
            " | " +
            this.tokens["alv"] +
            " | " +
            this.tokens["SimpleSAMLAuthToken"] +
            " | " +
            this.tokens["uids"] +
            " | " +
            this.error.toString());
      }
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < before["s${i + 1}"].length; j++) {
          for (int k = 0; k < before["s${i + 1}"][j]["matieres"].length; k++) {
            var old = before["s${i + 1}"][j]["matieres"][k]["notes"];
            var n = nn["s${i + 1}"][j]["matieres"][k]["notes"];
            // print(
            //     "old:${before["s${i + 1}"][j]["matieres"].length} | n:${nn["s${i + 1}"][j]["matieres"].length}");
            // print(before["s${i + 1}"][j]["module"]);
            before["s${i + 1}"][j]["matieres"][k]["moy"] =
                nn["s${i + 1}"][j]["matieres"][k]["moy"];
            before["s${i + 1}"][j]["matieres"][k]["moyP"] =
                nn["s${i + 1}"][j]["matieres"][k]["moyP"];
            Map<String, dynamic> comparaison = comparer(old, n);
            comparaison['added'].forEach(
              (item) {
                before["s${i + 1}"][j]["matieres"][k]["notes"].add(
                  {
                    'nom': item['nom'],
                    'note': item['note'],
                    'noteP': item['noteP'],
                    'date': timestamp,
                  },
                );
                added.add(
                  {
                    'matieres': before["s${i + 1}"][j]["matieres"][k]
                        ["matiere"],
                    'nom': item['nom'],
                    'note': item['note'],
                  },
                );
              },
            );
            comparaison['removed'].forEach(
              (item) {
                before["s${i + 1}"][j]["matieres"][k]["notes"]
                    .removeWhere((element) => element["nom"] == item["nom"]);
              },
            );
            comparaison['changed'].forEach((item) {
              changed.add({
                'matieres': before["s${i + 1}"][j]["matieres"][k]["matiere"],
                'data': item
              });
              for (int y = 0;
                  y < before["s${i + 1}"][j]["matieres"][k]["notes"].length;
                  y++) {
                if (before["s${i + 1}"][j]["matieres"][k]["notes"][y]["nom"] ==
                    item["key"]) {
                  item['v'].forEach((e) {
                    before["s${i + 1}"][j]["matieres"][k]["notes"][y][e[0]] =
                        e[1][1];
                  });
                  before["s${i + 1}"][j]["matieres"][k]["notes"][y]['date'] =
                      timestamp;
                  break;
                }
              }
            });
          }
        }
      }
      if (before["s1"].isEmpty && before["s2"].isEmpty) {
        this.notes.copy(nn);
        await globals.store.record('notes').put(globals.db, this.notes);
        this.notesFetched = true;
        print("db updated");
      } else {
        this.notes = {"s1": [], "s2": []};
        this.notes.copy(before);
        this.notesEvolution["added"] = added;
        this.notesEvolution["changed"] = changed;
        await globals.store.record('notes').put(globals.db, this.notes);
        this.notesFetched = true;
        print("db updated");
      }
    } else {
      this.notesFetched = true;
    }
    return;
  }

  Future<void> getDocuments() async {
    if (globals.isConnected) {
      HttpClient client = new HttpClient();
      if (this.tokens["SimpleSAML"] != "" &&
          this.tokens["alv"] != "" &&
          this.tokens["uids"] != "" &&
          this.tokens["SimpleSAMLAuthToken"] != "") {
        HttpClientRequest req = await client.getUrl(
          Uri.parse("https://www.leonard-de-vinci.net/?my=docs"),
          //"http://10.188.132.77:5500/documents.html"),
        );
        req.followRedirects = false;
        req.cookies.addAll([
          new Cookie('alv', this.tokens["alv"]),
          new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
          new Cookie('uids', this.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
        ]);
        HttpClientResponse res = await req.close();
        if (res.statusCode == 200) {
          String body = await res.transform(utf8.decoder).join();
          if (body.indexOf('Validation des règlements') < 0) {
            var doc = parse(body);
            //Element cert = doc.querySelector("#main > div > div:nth-child(5) > div:nth-child(2) > div > table > tbody > tr > td:nth-child(2)");
            try {
              int certIndex = 1;
              int imaginrIndex = 1;
              for (int i = 1;
                  i <
                      doc
                          .querySelectorAll(
                              ".social-box.social-bordered.span6")[1]
                          .querySelectorAll("tr")
                          .length;
                  i++) {
                print('[1]' +
                    doc
                        .querySelectorAll(
                            ".social-box.social-bordered.span6")[1]
                        .querySelectorAll("tr")[i]
                        .querySelectorAll("td")[1]
                        .text);
                if (doc
                        .querySelectorAll(
                            ".social-box.social-bordered.span6")[1]
                        .querySelectorAll("tr")[i]
                        .querySelectorAll("td")[0]
                        .text
                        .indexOf("scolarité") >
                    -1) {
                  certIndex = i;
                } else if (doc
                        .querySelectorAll(
                            ".social-box.social-bordered.span6")[1]
                        .querySelectorAll("tr")[i]
                        .querySelectorAll("td")[0]
                        .text
                        .indexOf("ImaginR") >
                    -1) {
                  imaginrIndex = i;
                }
              }
              List<Element> certElements = doc
                  .querySelectorAll(".social-box.social-bordered.span6")[1]
                  .querySelectorAll("tr")[certIndex]
                  .querySelectorAll("td");

              this.documents["certificat"]["annee"] = certElements[1].text;
              this.documents["certificat"]["fr_url"] =
                  "https://www.leonard-de-vinci.net" +
                      certElements[2]
                          .querySelectorAll("a")[0]
                          .attributes["href"];
              this.documents["certificat"]["en_url"] =
                  "https://www.leonard-de-vinci.net" +
                      certElements[2]
                          .querySelectorAll("a")[1]
                          .attributes["href"];

              print('[2]' + this.documents["certificat"]["annee"]);
              print('[3]' + this.documents["certificat"]["fr_url"]);
              print('[4]' + this.documents["certificat"]["en_url"]);

              List<Element> imaginrElements = doc
                  .querySelectorAll(".social-box.social-bordered.span6")[1]
                  .querySelectorAll("tr")[imaginrIndex]
                  .querySelectorAll("td");

              this.documents["imaginr"]["annee"] = imaginrElements[1].text;
              this.documents["imaginr"]["url"] =
                  "https://www.leonard-de-vinci.net" +
                      imaginrElements[2]
                          .querySelectorAll("a")[0]
                          .attributes["href"];
            } catch (e) {
              FirebaseCrashlytics.instance.recordError(e, e.stacktrace);
            }
            int calendrierIndex = 4;
            for (int i = 0;
                i <
                    doc
                        .querySelectorAll(
                            ".social-box.social-bordered.span6")[0]
                        .querySelectorAll("a")
                        .length;
                i++) {
              if (doc
                          .querySelectorAll(
                              ".social-box.social-bordered.span6")[0]
                          .querySelectorAll("a")[i]
                          .text
                          .indexOf("CALENDRIER ACADEMIQUE") >
                      -1 &&
                  doc
                          .querySelectorAll(
                              ".social-box.social-bordered.span6")[0]
                          .querySelectorAll("a")[i]
                          .text
                          .indexOf("APPRENTISSAGE") <
                      0) {
                calendrierIndex = i;
              }
            }

            this.documents["calendrier"]["url"] =
                "https://www.leonard-de-vinci.net" +
                    doc
                        .querySelectorAll(
                            ".social-box.social-bordered.span6")[0]
                        .querySelectorAll("a")[calendrierIndex]
                        .attributes["href"];
            this.documents["calendrier"]["annee"] = RegExp(r"\d{4}-\d{4}")
                .firstMatch(doc
                    .querySelectorAll(".social-box.social-bordered.span6")[0]
                    .querySelectorAll("a")[calendrierIndex]
                    .text)
                .group(0);

            print('[5]' +
                "calendrier : ${this.documents["calendrier"]["annee"]}|${this.documents["calendrier"]["url"]}");
            //documents liés aux notes :
            req = await client.getUrl(
              Uri.parse("https://www.leonard-de-vinci.net/?my=notes"),
              //"http://10.188.132.77:5500/notes.html"),
            );
            req.followRedirects = false;
            req.cookies.addAll([
              new Cookie('alv', this.tokens["alv"]),
              new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
              new Cookie('uids', this.tokens["uids"]),
              new Cookie(
                  'SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
            ]);
            res = await req.close();
            if (res.statusCode == 200) {
              body = await res.transform(utf8.decoder).join();
              doc = parse(body);
              if (doc.querySelectorAll("div.body").length > 1) {
                List<Element> filesA = doc
                    .querySelectorAll(
                        "div.body")[doc.querySelectorAll("div.body").length - 2]
                    .querySelectorAll("a:not(.label)");
                print('[6]' + filesA.toString());
                this.documents["bulletins"].clear();
                for (int i = 0; i < filesA.length; i += 2) {
                  this.documents["bulletins"].add({
                    "name":
                        filesA[i].text.substring(1, filesA[i].text.length - 1),
                    "fr_url": "https://www.leonard-de-vinci.net" +
                        filesA[i].attributes["href"],
                    "en_url": "https://www.leonard-de-vinci.net" +
                        filesA[i + 1].attributes["href"],
                    "sub": RegExp(r'\s\s+(.*?)\s\s+')
                        .firstMatch(doc
                            .querySelectorAll("div.body")[
                                doc.querySelectorAll("div.body").length - 2]
                            .querySelector("header")
                            .text
                            .split("\n")
                            .last)
                        .group(1)
                  });
                }
              }
              print('[7]' + this.documents["bulletins"].toString());
            }
          } else if (body.indexOf('Validation des règlements') > -1) {
            final snackBar = material.SnackBar(
              content: material.Text(
                  "Validation des règlements requise sur le portail."),
              duration: const Duration(seconds: 10),
            );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
            material.Scaffold.of(globals.currentContext).showSnackBar(snackBar);
          }
        }
      }
      await globals.store.record('documents').put(globals.db, this.documents);
    } else {
      this.documents =
          await globals.store.record('documents').get(globals.db) as Map;
    }
    return;
  }

  Future<void> getPresence({bool force = false}) async {
    if (globals.isConnected || force) {
      HttpClient client = new HttpClient();
      if (this.tokens["SimpleSAML"] != "" &&
          this.tokens["alv"] != "" &&
          this.tokens["uids"] != "" &&
          this.tokens["SimpleSAMLAuthToken"] != "") {
        HttpClientRequest req = await client.getUrl(
          Uri.parse(
            "https://www.leonard-de-vinci.net/student/presences/",
            //'http://10.188.132.77:5500/pr%C3%A9sence-zoom.html',
          ),
        );
        req.followRedirects = false;
        req.cookies.addAll([
          new Cookie('alv', this.tokens["alv"]),
          new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
          new Cookie('uids', this.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
        ]);
        HttpClientResponse res = await req.close();
        if (res.statusCode == 200) {
          String body = await res.transform(utf8.decoder).join();
          if (body.indexOf('Pas de cours de prévu') > -1) {
            this.presence['type'] = 'none';
          } else {
            var doc = parse(body);
            List<Element> trs = doc.querySelectorAll('table > tbody > tr');
            int index = -1;
            for (int i = 0; i < trs.length; i++) {
              Element tr = trs[i];
              String classe = tr.attributes['class'];
              if (classe == '' || classe == 'warning') {
                index = i;
                break;
              }
            }
            if (index == -1) {
              this.presence['type'] = 'none';
            } else {
              List<Element> tds = trs[index].querySelectorAll('td');
              this.presence['horaires'] =
                  tds[0].text.replaceAllMapped(RegExp(r' '), (match) {
                return '';
              });
              this.presence['title'] = tds[1].text;
              this.presence['prof'] = tds[2].text;
              try {
                this.presence['zoom'] =
                    tds[4].querySelector('a').attributes['href'];
                this.presence['zoom_pwd'] = tds[4]
                    .querySelector('span')
                    .attributes['title']
                    .split(': ')[1];
              } catch (e) {
                print(e);
              }
              String nextLink = tds[3].querySelector('a').attributes['href'];
              print(nextLink);
              print(this.presence);
              req = await client.getUrl(
                Uri.parse('https://www.leonard-de-vinci.net' + nextLink),
              );
              req.followRedirects = false;
              req.cookies.addAll([
                new Cookie('alv', this.tokens["alv"]),
                new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
                new Cookie('uids', this.tokens["uids"]),
                new Cookie(
                    'SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
              ]);
              res = await req.close();
              if (res.statusCode == 200) {
                print("go");
                String body = await res.transform(utf8.decoder).join();
                if (body.indexOf('pas encore ouvert') > -1) {
                  this.presence['type'] = 'notOpen';
                } else {
                  if (body.indexOf('Valider') > -1) {
                    this.presence['type'] = 'ongoing';
                    this.presence['seance_pk'] =
                        new RegExp(r"seance_pk : '(.*?)'")
                            .firstMatch(body)
                            .group(1);
                  } else if (body.indexOf('clôturé') > -1) {
                    this.presence['type'] = 'closed';
                  } else if (body.indexOf('Vous avez été noté présent') > -1) {
                    this.presence['type'] = 'done';
                  }
                }
              } else {
                this.presence['type'] = 'none';
              }
            }
          }
        } else {
          this.error = true;
          this.code = res.statusCode;
          throw Exception("unhandled exception");
        }
      } else {
        throw Exception(400); //missing parameters
      }
    } else {
      throw Exception(503); //service unavailable
    }
    print(this.presence);
    return;
  }

  Future<void> setPresence({bool force = false}) async {
    if (globals.isConnected || force) {
      HttpClient client = new HttpClient();
      if (this.tokens["SimpleSAML"] != "" &&
          this.tokens["alv"] != "" &&
          this.tokens["uids"] != "" &&
          this.tokens["SimpleSAMLAuthToken"] != "" &&
          this.presence["seance_pk"] != "") {
        HttpClientRequest req = await client.postUrl(
          Uri.parse(
            "https://www.leonard-de-vinci.net/student/presences/upload.php",
          ),
        );
        req.followRedirects = false;
        req.cookies.addAll([
          new Cookie('alv', this.tokens["alv"]),
          new Cookie('SimpleSAML', this.tokens["SimpleSAML"]),
          new Cookie('uids', this.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken', this.tokens["SimpleSAMLAuthToken"]),
        ]);
        req.headers.set('Connection', 'keep-alive');
        req.headers.set('Accept', '*/*');
        req.headers.set('DNT', '1');
        req.headers.set('X-Requested-With', 'XMLHttpRequest');
        req.headers.set('User-Agent',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36 Edg/81.0.416.64');
        req.headers.set(
            'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        req.headers.set('Origin', 'https://www.leonard-de-vinci.net');
        req.headers.set('Sec-Fetch-Site', 'same-origin');
        req.headers.set('Sec-Fetch-Mode', 'cors');
        req.headers.set('Sec-Fetch-Dest', 'empty');
        req.headers.set(
            'Referer',
            'https://www.leonard-de-vinci.net/student/presences/' +
                Uri.encodeComponent(this.presence["seance_pk"]));
        req.headers.set('Accept-Language',
            'fr,fr-FR;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6');
        req.write(
          "act=set_present&seance_pk=" +
              Uri.encodeComponent(this.presence["seance_pk"]),
        );
        HttpClientResponse res = await req.close();
        if (res.statusCode == 200) {
          this.presence["type"] = 'done';
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
}
