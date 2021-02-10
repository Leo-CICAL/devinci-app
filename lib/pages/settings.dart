import 'dart:convert';
import 'dart:io';
import 'package:about/about.dart';
import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:matomo/matomo.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:f_logs/f_logs.dart';
import 'package:wiredash/wiredash.dart';

// ignore: must_be_immutable
class SettingsPage extends TraceableStatefulWidget {
  SettingsPage({Key key, this.scrollController}) : super(key: key);

  ScrollController scrollController;

  @override
  _SettingsPageState createState() => _SettingsPageState(scrollController);
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController scrollController;
  _SettingsPageState(this.scrollController);

  @override
  void initState() {
    super.initState();
    //SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {
    var packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    appVersion += ' b' + packageInfo.buildNumber;
    theme = globals.prefs.getString('theme') ?? 'system';
  }

  String appVersion = '';
  String theme = 'system';

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        globals.currentTheme.isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        globals.currentTheme.isDark());

    return Material(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          brightness: MediaQuery.of(context).platformBrightness,
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 28),
            child: Text(
              'settings',
              style: Theme.of(context).textTheme.headline1,
            ).tr(),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            shrinkWrap: true,
            controller: scrollController,
            children: <Widget>[
              Platform.isIOS
                  ? (Column(
                      children: [
                        TitleSection('icon_change'),
                        Container(
                          margin: EdgeInsets.only(top: 18, bottom: 18),
                          height: 100.0,
                          child: ListView(
                            // This next line does the trick.
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 18),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    changeIcon(0);
                                  }), // handle your onTap here
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/icon_blanc_a.png'),
                                    radius: 50,
                                  ),
                                ),
                                height: 100,
                                width: 100,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 18),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    changeIcon(1);
                                  }), // handle your onTap here
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/icon_noir_a.png'),
                                    radius: 50,
                                  ),
                                ),
                                height: 100,
                                width: 100,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 18),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    changeIcon(2);
                                  }), // handle your onTap here
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/icon_blanc_b.png'),
                                    radius: 50,
                                  ),
                                ),
                                height: 100,
                                width: 100,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 18, right: 18),
                                child: InkWell(
                                  onTap: () => setState(() {
                                    changeIcon(3);
                                  }), // handle your onTap here
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/icon_noir_b.png'),
                                    radius: 50,
                                  ),
                                ),
                                height: 100,
                                width: 100,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
                  : SizedBox.shrink(),
              //TitleSection("Paramètres avancés"),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                height: (6 * 46).toDouble(),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    )),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'offline',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Switch.adaptive(
                              value: !globals.isConnected,
                              onChanged: (bool value) {
                                setState(() {
                                  globals.isConnected = !globals.isConnected;
                                  globals.prefs.setBool(
                                      'isConnected', globals.isConnected);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'theme',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 9),
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                value: theme,
                                icon: Icon(Icons.expand_more_rounded),
                                iconSize: 24,
                                elevation: 16,
                                style: Theme.of(context).textTheme.subtitle1,
                                underline: Container(
                                  height: 0,
                                  color: Colors.transparent,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    theme = newValue;
                                    globals.prefs.setString('theme', newValue);
                                    if (newValue != 'system') {
                                      globals.currentTheme
                                          .setDark(newValue == 'dark');
                                    } else {
                                      globals.currentTheme.setDark(
                                          MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark);
                                    }
                                  });
                                },
                                items: <String>[
                                  'system',
                                  'dark',
                                  'light',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value).tr(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'attendance_notif',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Switch.adaptive(
                              value: globals.notifConsent,
                              onChanged: (bool value) {
                                setState(() {
                                  globals.notifConsent = value;
                                  OneSignal.shared
                                      .consentGranted(globals.notifConsent);
                                  globals.prefs.setBool(
                                      'notifConsent', globals.notifConsent);
                                  OneSignal.shared
                                      .consentGranted(globals.notifConsent);
                                  if (globals.notifConsent) {
                                    OneSignal.shared
                                        .promptUserForPushNotificationPermission(
                                            fallbackToSettings: true);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'error_report',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Switch.adaptive(
                              value: globals.crashConsent == 'true',
                              onChanged: (bool value) {
                                setState(() {
                                  if (globals.crashConsent == 'false') {
                                    globals.crashConsent = 'true';
                                    globals.prefs
                                        .setString('crashConsent', 'true');
                                  } else {
                                    globals.crashConsent = 'false';
                                    globals.prefs
                                        .setString('crashConsent', 'false');
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'usage_monitoring',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Switch.adaptive(
                              value: globals.analyticsConsent,
                              onChanged: (bool value) {
                                setState(() {
                                  if (globals.analyticsConsent) {
                                    globals.analyticsConsent = false;
                                    globals.prefs
                                        .setBool('analyticsConsent', false);
                                  } else {
                                    globals.analyticsConsent = true;
                                    globals.prefs
                                        .setBool('analyticsConsent', true);
                                  }
                                });
                                MatomoTracker()
                                    .setOptOut(!globals.analyticsConsent);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        globals.user.reset();
                        Phoenix.rebirth(context);
                      }, // handle your onTap here
                      child: Container(
                        height: 46,
                        margin: EdgeInsets.only(left: 24),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('logout',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.redAccent.shade200))
                                  .tr(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.navigate_next,
                                color: Color(0xffACACAC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 28,
                ),
                height: (7 * 46).toDouble(),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    )),
                child: Column(children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      Wiredash.of(context).show();
                    }, // handle your onTap here
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'write_comment',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await showAboutPage(
                        title: Text('about').tr(),
                        context: context,
                        applicationVersion:
                            'Version {{ version }}, build #{{ buildNumber }}',
                        applicationLegalese:
                            'Copyright © Antoine Raulin, {{ year }}',
                        applicationDescription: Container(
                          height: 160,
                          child: Markdown(
                              padding: const EdgeInsets.all(0),
                              styleSheet: MarkdownStyleSheet(
                                  p: Theme.of(context).textTheme.bodyText2),
                              data: 'app_description'.tr()),
                        ),
                        children: <Widget>[
                          MarkdownPageListTile(
                            filename: 'assets/LICENSE',
                            title: Text('see_license').tr(),
                            icon: Icon(Icons.description_outlined),
                          ),
                          MarkdownPageListTile(
                            filename: 'assets/CONTRIBUTING.md',
                            title: Text('contribution_guide').tr(),
                            icon: Icon(Icons.share_outlined),
                          ),
                          LicensesPageListTile(
                            title: Text('open_source_licenses').tr(),
                            icon: Icon(Icons.favorite_outlined),
                          ),
                          MarkdownPageListTile(
                            filename: 'assets/tos.md',
                            title: Text('TOS_full').tr(),
                            icon: Icon(Icons.gavel_outlined),
                          ),
                          MarkdownPageListTile(
                            filename: 'assets/privacy.md',
                            title: Text('PP').tr(),
                            icon: Icon(Icons.security_outlined),
                          ),
                        ],
                        applicationIcon: SizedBox(
                          width: 100,
                          height: 100,
                          child: Container(
                            child: Center(
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/icon_blanc_a.png'),
                                radius: 50,
                              ),
                            ),
                          ),
                        ),
                      );
                    }, // handle your onTap here
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'about',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      const url = 'https://discord.gg/wttsfQP';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'join_discord',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      const url =
                          'https://github.com/antoineraulin/devinci-app';
                      if (await canLaunch(url)) {
                        await launch(
                          url,
                        );
                      } else {
                        throw 'Could not launch $url';
                      }
                    }, // handle your onTap here
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'support',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      showChangelog(context);
                    }, // handle your onTap here
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'whatsnew',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await globals.prefs.setBool('showcase_notes', true);
                      await globals.prefs.setBool('showcase_agenda', true);
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('show_guide').tr(),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('show_guide_desc').tr(),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK',
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }, // handle your onTap here
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.2,
                        color: Color(0xffACACAC),
                      ))),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'show_guide',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Sentry.captureMessage('Devinci logs sent');
                      var logs = await FLog.exportLogs();
                      final email = Email(
                        body: '',
                        subject: 'Devinci - Logs',
                        recipients: ['devinci@araulin.eu'],
                        attachmentPaths: [logs.path],
                        isHTML: false,
                      );

                      await FlutterEmailSender.send(email);
                    }, // handle your onTap here
                    child: Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'dump_logs',
                              style: Theme.of(context).textTheme.subtitle1,
                            ).tr(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.navigate_next,
                                color: Color(0xffACACAC)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 28,
                  bottom: 28,
                ),
                height: (4 * 46).toDouble(),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    )),
                child: Column(children: <Widget>[
                  StatusComponent(),
                  VersionComponent(),
                  IdComponent(),
                  Container(
                    height: 46,
                    margin: EdgeInsets.only(left: 24),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('footer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              )).tr(),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusComponent extends StatefulWidget {
  StatusComponent({Key key}) : super(key: key);

  @override
  _StatusComponentState createState() => _StatusComponentState();
}

class _StatusComponentState extends State<StatusComponent> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  String state = 'verifying';

  void runBeforeBuild() async {
    try {
      var client = HttpClient();
      var uri = Uri.parse('https://devinci.antoineraulin.com/health');
      var req = await client.getUrl(uri);
      var res = await req.close();
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        if (body == '"OK"') {
          setState(() {
            state = 'connected';
          });
        } else {
          setState(() {
            state = 'not_connected';
          });
        }
      } else {
        setState(() {
          state = 'not_connected';
        });
      }
    } catch (e) {
      setState(() {
        state = 'not_connected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: EdgeInsets.only(left: 24),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 0.2,
        color: Color(0xffACACAC),
      ))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'Notifications : ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: state.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: state == 'connected'
                          ? Theme.of(context).accentColor
                          : (state == 'not_connected'
                              ? Colors.redAccent.shade200
                              : Theme.of(context).textTheme.bodyText1.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VersionComponent extends StatefulWidget {
  VersionComponent({Key key}) : super(key: key);

  @override
  _VersionComponentState createState() => _VersionComponentState();
}

class _VersionComponentState extends State<VersionComponent> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {
    var packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    appVersion += ' b' + packageInfo.buildNumber;
    setState(() {
      show = true;
    });
  }

  String appVersion = '';
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: EdgeInsets.only(left: 24),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 0.2,
        color: Color(0xffACACAC),
      ))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text('Version: ' + (show ? appVersion : '...'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                )),
          ),
        ],
      ),
    );
  }
}

class IdComponent extends StatefulWidget {
  IdComponent({Key key}) : super(key: key);

  @override
  _IdComponentState createState() => _IdComponentState();
}

class _IdComponentState extends State<IdComponent> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {
    try {
      var sub = await OneSignal.shared.getPermissionSubscriptionState();
      var sub2 = sub.subscriptionStatus;
      id = sub2.userId;
    } catch (e) {
      id = '401';
    }
  }

  String id = '';
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var snackBar;
        if (id == '401') {
          // error while retrieving the playerId
          snackBar = SnackBar(content: Text('error_playerid').tr());
        } else {
          await Clipboard.setData(ClipboardData(text: id));
          snackBar = SnackBar(content: Text('copied').tr(args: [id]));
        }
        await showSnackBar(snackBar, forceOneContext: true);
      }, // handle your onTap here
      child: Container(
        height: 46,
        margin: EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 0.2,
          color: Color(0xffACACAC),
        ))),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('copy_player_id',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  )).tr(),
            ),
          ],
        ),
      ),
    );
  }
}
