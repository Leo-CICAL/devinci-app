import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:matomo/matomo.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:f_logs/f_logs.dart';

class PresencePage extends TraceableStatefulWidget {
  final bool inSidePanel;
  PresencePage({Key key, this.inSidePanel}) : super(key: key);

  @override
  _PresencePageState createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  bool show = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ButtonState buttonState = ButtonState.normal;

  var padding = 0.0;

  final PageController _pageController = PageController(
    initialPage: 0,
  );

  void runBeforeBuild() async {
    try {
      await globals.user.getPresence(force: true);
    } catch (e, stacktrace) {
      FLog.info(
          className: '_PresencePageState',
          methodName: 'runBeforeBuild',
          text: 'needs reconnection');
      final snackBar = SnackBar(
        content: Text('reconnecting').tr(),
        duration: const Duration(seconds: 10),
      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
      try {
        await globals.user.getTokens();
      } catch (e, stacktrace) {
        FLog.logThis(
            className: '_PresencePageState',
            methodName: 'runBeforeBuild',
            text: 'exception',
            type: LogLevel.ERROR,
            exception: Exception(e),
            stacktrace: stacktrace);
      }
      await globals.user.getPresence(force: true);
      Scaffold.of(context).removeCurrentSnackBar();
    }
    if (mounted) {
      setState(() {
        show = true;
      });
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (globals.user.presence.isNotEmpty) {
      try {
        _pageController.jumpToPage(globals.user.presenceIndex);
      } catch (e, stacktrace) {
        FLog.logThis(
            className: '_PresencePageState',
            methodName: 'runBeforeBuild',
            text: 'exception',
            type: LogLevel.ERROR,
            exception: Exception(e),
            stacktrace: stacktrace);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void _onRefresh() async {
    try {
      await globals.user.getPresence(force: true);
    } catch (e, stacktrace) {
      FLog.info(
          className: '_PresencePageState',
          methodName: '_onRefresh',
          text: 'needs reconnection');
      final snackBar = SnackBar(
        content: Text('reconnecting').tr(),
        duration: const Duration(seconds: 10),
      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
      try {
        await globals.user.getTokens();
      } catch (e, stacktrace) {
        FLog.logThis(
            className: '_PresencePageState',
            methodName: '_onRefresh',
            text: 'exception',
            type: LogLevel.ERROR,
            exception: Exception(e),
            stacktrace: stacktrace);
      }
      await globals.user.getPresence(force: true);
      Scaffold.of(context).removeCurrentSnackBar();
    }
    if (mounted) {
      setState(() {
        show = true;
      });
    }
    if (mounted) {
      setState(() {
        _refreshController.refreshCompleted();
      });
    }
  }

  List<Widget> pageGen() {
    var res = <Widget>[];
    for (var i = 0; i < globals.user.presence.length; i++) {
      res.add(CupertinoScrollbar(
        child: SmartRefresher(
          enablePullDown: true,
          header: ClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 62, left: 8, right: 8),
                  child: Center(
                    child: Text(
                        globals.user.presence[i]['type'] == 'none'
                            ? 'no_class'.tr()
                            : globals.user.presence[i]['title'],
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: widget.inSidePanel != null
                            ? TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color:
                                    Theme.of(context).textTheme.headline2.color,
                              )
                            : Theme.of(context).textTheme.headline2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Center(
                    child: Text(
                        globals.user.presence[i]['type'] == 'none' ? '' : '—',
                        style: Theme.of(context).textTheme.headline2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Center(
                    child: Text(
                        globals.user.presence[i]['type'] == 'none'
                            ? ''
                            : (globals.user.presence[i]['prof'] == ''
                                ? globals.user.presence[i]['horaires']
                                : globals.user.presence[i]['prof']),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: widget.inSidePanel != null
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    Theme.of(context).textTheme.headline2.color,
                              )
                            : Theme.of(context).textTheme.bodyText1),
                  ),
                ),
                globals.user.presence[i]['prof'] != ''
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text(
                              globals.user.presence[i]['type'] == 'none'
                                  ? ''
                                  : globals.user.presence[i]['horaires'],
                              style: Theme.of(context).textTheme.bodyText2),
                        ),
                      )
                    : SizedBox.shrink(),
                Container(
                  padding: EdgeInsets.only(
                      top: 112,
                      left: widget.inSidePanel != null ? 16 : 48,
                      right: widget.inSidePanel != null ? 16 : 48),
                  child: Center(
                      child: {
                    'ongoing': ProgressButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'ongoing',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: globals.currentTheme.isDark()
                                  ? Colors.black
                                  : Colors.white),
                        ).tr(),
                      ),
                      onPressed: () async {
                        setState(() {
                          buttonState = ButtonState.inProgress;
                        });
                        try {
                          await globals.user.setPresence(i);
                          setState(() {
                            buttonState = ButtonState.normal;
                          });
                        } catch (e, stacktrace) {
                          FLog.info(
                              className: '_PresencePageState',
                              methodName: 'pageGen',
                              text: 'needs reconnection');
                          final snackBar = SnackBar(
                            content: Text('reconnecting').tr(),
                            duration: const Duration(seconds: 10),
                          );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
                          Scaffold.of(context).showSnackBar(snackBar);
                          try {
                            await globals.user.getTokens();
                          } catch (e, stacktrace) {
                            FLog.logThis(
                                className: '_PresencePageState',
                                methodName: 'pageGen',
                                text: 'exception',
                                type: LogLevel.ERROR,
                                exception: Exception(e),
                                stacktrace: stacktrace);
                          }
                          Scaffold.of(context).removeCurrentSnackBar();
                          try {
                            await globals.user.setPresence(i);
                            setState(() {
                              buttonState = ButtonState.normal;
                            });
                          } catch (exception, stacktrace) {
                            FLog.logThis(
                                className: '_PresencePageState',
                                methodName: 'pageGen',
                                text: 'exception',
                                type: LogLevel.ERROR,
                                exception: Exception(e),
                                stacktrace: stacktrace);
                            setState(() {
                              buttonState = ButtonState.error;
                            });
                            final snackBar = SnackBar(
                              content: Text('error_msg').tr(),
                              duration: const Duration(seconds: 6),
                            );

// Find the Scaffold in the widget tree and use it to show a SnackBar.
                            globals.mainScaffoldKey.currentState
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      buttonState: buttonState,
                      backgroundColor: Theme.of(context).accentColor,
                      progressColor: globals.currentTheme.isDark()
                          ? Colors.black
                          : Colors.white,
                    ),
                    'done': ProgressButton(
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
                    'notOpen': ProgressButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'notOpen',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ).tr(),
                      ),
                      onPressed: null,
                      buttonState: buttonState,
                      backgroundColor: globals.currentTheme.isDark()
                          ? Color(0xFF313131)
                          : Color(0xFFDFDFDF),
                    ),
                    'closed': ProgressButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'closed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ).tr(),
                      ),
                      onPressed: null,
                      buttonState: buttonState,
                      backgroundColor: globals.currentTheme.isDark()
                          ? Colors.redAccent
                          : Colors.red.shade700,
                    ),
                  }[globals.user.presence[i]['type']]),
                ),
                Visibility(
                  visible: globals.user.presence[i]['zoom'] != '',
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 32,
                        left: widget.inSidePanel != null ? 16 : 48,
                        right: widget.inSidePanel != null ? 16 : 48),
                    child: ProgressButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          'ZOOM',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      onPressed: () async {
                        String url = globals.user.presence[i]['zoom'];
                        if (await canLaunch(url)) {
                          await launch(url, forceSafariVC: false);
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
                  visible: globals.user.presence[i]['zoom_pwd'] != '',
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 12,
                        left: widget.inSidePanel != null ? 16 : 48,
                        right: widget.inSidePanel != null ? 16 : 48),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: '${'password'.tr()} : ',
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                                text: globals.user.presence[i]['zoom_pwd'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    padding = 0.0;
    if (widget.inSidePanel == null) {
      if (MediaQuery.of(context).size.width > 1000) {
        padding = MediaQuery.of(context).size.width * 0.13;
      } else if (MediaQuery.of(context).size.width > 800) {
        padding = MediaQuery.of(context).size.width * 0.1;
      } else if (MediaQuery.of(context).size.width > 600) {
        padding = MediaQuery.of(context).size.width * 0.08;
      }
    }

    if (show) {
      return (globals.user.presence.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: pageGen(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 62,
                      left: 8,
                      right: 8,
                      bottom: 12.0 +
                          (MediaQuery.of(context).size.width > 1000 ? 32 : 0)),
                  child: SmoothPageIndicator(
                      controller: _pageController, // PageController
                      count: globals.user.presence.length,
                      effect: WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          activeDotColor: Theme.of(context)
                              .accentColor), // your preferred effect
                      onDotClicked: (index) {
                        _pageController.jumpToPage(index);
                      }),
                )
              ],
            )
          : CupertinoScrollbar(
              child: SmartRefresher(
                enablePullDown: true,
                header: ClassicHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView(
                  shrinkWrap: false,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 62, left: 8, right: 8),
                      child: Center(
                        child: Text('no_class',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline2)
                            .tr(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 52),
                      child: Container(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/free.svg',
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
    } else {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
  }
}
