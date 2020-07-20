import 'dart:convert';
import 'dart:io';
import 'package:devinci/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:http/http.dart';
import 'package:ota_update/ota_update.dart';
import 'package:sentry/sentry.dart' as Sentry;
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:package_info/package_info.dart';
import 'dart:typed_data';
import 'package:devinci/libraries/feedback/feedback.dart';

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
      return null as double;
    }
  }
}

removeGarbage(text) {
  List<String> s = text.split(" ");
  String res = "";
  for (var i = 1; i < s.length; i++) {
    res += s[i] + " ";
  }
  //res = truncateWithEllipsis(18, res);
  return res;
}

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

getColor(type, context) {
  switch (type) {
    case "top":
      return MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Color(0xff121212)
          : Color(0xffFAFAFA);
    case "background":
      return MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Color(0xff121212)
          : Color(0xffFAFAFA);
    case "card":
      return MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Color(0xff1E1E1E)
          : Colors.white;
    case "text":
      return MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black;
    case "primary":
      return MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.tealAccent[200]
          : Colors.teal[800];
      break;
    default:
      return Theme.of(context).primaryColor;
  }
}

Future<List<Cours>> parseIcal(String icsUrl) async {
  List<Cours> results = new List<Cours>();
  HttpClient client = new HttpClient();

  HttpClientRequest req = await client.getUrl(Uri.parse(icsUrl));
  HttpClientResponse res = await req.close();

  String body = await res.transform(utf8.decoder).join();

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
      String dtstart, dtend, location, site, prof, title, typecours;
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
      if (site != "") {
        site = "- site : $site";
      }
      if (location == "SANS SALLE") {
        site = "";
      }
      results.add(new Cours(
          "($typecours) $title" +
              (prof != "" ? "\n$prof\n" : "\n") +
              "$location $site",
          DateTime.parse(dtstart),
          DateTime.parse(dtend),
          Colors.teal,
          false));
    });
  } else {
    throw Exception("no vevents in body");
  }

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
  String consent = await globals.storage.read(key: "crashConsent");
  if (consent == null) {
    showDialog<void>(
      context: globals.currentContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text("Erreur"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: 'Félicitations, vous avez cassé cette ',
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: "putain d'",
                              style: TextStyle(
                                color: Colors.black,
                                backgroundColor: Colors.black,
                              ),
                            ),
                            TextSpan(
                                text:
                                    " application. Je parie que vous attendez que l'on vous dise ce qui s'est passé : ¯\\_(ツ)_/¯"),
                          ],
                        ),
                      ),
                      Text(
                        '\nCependant, si vous souhaitez que nous resolvions cette erreur, vous pouvez accepter que l\'application partage les informations liées au problème avec nous.',
                        style: TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('Refuser'),
                    onPressed: () async {
                      await globals.storage
                          .write(key: "crashConsent", value: "false");
                      Navigator.of(context).pop();
                      return;
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Accepter'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await globals.storage
                          .write(key: "crashConsent", value: "true");
                      if (isInDebugMode) {
                        print(stackTrace);
                        print('In dev mode. Not sending report to Sentry.io.');
                        return;
                      }

                      print('Reporting to Sentry.io...');

                      final Sentry.SentryResponse response =
                          await globals.sentry.captureException(
                        exception: err,
                        stackTrace: stackTrace,
                      );

                      if (response.isSuccessful) {
                        print('Success! Event ID: ${response.eventId}');
                        globals.eventId = response.eventId;
                      } else {
                        print(
                            'Failed to report to Sentry.io: ${response.error}');
                      }

                      return;
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: Text('Erreur'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: 'Félicitations, vous avez cassé cette ',
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              color: getColor('text', context)),
                          children: <TextSpan>[
                            TextSpan(
                              text: "putain d'",
                              style: TextStyle(
                                color: getColor("text", context),
                                backgroundColor: getColor("text", context),
                              ),
                            ),
                            TextSpan(
                                text:
                                    " application. Je parie que vous attendez que l'on vous dise ce qui s'est passé : ¯\\_(ツ)_/¯"),
                          ],
                        ),
                      ),
                      Text(
                        '\nCependant, si vous souhaitez que nous resolvions cette erreur, vous pouvez accepter que l\'application partage les informations liées au problème avec nous.',
                        style: TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            color: getColor('text', context)),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Refuser'),
                    onPressed: () async {
                      await globals.storage
                          .write(key: "crashConsent", value: "false");
                      Navigator.of(context).pop();
                      return;
                    },
                  ),
                  FlatButton(
                    child: Text('Accepter'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await globals.storage
                          .write(key: "crashConsent", value: "true");
                      if (isInDebugMode) {
                        print(stackTrace);
                        print('In dev mode. Not sending report to Sentry.io.');
                        return;
                      }

                      print('Reporting to Sentry.io...');

                      final Sentry.SentryResponse response =
                          await globals.sentry.captureException(
                        exception: err,
                        stackTrace: stackTrace,
                      );

                      if (response.isSuccessful) {
                        print('Success! Event ID: ${response.eventId}');
                        globals.eventId = response.eventId;
                      } else {
                        print(
                            'Failed to report to Sentry.io: ${response.error}');
                      }

                      return;
                    },
                  ),
                ],
              );
      },
    );
  } else if (consent == "true") {
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
      print('In dev mode. Not sending report to Sentry.io.');
      return;
    }

    print('Reporting to Sentry.io...');

    final Sentry.SentryResponse response =
        await globals.sentry.captureException(
      exception: err,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
      globals.eventId = response.eventId;
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  } else {
    final snackBar = SnackBar(
      content: Text(
          'Une erreur est survenue, mais nous n\'avons pas envoyer de rapport d\'incident'),
      action: SnackBarAction(
        label: 'Envoyer',
        onPressed: () async {
          if (isInDebugMode) {
            print(stackTrace);
            print('In dev mode. Not sending report to Sentry.io.');
            return;
          }

          print('Reporting to Sentry.io...');

          final Sentry.SentryResponse response =
              await globals.sentry.captureException(
            exception: err,
            stackTrace: stackTrace,
          );

          if (response.isSuccessful) {
            print('Success! Event ID: ${response.eventId}');
            globals.eventId = response.eventId;
          } else {
            print('Failed to report to Sentry.io: ${response.error}');
          }
          final snackBar = SnackBar(
            content: Text('Envoyé !'),
            action: SnackBarAction(
                label: 'Ajouter des informations',
                onPressed: () async {
                  globals.feedbackError = err;
                  globals.feedbackStackTrace = stackTrace;
                  BetterFeedback.of(globals.currentContext).show();
                }),
          );
          Scaffold.of(globals.currentContext).showSnackBar(snackBar);
        },
      ),
      duration: const Duration(seconds: 6),
    );

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(globals.currentContext).showSnackBar(snackBar);
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

void checkUpdate() async {}
