import 'dart:convert';
import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity/connectivity.dart';
import 'package:devinci/libraries/json_diff/json_diff.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:package_info/package_info.dart';
import 'dart:typed_data';
import 'package:devinci/libraries/feedback/feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:devinci/extra/classes.dart';

Cookie getCookie(List<Cookie> cookieJar, String name) {
  Cookie res;
  for (Cookie cookie in cookieJar) {
    if (cookie.name == name) {
      res = cookie;
      break;
    }
  }
  return res;
}

void l(var msg) {
  //stand for log
  if (!kReleaseMode) {
    //app is not in release mode
    print(msg);
  }
}

double getMatMoy(var elem) {
  if (elem["ratt"] != null) {
    if (elem["moy"] > elem["ratt"]) {
      return elem["moy"];
    } else {
      return elem["ratt"];
    }
  } else {
    if (elem["moy"] != null) {
      return elem["moy"];
    } else {
      if (!globals.asXxMoy) {
        globals.asXxMoy = true;
      }
      return null;
    }
  }
}

removeGarbage(text) {
  List<String> s = text.split(" ");
  String res = "";
  for (var i = 1; i < s.length; i++) {
    res += s[i] + (i == s.length - 1 ? "" : " ");
  }
  //res = truncateWithEllipsis(18, res);
  return res;
}

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

Future<List<Cours>> parseIcal(String icsUrl, {bool load = false}) async {
  List<Cours> results = new List<Cours>();
  HttpClient client = new HttpClient();
  String body = "";
  if (globals.isConnected && load) {
    HttpClientRequest req = await client.getUrl(Uri.parse(icsUrl));
    HttpClientResponse res = await req.close();

    body = await res.transform(utf8.decoder).join();
    if (res.statusCode == 200) {
      await globals.store.record('ical').put(globals.db, body);
    } else {
      body = await globals.store.record('ical').get(globals.db) as String ?? "";
      if (body == "") {
        throw Exception("error ${res.statusCode}");
      }
    }
  } else {
    body = await globals.store.record('ical').get(globals.db) as String ?? "";
    if (body == "") {
      if (globals.isConnected) {
        HttpClientRequest req = await client.getUrl(Uri.parse(icsUrl));
        HttpClientResponse res = await req.close();

        body = await res.transform(utf8.decoder).join();
        if (res.statusCode == 200) {
          await globals.store.record('ical').put(globals.db, body);
        } else {
          body = await globals.store.record('ical').get(globals.db) as String ??
              "";
          if (body == "") {
            throw Exception("error ${res.statusCode}");
          }
        }
      } else {
        throw Exception("no backup");
      }
    }
  }
  RegExp mainReg =
      new RegExp(r'BEGIN:VEVENT([\s\S]*?)END:VEVENT', multiLine: true);

  if (mainReg.hasMatch(body)) {
    Iterable<RegExpMatch> vevents = mainReg.allMatches(body);
    // print(vevents);
    // print(vevents.length);
    vevents.forEach((vevent) {
      //print("new   ");
      String veventBody = vevent.group(1);
      //print(veventBody);
      String dtstart,
          dtend,
          location,
          site,
          prof,
          title,
          typecours,
          flag,
          uid,
          groupe;
      dtstart = new RegExp(r'DTSTART:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("DTSTART:", "");
      dtend = new RegExp(r'DTEND:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("DTEND:", "");

      location = new RegExp(r'LOCATION:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("LOCATION:", "");
      site = new RegExp(r'SITE:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("SITE:", "");
      prof = new RegExp(r'PROF:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("PROF:", "");
      title = new RegExp(r'TITLE:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("TITLE:", "");
      typecours = new RegExp(r'TYPECOURS:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("TYPECOURS:", "");
      flag = new RegExp(r'FLAGPRESENTIEL:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("FLAGPRESENTIEL:", "");
      uid = new RegExp(r'UID:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("UID:", "");
      groupe = new RegExp(r'GROUPE:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst("GROUPE:", "");

      if (location == "SANS SALLE") {
        site = "";
      }
      Color color = (globals.currentTheme.isDark()
          ? Colors.redAccent
          : Colors.red.shade700);
      if (flag == 'distanciel') {
        color = (globals.currentTheme.isDark()
            ? Color(0xffFFDE03)
            : Color(0xffFF8A5C));
      } else if (flag == 'presentiel') {
        color = Colors.teal;
      }
      results.add(new Cours(
          typecours,
          title,
          prof,
          location,
          site,
          DateTime.parse(dtstart),
          DateTime.parse(dtend),
          color,
          false,
          flag,
          uid,
          groupe));
    });

    //(typecours == 'NR' ? '' : '($typecours) ') +
    //          "$title" +
    //          (prof != "" ? "\n$prof\n" : "\n") +
    //          "$location $site"
  } else {
    throw Exception("no vevents in body");
  }
  results.addAll(await jsonToCoursList());
  return results;
}

bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

/// Reports [error] along with its [stackTrace] to Sentry.io.
Future<Null> reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');
  String err = error.toString();
  if (Platform.isAndroid || Platform.isIOS) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      err +=
          "\ndevice info : ${iosInfo.name} : ${iosInfo.model} \n ios : ${iosInfo.systemVersion}\n physical device : ${iosInfo.isPhysicalDevice}";
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      err +=
          "\ndevice info : ${androidInfo.product}:${androidInfo.brand} \n android : ${androidInfo.version.release}\n physical device : ${androidInfo.isPhysicalDevice}";
    }
    err +=
        "\n appName : ${packageInfo.appName}\n packageName : ${packageInfo.packageName}\n version : ${packageInfo.version}\n buildNumber : ${packageInfo.buildNumber}\n ";
  }
  String consent = globals.prefs.getString('crashConsent');
  if (consent == null) {
    dialog(
      title: "Erreur",
      content:
          "Félicitations, vous avez cassé cette application. Je parie que vous attendez que l'on vous dise ce qu'il s'est passé : ¯\\_(ツ)_/¯\nCependant, si vous souhaitez que nous resolvions cette erreur, vous pouvez accepter que l'application partage les informations liées au problème avec nous.",
      ok: "Accepter",
      no: "Refuser",
      callback: (bool res) async {
        if (res) {
          await globals.prefs.setString('crashConsent', 'true');
          reportToCrash(err, stackTrace);
        } else {
          await globals.prefs.setString('crashConsent', 'false');
        }
      },
    );
  } else if (consent == "true") {
    reportToCrash(err, stackTrace);
  } else {
    final snackBar = SnackBar(
      content: Text(
          "Une erreur est survenue, mais nous n'avons pas envoyer de rapport d'incident"),
      action: SnackBarAction(
        label: 'Envoyer',
        onPressed: () => reportToCrash(err, stackTrace),
      ),
      duration: const Duration(seconds: 6),
    );

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(globals.currentContext).showSnackBar(snackBar);
  }
}

void reportToCrash(String err, StackTrace stackTrace) async {
  final snackBar = SnackBar(
    content: Text('Une erreur est survenue'),
    action: SnackBarAction(
        label: 'Ajouter des informations',
        onPressed: () async {
          globals.feedbackError = err;
          globals.feedbackStackTrace = stackTrace;
          BetterFeedback.of(globals.currentContext).show();
        }),
  );
  Scaffold.of(globals.currentContext).showSnackBar(snackBar);
  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Crashlytics.');
    return;
  }

  print('Reporting to Crashlytics...');
  Crashlytics.instance.recordError(err, stackTrace);
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

void checkUpdate() async {}

Map<String, dynamic> comparer(old, n) {
  Map<String, dynamic> res = {
    "added": [],
    "removed": [],
    "changed": [],
  };
  Map<String, dynamic> oldM = new Map<String, dynamic>();
  Map<String, dynamic> nM = new Map<String, dynamic>();

  //convert list to map

  for (int i = 0; i < old.length; i++) {
    oldM[old[i]["nom"]] = {
      "nom": old[i]["nom"],
      "note": old[i]["note"],
      "noteP": old[i]["noteP"]
    };
  }
  for (int i = 0; i < n.length; i++) {
    nM[n[i]["nom"]] = {
      "nom": n[i]["nom"],
      "note": n[i]["note"],
      "noteP": n[i]["noteP"]
    };
  }
  var differ = JsonDiffer(oldM, nM);
  var diff = differ.diff();
  diff.added.forEach((key, value) {
    res['added'].add(value);
    nM.remove(key);
  });
  diff.removed.forEach((key, value) {
    res['removed'].add(value);
    oldM.remove(key);
  });
  //we should only have left the changed ones and the non changed
  nM.forEach((key, value) {
    try {
      var v = [];
      diff.node[key].changed.forEach((key2, value2) {
        v.add([key2, value2]);
      });
      res['changed'].add({'key': key, "v": v});
    } catch (e) {
      // this one wasn't changed
    }
  });
  return res;
}

extension CopyDeepMap on Map<String, dynamic> {
  void copy(Map<String, dynamic> source) {
    for (int y = 0; y < 2; y++) {
      this["s${y + 1}"] = [];
      int i = 0;
      source["s${y + 1}"].forEach((sem) {
        Map<String, dynamic> elem = {
          "module": sem["module"],
          "moy": sem["moy"],
          "nf": sem["nf"],
          "moyP": sem["moyP"],
          "matieres": []
        };

        this["s${y + 1}"].add(elem);
        int j = 0;
        sem["matieres"].forEach((mat) {
          elem = {
            "matiere": mat["matiere"],
            "moy": mat["moy"],
            "moyP": mat["moyP"],
            "notes": [],
            "c": true
          };
          this["s${y + 1}"][i]["matieres"].add(elem);
          mat["notes"].forEach((note) {
            elem = {
              "nom": note["nom"],
              "note": note["note"],
              "noteP": note["noteP"],
              "date": note["date"]
            };
            this["s${y + 1}"][i]["matieres"][j]["notes"].add(elem);
          });
          j++;
        });
        i++;
      });
    }
  }
}

Future<void> showNotification(
    {String title, String body, int delay = 5, int id = 0}) async {
  print("sending notification");
  if (title != null && body != null) {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(
        seconds:
            delay)); //On envoie la notif avec 5 secondes de retard pour être sur que l'app n'est plus en foreground
    await globals.flutterLocalNotificationsPlugin.schedule(0, title, body,
        scheduledNotificationDateTime, globals.platformChannelSpecifics);
  }
}

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish(taskId);
}

Future<dynamic> onSelectNotification(String payload) async {
  if (payload != null) {
    FlutterAppBadger
        .removeBadge(); //on supprime le badge de notification lorsque la notification a été cliqué
    debugPrint('notification payload: ' + payload);
  }
  globals.selectNotificationSubject.add(payload);
}

void betterFeedbackOnFeedback(
  BuildContext context,
  String feedbackText, // the feedback from the user
  Uint8List feedbackScreenshot, // raw png encoded image data
) async {
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
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
}

Future<void> initPlatformState() async {
  // Configure BackgroundFetch.
  BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          startOnBoot: true,
          requiredNetworkType: NetworkType.NONE), (String taskId) async {
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received $taskId");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage storage = new FlutterSecureStorage();
    await prefs.setInt(
      'bgTime',
      new DateTime.now().millisecondsSinceEpoch,
    );
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool isConnected = connectivityResult != ConnectivityResult.none;
    if (isConnected) {
      HttpClient client = new HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      HttpClientRequest req = await client.getUrl(
        Uri.parse(Platform.isAndroid
            ? 'https://devinci.araulin.tech/na.json'
            : 'https://devinci.araulin.tech/ni.json'),
      );
      HttpClientResponse res = await req.close();
      String body = await res.transform(utf8.decoder).join();
      Map<String, dynamic> notif = json.decode(body);
      String nId = prefs.getString('nid') ?? "";
      int timeLastNotes = prefs.getInt('lastFetch') ?? 0;
      //fetch nouvelles notes :
      bool fetch = false;
      print(timeLastNotes);
      if (timeLastNotes == 0) {
        print('timeLastNotes empty');
        timeLastNotes = new DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('lastFetch', timeLastNotes);
        fetch = true;
      } else {
        DateTime now = new DateTime.now();
        if (now.hour > 7 && now.hour < 22) {
          //on ne fetch pas de nouvelles notes la nuit
          if (now.millisecondsSinceEpoch - timeLastNotes > 5400000) {
            //on ne fetch que toute les heures et demi pour ne pas être pénalisé par l'OS (hmm hmm iOS), et puis 1h30 me semble raisonnable comme interval de temps, les nouvelles notes n'ont pas besoin d'être en temps réel parce que au minimum le background fetch est appelé tout les 15 min
            fetch = true;
          }
        }
      }

      if (fetch) {
        print("fetch");
        globals.noteLocked = true;

        String username = await storage.read(key: 'username');
        String password = await storage.read(key: 'password');
        if (username != null && password != null) {
          globals.user = new User(username, password);
          await globals.user
              .init(); //on récupère les tokens, et le backup des notes
          print("connected");
          await globals.user.getNotes().timeout(Duration(seconds: 8),
              onTimeout: () {
            BackgroundFetch.finish(taskId);
          });
          print(globals.user.notesEvolution);
          String notifTitle = "";
          String notifBody = "";
          if (!globals.user.notesEvolution["added"].isEmpty &&
              !globals.user.notesEvolution["changed"].isEmpty) {
            notifTitle = "Evolutions des notes";
            //added
            if (globals.user.notesEvolution["added"].length > 1) {
              notifBody += "Nouvelles notes : ";
              print(notifTitle);
              for (int i = 0;
                  i < globals.user.notesEvolution["added"].length;
                  i++) {
                if (i == globals.user.notesEvolution["added"].length - 1) {
                  notifBody += " et ";
                }
                if (globals.user.notesEvolution["added"][i]["notes"] != null) {
                  notifBody +=
                      "${removeGarbage(globals.user.notesEvolution["added"][i]["notes"][0]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][i]["matieres"])} : ${globals.user.notesEvolution["added"][i]["notes"][0]["note"]}";
                } else {
                  notifBody +=
                      "${removeGarbage(globals.user.notesEvolution["added"][i]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][i]["matieres"])} : ${globals.user.notesEvolution["added"][i]["note"]}";
                }
                if (i < globals.user.notesEvolution["added"].length - 2) {
                  notifBody += ", ";
                }
              }
            } else {
              notifBody += "Nouvelle note : ";
              print(notifTitle);
              if (globals.user.notesEvolution["added"][0]["notes"] != null) {
                notifBody +=
                    "${removeGarbage(globals.user.notesEvolution["added"][0]["notes"][0]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][0]["matieres"])} : ${globals.user.notesEvolution["added"][0]["notes"][0]["note"]}";
              } else {
                notifBody +=
                    "${removeGarbage(globals.user.notesEvolution["added"][0]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][0]["matieres"])} : ${globals.user.notesEvolution["added"][0]["note"]}";
              }
            }

            //changed
            notifBody += "\n";
            if (globals.user.notesEvolution["changed"].length > 1) {
              notifBody += "Notes qui ont évoluées : ";
              print(notifTitle);
              for (int i = 0;
                  i < globals.user.notesEvolution["changed"].length;
                  i++) {
                if (i == globals.user.notesEvolution["changed"].length - 1) {
                  notifBody += " et ";
                }

                notifBody +=
                    "${removeGarbage(globals.user.notesEvolution["changed"][i]["data"]["key"])} en ${removeGarbage(globals.user.notesEvolution["changed"][i]["matieres"])} : ${globals.user.notesEvolution["changed"][i]["data"]["v"][0][1][0]} -> ${globals.user.notesEvolution["changed"][i]["data"]["v"][0][1][1]}";

                if (i < globals.user.notesEvolution["changed"].length - 2) {
                  notifBody += ", ";
                }
              }
            } else {
              notifBody += "Note qui a évoluée : ";
              print(notifTitle);
              notifBody +=
                  "${removeGarbage(globals.user.notesEvolution["changed"][0]["data"]["key"])} en ${removeGarbage(globals.user.notesEvolution["changed"][0]["matieres"])} : ${globals.user.notesEvolution["changed"][0]["data"]["v"][0][1][0]} -> ${globals.user.notesEvolution["changed"][0]["data"]["v"][0][1][1]}";
            }
          } else if (!globals.user.notesEvolution["added"].isEmpty &&
              globals.user.notesEvolution["changed"].isEmpty) {
            if (globals.user.notesEvolution["added"].length > 1) {
              notifTitle = "Nouvelles notes";
              print(notifTitle);
              for (int i = 0;
                  i < globals.user.notesEvolution["added"].length;
                  i++) {
                if (i == globals.user.notesEvolution["added"].length - 1) {
                  notifBody += " et ";
                }
                if (globals.user.notesEvolution["added"][i]["notes"] != null) {
                  notifBody +=
                      "${removeGarbage(globals.user.notesEvolution["added"][i]["notes"][0]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][i]["matieres"])} : ${globals.user.notesEvolution["added"][i]["notes"][0]["note"]}";
                } else {
                  notifBody +=
                      "${removeGarbage(globals.user.notesEvolution["added"][i]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][i]["matieres"])} : ${globals.user.notesEvolution["added"][i]["note"]}";
                }
                if (i < globals.user.notesEvolution["added"].length - 2) {
                  notifBody += ", ";
                }
              }
            } else {
              notifTitle = "Nouvelle note";
              print(notifTitle);
              if (globals.user.notesEvolution["added"][0]["notes"] != null) {
                notifBody =
                    "${removeGarbage(globals.user.notesEvolution["added"][0]["notes"][0]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][0]["matieres"])} : ${globals.user.notesEvolution["added"][0]["notes"][0]["note"]}";
              } else {
                notifBody =
                    "${removeGarbage(globals.user.notesEvolution["added"][0]["nom"])} en ${removeGarbage(globals.user.notesEvolution["added"][0]["matieres"])} : ${globals.user.notesEvolution["added"][0]["note"]}";
              }
            }
          } else if (globals.user.notesEvolution["added"].isEmpty &&
              !globals.user.notesEvolution["changed"].isEmpty) {
            if (globals.user.notesEvolution["changed"].length > 1) {
              notifTitle = "Des notes ont évoluées";
              print(notifTitle);
              for (int i = 0;
                  i < globals.user.notesEvolution["changed"].length;
                  i++) {
                if (i == globals.user.notesEvolution["changed"].length - 1) {
                  notifBody += " et ";
                }

                notifBody +=
                    "${removeGarbage(globals.user.notesEvolution["changed"][i]["data"]["key"])} en ${removeGarbage(globals.user.notesEvolution["changed"][i]["matieres"])} : ${globals.user.notesEvolution["changed"][i]["data"]["v"][0][1][0]} -> ${globals.user.notesEvolution["changed"][i]["data"]["v"][0][1][1]}";

                if (i < globals.user.notesEvolution["changed"].length - 2) {
                  notifBody += ", ";
                }
              }
            } else {
              notifTitle = "Une note a évoluée";
              print(notifTitle);
              notifBody =
                  "${removeGarbage(globals.user.notesEvolution["changed"][0]["data"]["key"])} en ${removeGarbage(globals.user.notesEvolution["changed"][0]["matieres"])} : ${globals.user.notesEvolution["changed"][0]["data"]["v"][0][1][0]} -> ${globals.user.notesEvolution["changed"][0]["data"]["v"][0][1][1]}";
            }
          }
          print(notifTitle);
          print(notifBody);
          if (notifTitle != "" && notifBody != "") {
            showNotification(title: notifTitle, body: notifBody, id: 1);
          } else {
            bool show = false;
            if (nId == "") {
              print("nId == empty");
              nId = notif["id"];
              show = true;
              await prefs.setString('nid', nId);
            } else if (nId != notif["id"]) {
              print(
                  "let show it : nId = $nId & notif[\"id\"] = ${notif["id"]}");
              show = true;
              nId = notif["id"];
              await prefs.setString('nid', nId);
            }
            if (show)
              showNotification(
                  title: notif["title"],
                  body: notif["content"],
                  id: 3,
                  delay: 5);
          }
        }
        globals.noteLocked = false;
      } else {
        bool show = false;
        if (nId == "") {
          print("nId == empty");
          nId = notif["id"];
          show = true;
          await prefs.setString('nid', nId);
        } else if (nId != notif["id"]) {
          print("let show it : nId = $nId & notif[\"id\"] = ${notif["id"]}");
          show = true;
          nId = notif["id"];
          await prefs.setString('nid', nId);
        }
        if (show)
          showNotification(
              title: notif["title"], body: notif["content"], id: 3, delay: 5);
      }
    }
    // IMPORTANT:  We must signal completion of our task or the OS can punish our app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }).then((int status) {
    print('[BackgroundFetch] configure success: $status');
  }).catchError((e) {
    print('[BackgroundFetch] configure ERROR: $e');
  });
  return;
}

void quickActionsCallback(shortcutType) {
  print(shortcutType);
  switch (shortcutType) {
    case "action_edt":
      globals.selectedPage = 0;
      return;
      break;
    case "action_notes":
      globals.selectedPage = 1;
      return;
      break;
    case "action_presence":
      globals.selectedPage = 3;
      return;
      break;
    case "action_offline":
      globals.isConnected = false;
      return;
      break;
    default:
      return;
  }
}

const platform = const MethodChannel('eu.araulin.devinci/channel');

Future<void> changeIcon(int iconId) async {
  try {
    await platform.invokeMethod('changeIcon', iconId);
  } catch (exception, stacktrace) {
    reportError(exception, stacktrace);
  }
}

Future<void> dialog(
    {String title = "",
    String content = "",
    String ok = "",
    String no = "",
    Function callback}) async {
  try {
    bool res = await platform.invokeMethod('showDialog',
        {"title": title, "content": content, "ok": ok, "cancel": no});
    callback(res);
  } catch (exception, stacktrace) {
    reportError(exception, stacktrace);
  }
}

Future<String> downloadDocuments(String url, String filename) async {
  HttpClient client = new HttpClient();
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  final String path = directory.path;

  var fileSave = new File(path + '/' + removeDiacritics(filename) + ".pdf");
  if (globals.isConnected) {
    if (await fileSave.exists()) {
      return fileSave.path;
    }
    //check if all tokens are still valid:
    if (globals.user.tokens["SimpleSAML"] != "" &&
        globals.user.tokens["alv"] != "" &&
        globals.user.tokens["uids"] != "" &&
        globals.user.tokens["SimpleSAMLAuthToken"] != "" &&
        globals.user.error == false) {
      globals.user.error = false;
      globals.user.code = 200;

      HttpClientRequest request = await client.getUrl(
        Uri.parse(url),
      );
      //request.followRedirects = false;
      request.cookies.addAll([
        new Cookie('alv', globals.user.tokens["alv"]),
        new Cookie('SimpleSAML', globals.user.tokens["SimpleSAML"]),
        new Cookie('uids', globals.user.tokens["uids"]),
        new Cookie(
            'SimpleSAMLAuthToken', globals.user.tokens["SimpleSAMLAuthToken"]),
      ]);
      HttpClientResponse response = await request.close();
      if (response.headers.value("content-type").indexOf("html") > -1) {
        //c'est du html, mais bordel ou est le fichier ?
        String body = await response.transform(utf8.decoder).join();
        print(body);
      } else {
        var bytes = await consolidateHttpClientResponseBytes(response);
        await fileSave.writeAsBytes(bytes);
        return fileSave.path;
      }
    } else {
      globals.user.error = true;
      globals.user.code = 400;
      throw Exception("missing parameters");
    }
  } else if (await fileSave.exists()) {
    return fileSave.path;
  } else {
    final snackBar = SnackBar(content: Text('Non disponible hors ligne'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(globals.currentContext).showSnackBar(snackBar);
  }
  return "";
}

fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String coursListToJson() {
  String j = '[';
  for (int i = 0; i < globals.customCours.length; i++) {
    Cours c = globals.customCours[i];
    j += json.encode({
      'type': c.type,
      'title': c.title,
      'prof': c.prof,
      'location': c.location,
      'site': c.site,
      'from': c.from.millisecondsSinceEpoch,
      'to': c.to.millisecondsSinceEpoch,
      'isAllDay': c.isAllDay,
      'flag': c.flag,
      'uid': c.uid,
      'groupe': c.groupe
    });
    if (i != globals.customCours.length - 1) j += ",";
  }
  j += ']';
  return j;
}

Future<List<Cours>> jsonToCoursList() async {
  globals.customCours = new List<Cours>();
  String j =
      await globals.store.record('customCours').get(globals.db) as String ??
          "[]";
  List<dynamic> jj = json.decode(j);
  for (int i = 0; i < jj.length; i++) {
    Map<String, dynamic> jjj = jj[i];
    Cours c = new Cours(
        jjj['type'],
        jjj['title'],
        jjj['prof'],
        jjj['location'],
        jjj['site'],
        DateTime.fromMillisecondsSinceEpoch(jjj['from']),
        DateTime.fromMillisecondsSinceEpoch(jjj['to']),
        Colors.blue,
        jjj['isAllDay'],
        jjj['flag'],
        jjj['uid'],
        jjj['groupe']);
    globals.customCours.add(c);
  }
  return globals.customCours;
}
