import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

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
  }

  static const platform =
      const MethodChannel('eu.araulin.devinci/channel');

  Future<void> changeIcon1() async {
    try {
      final int result = await platform.invokeMethod('changeIcon1');
    } on PlatformException catch (e) {}
  }

  Future<void> changeIcon2() async {
    try {
      final int result = await platform.invokeMethod('changeIcon2');
    } on PlatformException catch (e) {}
  }

  Future<void> changeIcon3() async {
    try {
      final int result = await platform.invokeMethod('changeIcon3');
    } on PlatformException catch (e) {}
  }

  Future<void> changeIcon4() async {
    try {
      final int result = await platform.invokeMethod('changeIcon4');
    } on PlatformException catch (e) {}
  }

  String appVersion = "";

  @override
  Widget build(BuildContext context) {
    Widget TitleSection(String title) {
      return Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: getColor("text", context),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )
            ],
          ));
    }

    return Material(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          brightness: MediaQuery.of(context).platformBrightness,
          centerTitle: false,
          backgroundColor: getColor("top", context),
          title: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              "Paramètres",
              style: TextStyle(
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 36),
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
                          changeIcon1();
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
                          changeIcon2();
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
                          changeIcon3();
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
                          changeIcon4();
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
              Padding(
                padding: EdgeInsets.only(left: 16, top: 18, right: 16),
                child: MaterialButton(
                    onPressed: () async {
                      globals.user.reset();
                      Phoenix.rebirth(context);
                    },
                    child: Text("Déconnexion")),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, top: 9, right: 16),
                child: MaterialButton(
                    onPressed: () async {
                      showAboutDialog(
                        context: context,
                        applicationIcon: Image.asset(
                          'assets/icon_blanc_a.png',
                          height: 48,
                          width: 48,
                        ),
                        applicationName: 'Devinci',
                        applicationVersion: appVersion,
                        applicationLegalese: '©2020 Antoine Raulin',
                        children: <Widget>[],
                      );
                    },
                    child: Text("A propos")),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, top: 18, right: 16),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                          "Envoyer des rapports d'incident lorsqu'une erreur survient ? "),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: CupertinoSwitch(
                        value: globals.crashConsent == "true",
                        onChanged: (bool value) {
                          setState(() {
                            if (globals.crashConsent == "false") {
                              globals.crashConsent = "true";
                              globals.storage
                                  .write(key: "crashConsent", value: "true");
                            } else {
                              globals.crashConsent = "false";
                              globals.storage
                                  .write(key: "crashConsent", value: "false");
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, top: 18, right: 16),
                child: MaterialButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await reportError("Test Exception !",
                          StackTrace.fromString("this is a test"));
                    },
                    child: Text("Tester erreur")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
