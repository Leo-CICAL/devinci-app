import 'package:devinci/libraries/flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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

  PageController _pageController = PageController(
    initialPage: 0,
  );

  void runBeforeBuild() async {
    await globals.user.getPresence(force: true);
    if (mounted)
      setState(() {
        show = true;
      });
    if (globals.user.presence.length > 0)
      _pageController.jumpToPage(globals.user.presenceIndex);
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

  List<Widget> pageGen() {
    List<Widget> res = new List<Widget>();
    for (int i = 0; i < globals.user.presence.length; i++) {
      res.add(CupertinoScrollbar(
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
                      globals.user.presence[i]['type'] == 'none'
                          ? 'Pas de cours prévu.'
                          : globals.user.presence[i]["title"],
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Center(
                  child: Text(
                      globals.user.presence[i]['type'] == 'none' ? '' : "—",
                      style: Theme.of(context).textTheme.headline2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Center(
                  child: Text(
                      globals.user.presence[i]['type'] == 'none'
                          ? ''
                          : (globals.user.presence[i]["prof"] == ''
                              ? globals.user.presence[i]["horaires"]
                              : globals.user.presence[i]["prof"]),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
              globals.user.presence[i]["prof"] != ''
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                            globals.user.presence[i]['type'] == 'none'
                                ? ''
                                : globals.user.presence[i]["horaires"],
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                    )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.only(top: 112, left: 48, right: 48),
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
                        await globals.user.setPresence(i);
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
                }[globals.user.presence[i]["type"]]),
              ),
              Visibility(
                visible: globals.user.presence[i]['zoom'] != '',
                child: Padding(
                  padding: const EdgeInsets.only(top: 32, left: 48, right: 48),
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
                      String url = globals.user.presence[i]['zoom'];
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
                visible: globals.user.presence[i]['zoom_pwd'] != '',
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 48, right: 48),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Mot de passe : ',
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
      ));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? (globals.user.presence.length > 0
            ? Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: pageGen(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 62, left: 8, right: 8, bottom: 12),
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
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 62, left: 8, right: 8),
                        child: Center(
                          child: Text('Pas de cours prévu.',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 52),
                        child: Container(
                          height: 200,
                          width: 200,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/free.svg",
                              color:
                                  Theme.of(context).textTheme.bodyText1.color,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }
}
