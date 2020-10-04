import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class PresencePage extends StatefulWidget {
  PresencePage({Key key}) : super(key: key);

  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  bool show = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ButtonState buttonState = ButtonState.normal;

  void runBeforeBuild() async {
    await globals.user.getPresence(force: true);
    if (mounted)
      setState(() {
        show = true;
      });
  }

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void _onRefresh() async {
    await globals.user.getPresence(force: true);
    if (mounted)
      setState(() {
        show = true;
      });
    if (mounted) {
      setState(() {
        _refreshController.refreshCompleted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? CupertinoScrollbar(
            child: SmartRefresher(
              enablePullDown: true,
              header: ClassicHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 62, left: 8, right: 8),
                    child: Center(
                      child: Text(
                          globals.user.presence['type'] == 'none'
                              ? 'Pas de cours prévu.'
                              : globals.user.presence["title"],
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Center(
                      child: Text(
                          globals.user.presence['type'] == 'none' ? '' : "—",
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Center(
                      child: Text(
                          globals.user.presence['type'] == 'none'
                              ? ''
                              : (globals.user.presence["prof"] == ''
                                  ? globals.user.presence["horaires"]
                                  : globals.user.presence["prof"]),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                  ),
                  globals.user.presence["prof"] != ''
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                                globals.user.presence['type'] == 'none'
                                    ? ''
                                    : globals.user.presence["horaires"],
                                style: Theme.of(context).textTheme.bodyText2),
                          ),
                        )
                      : SizedBox.shrink(),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 112, left: 48, right: 48),
                    child: Center(
                        child: {
                      "ongoing": ProgressButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            "présent".toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: globals.currentTheme.isDark()
                                    ? Colors.black
                                    : Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            buttonState = ButtonState.inProgress;
                          });

                          try {
                            await globals.user.setPresence();
                            setState(() {
                              buttonState = ButtonState.normal;
                            });
                          } catch (exception) {
                            setState(() {
                              buttonState = ButtonState.error;
                            });
                            final snackBar = SnackBar(
                              content: Text("Une erreur est survenue"),
                              duration: const Duration(seconds: 6),
                            );

// Find the Scaffold in the widget tree and use it to show a SnackBar.
                            Scaffold.of(globals.currentContext)
                                .showSnackBar(snackBar);
                          }
                        },
                        buttonState: buttonState,
                        backgroundColor: Theme.of(context).accentColor,
                        progressColor: globals.currentTheme.isDark()
                            ? Colors.black
                            : Colors.white,
                      ),
                      "done": ProgressButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: IconTheme(
                            data: Theme.of(context).accentIconTheme,
                            child: Icon(Icons.done),
                          ),
                        ),
                        onPressed: null,
                        buttonState: buttonState,
                        backgroundColor: globals.currentTheme.isDark()
                            ? Color(0xFF313131)
                            : Color(0xFFDFDFDF),
                      ),
                      "notOpen": ProgressButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            "pas encore ouvert".toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onPressed: null,
                        buttonState: buttonState,
                        backgroundColor: globals.currentTheme.isDark()
                            ? Color(0xFF313131)
                            : Color(0xFFDFDFDF),
                      ),
                      "closed": ProgressButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            "cloturé".toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPressed: null,
                        buttonState: buttonState,
                        backgroundColor: globals.currentTheme.isDark()
                            ? Colors.redAccent
                            : Colors.red.shade700,
                      ),
                    }[globals.user.presence["type"]]),
                  ),
                  Visibility(
                    visible: globals.user.presence['zoom'] != '',
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 32, left: 48, right: 48),
                      child: ProgressButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            "ZOOM".toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          String url = globals.user.presence['zoom'];
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                            );
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        buttonState: ButtonState.normal,
                        backgroundColor: globals.currentTheme.isDark()
                            ? Colors.blueAccent.shade200
                            : Color(0xFF2D8CFF),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: globals.user.presence['zoom_pwd'] != '',
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 12, left: 48, right: 48),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Mot de passe : ',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: globals.user.presence['zoom_pwd'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }
}
