import 'dart:async';

import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/extra/globals.dart' as globals;

class PresencePage extends StatefulWidget {
  PresencePage({Key key}) : super(key: key);

  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  bool show = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ButtonState buttonState = ButtonState.normal;

  void _onRefresh() async {
    print("refresh");
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
                    padding: const EdgeInsets.only(top: 62),
                    child: Center(
                      child: Text(globals.user.presence["title"],
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Center(
                      child: Text("—",
                          style: Theme.of(context).textTheme.headline2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Center(
                      child: Text(globals.user.presence["prof"],
                          style: Theme.of(context).textTheme.bodyText2),
                    ),
                  ),
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
                          new Timer(const Duration(milliseconds: 2000), () {
                            setState(() {
                              buttonState = ButtonState.error;
                            });
                            Timer(
                                Duration(milliseconds: 500),
                                () => setState(() {
                                      buttonState = ButtonState.normal;
                                    }));
                          });
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
                ],
              ),
            ),
          )
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }
}
