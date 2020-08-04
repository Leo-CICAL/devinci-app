import 'dart:io';

import 'package:about/about.dart';
import 'package:app_settings/app_settings.dart';
import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.scrollController}) : super(key: key);

  ScrollController scrollController;

  @override
  _SettingsPageState createState() => _SettingsPageState(scrollController);
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController scrollController;
  _SettingsPageState(this.scrollController);

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    int bgIntTime = globals.prefs.getInt('bgTime') ?? 0;

    if (bgIntTime != 0) {
      DateTime bgDate = new DateTime.fromMillisecondsSinceEpoch(bgIntTime);
      bgTime = bgDate.toLocal().toString();
    } else {
      bgTime = 'jamais';
    }
    theme = globals.prefs.getString("theme") ?? "Système";
  }

  String appVersion = "";
  String bgTime = "";
  String theme = "Système";

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
              "Paramètres",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            shrinkWrap: true,
            controller: scrollController,
            children: <Widget>[
              TitleSection("Changement d'icône"),
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
                          backgroundImage: AssetImage('assets/icon_noir_a.png'),
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
                          backgroundImage: AssetImage('assets/icon_noir_b.png'),
                          radius: 50,
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                  ],
                ),
              ),
              TitleSection("Paramètres avancés"),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                height: 460,
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
                            child: Text("Hors connexion",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Switch.adaptive(
                              value: !globals.isConnected,
                              onChanged: (bool value) {
                                setState(() {
                                  globals.isConnected = !globals.isConnected;
                                  globals.prefs.setBool(
                                      "isConnected", globals.isConnected);
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
                            child: Text("Theme",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 9),
                            child: DropdownButton<String>(
                              value: theme,
                              icon: Icon(OMIcons.expandMore),
                              iconSize: 24,
                              elevation: 16,
                              style: Theme.of(context).textTheme.bodyText2,
                              underline: Container(
                                height: 0,
                                color: Colors.transparent,
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  theme = newValue;
                                  globals.prefs.setString("theme", newValue);
                                  if (newValue != "Système") {
                                    globals.currentTheme
                                        .setDark(newValue == "Sombre");
                                  } else {
                                    globals.currentTheme.setDark(
                                        MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark);
                                  }
                                });
                              },
                              items: <String>[
                                'Système',
                                'Sombre',
                                'Clair',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        AppSettings.openAppSettings();
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
                              child: Text("Paramètres des notifications",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
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
                        showAboutPage(
                          title: Text('A propos'),
                          context: context,
                          applicationVersion:
                              'Version {{ version }}, build #{{ buildNumber }}',
                          applicationLegalese:
                              'Copyright © Antoine Raulin, {{ year }}',
                          applicationDescription: const Text(
                            "Devinci est une application qui a pour but de faciliter l'utilisation du portail étudiant du pôle Léonard Devinci.",
                            textAlign: TextAlign.justify,
                          ),
                          children: <Widget>[
                            MarkdownPageListTile(
                              filename: 'assets/LICENSE',
                              title: Text('Voir la license'),
                              icon: Icon(OMIcons.description),
                            ),
                            MarkdownPageListTile(
                              filename: 'assets/CONTRIBUTING.md',
                              title: Text('Le code de contribution'),
                              icon: Icon(OMIcons.share),
                            ),
                            LicensesPageListTile(
                              title: Text('Les licenses open source'),
                              icon: Icon(OMIcons.favorite),
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
                              child: Text("A Propos",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
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
                            child: Text("Rapports d'incident",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Switch.adaptive(
                              value: globals.crashConsent == "true",
                              onChanged: (bool value) {
                                setState(() {
                                  if (globals.crashConsent == "false") {
                                    globals.crashConsent = "true";
                                    globals.prefs
                                        .setString('crashConsent', 'true');
                                  } else {
                                    globals.crashConsent = "false";
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
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await reportError("Test Exception !",
                            StackTrace.fromString("this is a test"));
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
                              child: Text("Test Erreur",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Color(0xffFFDE03)
                                          : Color(0xffFF8A5C))),
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
                    GestureDetector(
                      onTap: () async {
                        dialog(
                            title: "Test",
                            content: "Ceci est un popup de test",
                            ok: "D'accord",
                            no: "Pas d'accord",
                            callback: (bool res) {
                              print(res);
                            });
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
                              child: Text("Test popup",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Color(0xffFFDE03)
                                          : Color(0xffFF8A5C))),
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
                    GestureDetector(
                      onTap: () async {
                        globals.user.reset();
                        Phoenix.rebirth(context);
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
                              child: Text("Déconnexion",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent.shade200)),
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
                            child: Text("Version: $appVersion",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 46,
                      margin: EdgeInsets.only(left: 24),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("Date fetch: $bgTime",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
