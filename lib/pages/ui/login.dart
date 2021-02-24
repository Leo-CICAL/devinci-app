import 'package:about/about.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:devinci/pages/logic/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:devinci/extra/classes.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      didChangeAppLifecycle;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerUsername.dispose();
    myControllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        CustomTheme.instanceOf(context).isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        CustomTheme.instanceOf(context).isDark());

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                statusBarIconBrightness:
                    CustomTheme.instanceOf(context).isDark()
                        ? Brightness.light
                        : Brightness.dark),
            child: LayoutBuilder(builder: (context, constraints) {
              if (!show) {
                return Center(
                    child: CupertinoActivityIndicator(
                  animating: true,
                ));
              } else {
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600
                        ? constraints.maxWidth * 0.3
                        : 28.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: SvgPicture.asset(
                          'assets/devinci.svg',
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                        height: 68,
                        width: 68,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'welcome'.tr(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              key: Key('login_username'),
                              textInputAction: TextInputAction.next,
                              focusNode: usernameFocus,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'user'.tr(),
                                suffixText: '@edu.devinci.fr',
                              ),
                              controller: myControllerUsername,
                              onFieldSubmitted: (term) {
                                fieldFocusChange(
                                    context, usernameFocus, passwordFocus);
                              },
                              validator: validator,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: TextFormField(
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                focusNode: passwordFocus,
                                key: Key('login_password'),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'password'.tr(),
                                ),
                                controller: myControllerPassword,
                                onFieldSubmitted: submit,
                                validator: validator,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: ProgressButton(
                                key: Key('login_connect'),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  child: Text(
                                    'login'.tr().toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: CustomTheme.instanceOf(context)
                                                .isDark()
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ),
                                onPressed: submit,
                                buttonState: buttonState,
                                backgroundColor: Theme.of(context).accentColor,
                                progressColor:
                                    CustomTheme.instanceOf(context).isDark()
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextButton(
                                    onPressed: () async {
                                      const url =
                                          'https://www.leonard-de-vinci.net/lost_password.php';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Text('lost_password',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor))
                                        .tr())),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          ),
          persistentFooterButtons: show
              ? [
                  VersionComponent(),
                  TextButton(
                      key: Key('login_cgu'),
                      child: Text('TOS',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor))
                          .tr(),
                      onPressed: () {
                        showMarkdownPage(
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
                          context: context,
                          applicationName: 'LeoPortail',
                          filename: 'assets/tos.md',
                          title: Text("Conditions générales d'utilisation"),
                          useMustache: false,
                          mustacheValues: null,
                        );
                      }),
                  TextButton(
                      key: Key('login_privacy'),
                      child: Text('PP',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor))
                          .tr(),
                      onPressed: () {
                        showMarkdownPage(
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
                          context: context,
                          applicationName: 'LeoPortail',
                          filename: 'assets/privacy.md',
                          title: Text('Politique de confidentialité'),
                          useMustache: false,
                          mustacheValues: null,
                        );
                      })
                ]
              : [
                  TextButton(
                      key: Key('login_offline'),
                      child: Text('offline_mode',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor))
                          .tr(),
                      onPressed: () {
                        globals.isConnected = false;
                        loginProcess();
                      })
                ],
        ));
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
    appVersion += '#' + packageInfo.buildNumber;
    setState(() {
      show = true;
    });
  }

  String appVersion = '';
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key('login_version'),
      onPressed: null,
      child: Text('V' + (show ? appVersion : '...')),
    );
  }
}
