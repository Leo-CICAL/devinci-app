import 'dart:convert';
import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:matomo/matomo.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:package_info/package_info.dart';
import 'dart:typed_data';
import 'package:devinci/libraries/feedback/feedback.dart';
import 'package:sembast/sembast.dart';
import 'package:devinci/extra/classes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void l(var msg) {
  //stand for log
  if (!kReleaseMode) {
    //app is not in release mode
    print(msg);
  }
}

double getMatMoy(var elem) {
  if (elem['ratt'] != null) {
    if (elem['moy'] > elem['ratt']) {
      return elem['moy'];
    } else {
      return elem['ratt'];
    }
  } else {
    if (elem['moy'] != null) {
      return elem['moy'];
    } else {
      if (!globals.asXxMoy) {
        globals.asXxMoy = true;
      }
      return null;
    }
  }
}

String removeGarbage(String text) {
  var s = text.split(' ');
  var res = '';
  for (var i = 1; i < s.length; i++) {
    res += s[i] + (i == s.length - 1 ? '' : ' ');
  }
  return res;
}

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

Future<List<Cours>> parseIcal(String icsUrl, {bool load = false}) async {
  var results = <Cours>[];
  var client = HttpClient();
  var body = '';
  if (globals.isConnected && load) {
    var req = await client.getUrl(Uri.parse(icsUrl));
    var res = await req.close();

    body = await res.transform(utf8.decoder).join();
    if (res.statusCode == 200) {
      await globals.store.record('ical').put(globals.db, body);
    } else {
      body = await globals.store.record('ical').get(globals.db) as String ?? '';
      if (body == '') {
        throw Exception('error ${res.statusCode}');
      }
    }
  } else {
    body = await globals.store.record('ical').get(globals.db) as String ?? '';
    if (body == '') {
      if (globals.isConnected) {
        var req = await client.getUrl(Uri.parse(icsUrl));
        var res = await req.close();

        body = await res.transform(utf8.decoder).join();
        if (res.statusCode == 200) {
          await globals.store.record('ical').put(globals.db, body);
        } else {
          body = await globals.store.record('ical').get(globals.db) as String ??
              '';
          if (body == '') {
            throw Exception('error ${res.statusCode}');
          }
        }
      } else {
        throw Exception('no backup');
      }
    }
  }
  var mainReg = RegExp(r'BEGIN:VEVENT([\s\S]*?)END:VEVENT', multiLine: true);

  if (mainReg.hasMatch(body)) {
    var vevents = mainReg.allMatches(body);
    // l(vevents);
    // l(vevents.length);
    vevents.forEach((vevent) {
      //l('new   ');
      var veventBody = vevent.group(1);
      //l(veventBody);
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
      dtstart = RegExp(r'DTSTART:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('DTSTART:', '');
      dtend = RegExp(r'DTEND:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('DTEND:', '');

      location = RegExp(r'LOCATION:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('LOCATION:', '');
      site = RegExp(r'SITE:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('SITE:', '');
      prof = RegExp(r'PROF:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('PROF:', '');
      title = RegExp(r'TITLE:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('TITLE:', '');
      typecours = RegExp(r'TYPECOURS:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('TYPECOURS:', '');
      flag = RegExp(r'FLAGPRESENTIEL:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('FLAGPRESENTIEL:', '');
      uid = RegExp(r'UID:.*')
          .firstMatch(veventBody)
          .group(0)
          .replaceFirst('UID:', '');
      var regExp = RegExp(r'GROUPE:.*');
      groupe =
          regExp.firstMatch(veventBody).group(0).replaceFirst('GROUPE:', '');

      if (location == 'SANS SALLE') {
        site = '';
      }
      var color = (globals.currentTheme.isDark()
          ? Colors.redAccent
          : Colors.red.shade700);
      if (flag == 'distanciel') {
        color = (globals.currentTheme.isDark()
            ? Color(0xffFFDE03)
            : Color(0xffFF8A5C));
      } else if (flag == 'presentiel') {
        color = Colors.teal;
      }
      results.add(Cours(
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
    //          '$title' +
    //          (prof != '' ? '\n$prof\n' : '\n') +
    //          '$location $site'
  } else {
    throw Exception('no vevents in body');
  }
  results.addAll(await jsonToCoursList());
  return results;
}

bool get isInDebugMode {
  // Assume you're in production mode.
  var inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

/// Reports [error] along with its [stackTrace] to Sentry.io.
Future<Null> reportError(dynamic error, dynamic stackTrace) async {
  l('Caught error: $error');
  l(stackTrace);
  var err = error.toString();
  if (Platform.isAndroid || Platform.isIOS) {
    var packageInfo = await PackageInfo.fromPlatform();
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      err +=
          '\ndevice info : ${iosInfo.name} : ${iosInfo.model} \n ios : ${iosInfo.systemVersion}\n physical device : ${iosInfo.isPhysicalDevice}';
    } else {
      var androidInfo = await deviceInfo.androidInfo;

      err +=
          '\ndevice info : ${androidInfo.product}:${androidInfo.brand} \n android : ${androidInfo.version.release}\n physical device : ${androidInfo.isPhysicalDevice}';
    }
    err +=
        '\n appName : ${packageInfo.appName}\n packageName : ${packageInfo.packageName}\n version : ${packageInfo.version}\n buildNumber : ${packageInfo.buildNumber}\n ';
  }
  var consent = globals.prefs.getString('crashConsent');
  if (consent == 'true') {
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
    Scaffold.of(globals.getScaffold()).showSnackBar(snackBar);
  }
}

void reportToCrash(var err, StackTrace stackTrace) async {
  final snackBar = SnackBar(
    content: Text('Une erreur est survenue'),
    action: SnackBarAction(
        label: 'Ajouter des informations',
        onPressed: () async {
          globals.feedbackError = err.toString();
          globals.feedbackStackTrace = stackTrace;
          BetterFeedback.of(globals.getScaffold()).show();
        }),
  );
  Scaffold.of(globals.getScaffold()).showSnackBar(snackBar);
  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode) {
    l(stackTrace);
    l('in dev mode. Not sending report to Sentry.');
    return;
  }
  if (globals.crashConsent == 'true') {
    l('Reporting to Sentry...');
    await Sentry.captureException(
      err,
      stackTrace: stackTrace,
    );
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
  final path = directory.path;
  var attachment = File(path + '/devinci_f.png');
  var attachmentNotes = File(path + '/devinci_n.txt');
  await attachment.writeAsBytes(feedbackScreenshot);
  await attachmentNotes.writeAsString(globals.feedbackNotes);
  //l(attachment.path);
  final email = Email(
    body:
        '$feedbackText\n\n Erreur:${globals.feedbackError}\n StackTrace:${globals.feedbackStackTrace.toString()}\n eventId : ${globals.eventId}',
    subject: 'Devinci - Erreur',
    recipients: ['antoine@araulin.eu'],
    attachmentPaths: [attachment.path, attachmentNotes.path],
    isHTML: false,
  );

  await FlutterEmailSender.send(email);
}

void quickActionsCallback(shortcutType) {
  l(shortcutType);
  switch (shortcutType) {
    case 'action_edt':
      globals.selectedPage = 0;
      return;
      break;
    case 'action_notes':
      globals.selectedPage = 1;
      return;
      break;
    case 'action_presence':
      globals.selectedPage = 3;
      return;
      break;
    case 'action_offline':
      globals.isConnected = false;
      return;
      break;
    default:
      return;
  }
}

const platform = MethodChannel('eu.araulin.devinci/channel');

Future<void> changeIcon(int iconId) async {
  try {
    await platform.invokeMethod('changeIcon', iconId);
  } catch (exception, stacktrace) {
    await reportError(exception, stacktrace);
  }
}

Future<void> setICal(String url) async {
  try {
    if (Platform.isIOS) {
      await platform.invokeMethod('setICal', url);
    } else {
      await globals.prefs.setString('ical', url);
    }
  } catch (exception, stacktrace) {
    await reportError(exception, stacktrace);
  }
}

Future<void> dialog(
    {String title = '',
    String content = '',
    String ok = '',
    String no = '',
    Function callback}) async {
  try {
    var res = await platform.invokeMethod('showDialog',
        {'title': title, 'content': content, 'ok': ok, 'cancel': no});
    callback(res);
  } catch (exception, stacktrace) {
    await reportError(exception, stacktrace);
  }
}

void showGDPR(BuildContext context) async {
  var notif = false;
  if (Platform.isAndroid) {
    notif = true;
  }
  var show_notif = false;
  var bug = true;
  var show_bug = false;
  var analytics = true;
  var show_analytics = false;
  await showDialog<bool>(
      context: context,
      builder: (BuildContext context2) {
        return StatefulBuilder(builder: (context2, setState) {
          return SimpleDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text('gdpr_title',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headline1.color))
                .tr(),
            children: <Widget>[
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  child: Text('gdpr_consent',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.headline1.color))
                      .tr(),
                ),
              ),
              SwitchListTile(
                value: notif,
                activeColor: Theme.of(context).accentColor,
                secondary: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: globals.currentTheme.isDark()
                        ? Colors.white.withOpacity(0.2)
                        : Theme.of(context).accentColor.withOpacity(0.15),
                  ),
                  child: Icon(Icons.notifications_active_outlined,
                      color: Theme.of(context).textTheme.headline1.color,
                      size: 18),
                ),
                onChanged: (bool value) {
                  setState(() {
                    notif = value;
                    if (notif == true) {
                      OneSignal.shared.promptUserForPushNotificationPermission(
                          fallbackToSettings: true);
                    }
                  });
                },
                title: RichText(
                  text: TextSpan(
                    text: 'attendance_notif'.tr() + '\n',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: globals.currentTheme.isDark()
                            ? Colors.blueGrey[100]
                            : Colors.blueGrey[800]),
                    children: <InlineSpan>[
                      show_notif
                          ? WidgetSpan(child: SizedBox.shrink())
                          : TextSpan(
                              text: 'more_about'.tr(),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    show_notif = true;
                                    show_bug = false;
                                    show_analytics = false;
                                  });
                                },
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: globals.currentTheme.isDark()
                                      ? Colors.blueGrey[200]
                                      : Colors.blueGrey[600])),
                    ],
                  ),
                ),
                subtitle: !show_notif
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            show_notif = false;
                          });
                        },
                        child: Text('notif_more',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: globals.currentTheme.isDark()
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[600]))
                            .tr(),
                      ),
              ),
              SwitchListTile(
                value: bug,
                activeColor: Theme.of(context).accentColor,
                secondary: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: globals.currentTheme.isDark()
                        ? Colors.white.withOpacity(0.2)
                        : Theme.of(context).accentColor.withOpacity(0.15),
                  ),
                  child: Icon(Icons.bug_report_outlined,
                      color: Theme.of(context).textTheme.headline1.color,
                      size: 18),
                ),
                onChanged: (bool value) {
                  setState(() {
                    bug = value;
                  });
                },
                title: RichText(
                  text: TextSpan(
                    text: 'error_report'.tr() + '\n',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: globals.currentTheme.isDark()
                            ? Colors.blueGrey[100]
                            : Colors.blueGrey[800]),
                    children: <InlineSpan>[
                      show_bug
                          ? WidgetSpan(child: SizedBox.shrink())
                          : TextSpan(
                              text: 'more_about'.tr(),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    show_bug = true;
                                    show_analytics = false;
                                    show_notif = false;
                                  });
                                },
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: globals.currentTheme.isDark()
                                      ? Colors.blueGrey[200]
                                      : Colors.blueGrey[600])),
                    ],
                  ),
                ),
                subtitle: !show_bug
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            show_bug = false;
                          });
                        },
                        child: Text('crash_more',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: globals.currentTheme.isDark()
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[600]))
                            .tr(),
                      ),
              ),
              SwitchListTile(
                value: analytics,
                activeColor: Theme.of(context).accentColor,
                secondary: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: globals.currentTheme.isDark()
                        ? Colors.white.withOpacity(0.2)
                        : Theme.of(context).accentColor.withOpacity(0.15),
                  ),
                  child: Icon(Icons.insights_rounded,
                      color: Theme.of(context).textTheme.headline1.color,
                      size: 18),
                ),
                onChanged: (bool value) {
                  setState(() {
                    analytics = value;
                  });
                },
                title: RichText(
                  text: TextSpan(
                    text: 'usage_monitoring'.tr() + '\n',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: globals.currentTheme.isDark()
                            ? Colors.blueGrey[100]
                            : Colors.blueGrey[800]),
                    children: <InlineSpan>[
                      show_analytics
                          ? WidgetSpan(child: SizedBox.shrink())
                          : TextSpan(
                              text: 'more_about'.tr(),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    show_analytics = true;
                                    show_notif = false;
                                    show_bug = false;
                                  });
                                },
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: globals.currentTheme.isDark()
                                      ? Colors.blueGrey[200]
                                      : Colors.blueGrey[600])),
                    ],
                  ),
                ),
                subtitle: !show_analytics
                    ? SizedBox.shrink()
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            show_analytics = false;
                          });
                        },
                        child: Text('analytics_more',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: globals.currentTheme.isDark()
                                        ? Colors.blueGrey[200]
                                        : Colors.blueGrey[600]))
                            .tr(),
                      ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  child: Text('gdpr_footer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: globals.currentTheme.isDark()
                            ? Colors.blueGrey[100]
                            : Colors.blueGrey[800],
                      )).tr(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SimpleDialogOption(
                      onPressed: () {
                        setState(() {
                          notif = false;
                          bug = false;
                          analytics = false;
                        });
                      },
                      child: Center(
                          child: Text('refuse_all',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              )).tr()),
                    ),
                  ),
                  Expanded(
                    child: SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context2, true);
                      },
                      child: Center(
                          child: Text('confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).textTheme.headline1.color,
                              )).tr()),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      });
  l('notif1 ${notif}');
  l('crash1 ${bug}');
  l('ana1 ${analytics}');
  globals.notifConsent = notif;
  await globals.prefs.setBool('notifConsent', globals.notifConsent);
  if (globals.notifConsent) {
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
  }
  await OneSignal.shared.consentGranted(notif);
  globals.crashConsent = bug ? 'true' : 'false';
  await globals.prefs.setString('crashConsent', globals.crashConsent);
  globals.analyticsConsent = analytics;
  await globals.prefs.setBool('analyticsConsent', globals.analyticsConsent);
  MatomoTracker().setOptOut(!globals.analyticsConsent);

  l('notif ${globals.notifConsent}');
  l('crash ${globals.crashConsent}');
  l('ana ${globals.analyticsConsent}');
}

Future<String> downloadDocuments(String url, String filename) async {
  var client = HttpClient();
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  final path = directory.path;

  var fileSave = File(path + '/' + removeDiacritics(filename) + '.pdf');
  if (globals.isConnected) {
    if (await fileSave.exists()) {
      return fileSave.path;
    }
    //check if all tokens are still valid:
    if (globals.user.tokens['SimpleSAML'] != '' &&
        globals.user.tokens['alv'] != '' &&
        globals.user.tokens['uids'] != '' &&
        globals.user.tokens['SimpleSAMLAuthToken'] != '' &&
        globals.user.error == false) {
      globals.user.error = false;
      globals.user.code = 200;

      var request = await client.getUrl(
        Uri.parse(url),
      );
      //request.followRedirects = false;
      request.cookies.addAll([
        Cookie('alv', globals.user.tokens['alv']),
        Cookie('SimpleSAML', globals.user.tokens['SimpleSAML']),
        Cookie('uids', globals.user.tokens['uids']),
        Cookie(
            'SimpleSAMLAuthToken', globals.user.tokens['SimpleSAMLAuthToken']),
      ]);
      var response = await request.close();
      if (response.headers.value('content-type').contains('html')) {
        //c'est du html, mais bordel ou est le fichier ?
        var body = await response.transform(utf8.decoder).join();
        l(body);
      } else {
        var bytes = await consolidateHttpClientResponseBytes(response);
        await fileSave.writeAsBytes(bytes);
        return fileSave.path;
      }
    } else {
      globals.user.error = true;
      globals.user.code = 400;
      throw Exception('missing parameters');
    }
  } else if (await fileSave.exists()) {
    return fileSave.path;
  } else {
    final snackBar = SnackBar(content: Text('Non disponible hors ligne'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(globals.getScaffold()).showSnackBar(snackBar);
  }
  return '';
}

void fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

String coursListToJson() {
  var j = '[';
  for (var i = 0; i < globals.customCours.length; i++) {
    var c = globals.customCours[i];
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
    if (i != globals.customCours.length - 1) j += ',';
  }
  j += ']';
  return j;
}

Future<List<Cours>> jsonToCoursList() async {
  globals.customCours = <Cours>[];
  var j = await globals.store.record('customCours').get(globals.db) as String ??
      '[]';
  List<dynamic> jj = json.decode(j);
  for (var i = 0; i < jj.length; i++) {
    Map<String, dynamic> jjj = jj[i];
    var c = Cours(
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

Future<HttpClientResponse> devinciRequest(
    {String endpoint,
    String method = 'GET',
    bool followRedirects = false,
    List<List<String>> headers,
    String data,
    String replacementUrl = '',
    bool log = false}) async {
  if (globals.user.tokens['SimpleSAML'] != '' &&
      globals.user.tokens['alv'] != '' &&
      globals.user.tokens['uids'] != '' &&
      globals.user.tokens['SimpleSAMLAuthToken'] != '') {
    var client = HttpClient();
    if (log) l('[0]');
    var uri = Uri.parse(replacementUrl == ''
        ? 'https://www.leonard-de-vinci.net/' + endpoint
        : replacementUrl);
    if (log) l('[1] ${endpoint}');
    var req =
        method == 'GET' ? await client.getUrl(uri) : await client.postUrl(uri);
    if (log) l('[1] ${req}');
    req.followRedirects = followRedirects;
    req.cookies.addAll([
      Cookie('alv', globals.user.tokens['alv']),
      Cookie('SimpleSAML', globals.user.tokens['SimpleSAML']),
      Cookie('uids', globals.user.tokens['uids']),
      Cookie('SimpleSAMLAuthToken', globals.user.tokens['SimpleSAMLAuthToken']),
    ]);
    if (headers != null) {
      for (var header in headers) {
        req.headers.set(header[0], header[1]);
      }
    }
    if (data != null) {
      req.write(data);
    }
    if (log) l('[2]');
    return await req.close();
  } else {
    return null;
  }
}

void catcher(var exception, StackTrace stacktrace, String endpoint) async {
  if (globals.isConnected) {
    var res = await devinciRequest(
      endpoint: endpoint,
    );
    if (res != null) {
      globals.feedbackNotes = await res.transform(utf8.decoder).join();
    }
  }
  await reportError(exception, stacktrace);
}
