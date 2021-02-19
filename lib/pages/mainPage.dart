import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:devinci/extra/devinci_icons_icons.dart';
import 'package:devinci/pages/agenda.dart';
import 'package:devinci/pages/presence.dart';
import 'package:devinci/pages/salles.dart';
import 'package:devinci/pages/settings.dart';
import 'package:devinci/pages/ui/absences.dart';
import 'package:devinci/pages/ui/notes.dart';
import 'package:devinci/pages/ui/user.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_context/one_context.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:easy_localization/easy_localization.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:provider/provider.dart';
import 'package:devinci/extra/classes.dart';

class ShowCasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onStart: (index, key) {
        print('onStart: $index, $key');
      },
      onComplete: (index, key) {
        print('onComplete: $index, $key');
      },
      builder:
          Builder(builder: (context) => MainPage(key: globals.mainPageKey)),
      autoPlay: false,
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var title = globals.user.data['name'];

  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() {
      setState(() {});
    });
  }

  var _pageController = PageController();

  var lastWidth = 0.0;

  List<Widget> pages() {
    var res = <Widget>[
      AgendaPage(),
      NotesPage(key: globals.notesPageKey),
      AbsencesPage(key: globals.absencesPageKey),
      PresencePage(),
      UserPage(key: globals.userPageKey)
    ];
    return res;
  }

  List<BottomNavigationBarItem> bottomIcons() {
    var res = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(
            globals.selectedPage == 0 ? Icons.today : Icons.today_outlined),
        label: 'time_schedule'.tr(),
      ),
      BottomNavigationBarItem(
        icon: Icon(globals.selectedPage == 1
            ? Icons.assignment
            : Icons.assignment_outlined),
        label: 'grades'.tr(),
      ),
      BottomNavigationBarItem(
        icon: Icon(globals.selectedPage == 2
            ? Icons.watch_later
            : Icons.watch_later_outlined),
        label: 'absences'.tr(),
      ),
      BottomNavigationBarItem(
        icon: Icon(globals.selectedPage == 3
            ? DevinciIcons.megaphone_filled
            : DevinciIcons.megaphone_outlined),
        label: 'attendance'.tr(),
      ),
      BottomNavigationBarItem(
        icon: Icon(
            globals.selectedPage == 4 ? Icons.person : Icons.person_outlined),
        //,
        label: globals.user.data['name'],
      ),
    ];
    // if (Config.admin_id.isNotEmpty) {
    //   if (globals.user.tokens['uids'] == Config.admin_id) {
    //     res.add(BottomNavigationBarItem(
    //       icon: Icon(globals.selectedPage == 5
    //           ? Icons.admin_panel_settings
    //           : Icons.admin_panel_settings_outlined),
    //       //,
    //       label: 'admin'.tr(),
    //     ));
    //   }
    // }
    return res;
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
    if (globals.selectedPage > 4 && MediaQuery.of(context).size.width <= 1000) {
      globals.selectedPage = 4;
    }
    _pageController = PageController(initialPage: globals.selectedPage);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: globals.mainScaffoldKey,
        appBar: AppBar(
            elevation: 0.0,
            brightness: MediaQuery.of(context).platformBrightness,
            centerTitle: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              title,
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: <Widget>[
              [
                Showcase.withWidget(
                  key: globals.showcase_add,
                  // description: ,
                  container: Container(
                      width: 200,
                      child: Text(
                        'showcase_add'.tr(),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                  height: 200,
                  width: 200,
                  child: IconButton(
                    icon: IconTheme(
                      data: Theme.of(context).accentIconTheme,
                      child: Icon(Icons.add_outlined),
                    ),
                    onPressed: () async {
                      await OneContext().push(MaterialPageRoute(
                          builder: (_) => CoursEditor(
                                addButton: true,
                              )));
                      // await Navigator.push<Widget>(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (BuildContext context) => CoursEditor(
                      //             addButton: true,
                      //           )),
                      // );
                    },
                  ),
                ),
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
                MediaQuery.of(context).size.width > 1000
                    ? SizedBox.shrink()
                    : IconButton(
                        icon: IconTheme(
                          data: Theme.of(context).accentIconTheme,
                          child: Icon(Icons.settings_outlined),
                        ),
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => SettingsPage(
                                    scrollController:
                                        ModalScrollController.of(context),
                                  ));
                        },
                      ),
                SizedBox.shrink(),
                SizedBox.shrink(),
              ].elementAt(globals.selectedPage),
              [
                Showcase.withWidget(
                  key: globals.showcase_today,
                  container: Container(
                      width: 200,
                      child: Text(
                        'showcase_today'.tr(),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                  height: 200,
                  width: 200,
                  child: IconButton(
                    icon: IconTheme(
                      data: Theme.of(context).accentIconTheme,
                      child: Icon(Icons.today_outlined),
                    ),
                    onPressed: () async {
                      globals.calendarController.displayDate = DateTime.now();
                    },
                  ),
                ),
                globals.isLoading.state(1)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: CupertinoActivityIndicator(),
                      )
                    : SizedBox.shrink(),
                globals.isLoading.state(2)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: CupertinoActivityIndicator(),
                      )
                    : SizedBox.shrink(),
                SizedBox.shrink(),
                globals.isLoading.state(4)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: CupertinoActivityIndicator(),
                      )
                    : SizedBox.shrink(),
                globals.isLoading.state(5)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: CupertinoActivityIndicator(),
                      )
                    : SizedBox.shrink(),
                SizedBox.shrink(),
              ].elementAt(globals.selectedPage),
              [
                MediaQuery.of(context).size.width > 1000
                    ? Row(
                        children: [
                          IconButton(
                            icon: IconTheme(
                              data: Theme.of(context).accentIconTheme,
                              child: Icon(Icons.refresh_rounded),
                            ),
                            onPressed: () async {
                              await OneContext().push(MaterialPageRoute(
                                  builder: (_) => CoursEditor(
                                        addButton: true,
                                      )));
                              // await Navigator.push<Widget>(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (BuildContext context) =>
                              //           CoursEditor(
                              //             addButton: true,
                              //           )),
                              // );
                            },
                          ),
                          MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? SizedBox.shrink()
                              : IconButton(
                                  icon: IconTheme(
                                    data: Theme.of(context).accentIconTheme,
                                    child: Icon(globals.showSidePanel
                                        ? Icons.view_sidebar_rounded
                                        : Icons.view_sidebar_outlined),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      globals.showSidePanel =
                                          !globals.showSidePanel;
                                      globals.prefs.setBool('showSidePanel',
                                          globals.showSidePanel);
                                    });
                                  },
                                ),
                        ],
                      )
                    : Showcase.withWidget(
                        key: globals.showcase_moreMenu,
                        container: Container(
                            width: 200,
                            child: Text(
                              'showcase_more_menu'.tr(),
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.right,
                            )),
                        height: 200,
                        width: 200,
                        child: PopupMenuButton(
                          //captureInheritedThemes: true,
                          icon: IconTheme(
                            data: Theme.of(context).accentIconTheme,
                            child: Icon(Icons.more_vert_outlined),
                          ),
                          onSelected: (String choice) {
                            if (choice == 'refresh') {
                              globals.isLoading.setState(0, true);
                            } else if (choice == 'free_room') {
                              OneContext().push(CupertinoPageRoute(
                                  builder: (_) => SallesPage()));
                              // Navigator.push(
                              //   context,
                              //   CupertinoPageRoute(
                              //     builder: (context) => SallesPage(),
                              //   ),
                              // );
                            } else {
                              setState(() {
                                if (globals.calendarView == CalendarView.day) {
                                  globals.calendarView = CalendarView.workWeek;
                                  globals.prefs
                                      .setBool('calendarViewDay', false);
                                  globals.calendarController.view =
                                      CalendarView.workWeek;
                                } else {
                                  globals.calendarView = CalendarView.day;
                                  globals.prefs
                                      .setBool('calendarViewDay', true);
                                  globals.calendarController.view =
                                      CalendarView.day;
                                }
                              });
                            }
                          },
                          padding: EdgeInsets.zero,
                          // initialValue: choices[_selection],
                          itemBuilder: (BuildContext context) {
                            return [
                              globals.calendarView == CalendarView.day
                                  ? 'week'
                                  : 'day',
                              'refresh',
                              'free_room'
                            ].map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice).tr(),
                              );
                            }).toList();
                          },
                        ),
                      ),
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
              ].elementAt(globals.selectedPage),
              globals.selectedPage == 0
                  ? globals.isConnected
                      ? (globals.isLoading.state(0)
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: CupertinoActivityIndicator(),
                            )
                          : SizedBox.shrink())
                      : SizedBox.shrink()
                  : SizedBox.shrink(),
              if (globals.isConnected)
                SizedBox.shrink()
              else
                IconButton(
                  icon: IconTheme(
                    data: Theme.of(context).accentIconTheme,
                    child: Icon(Icons.offline_bolt),
                  ),
                  onPressed: () {
                    final snackBar =
                        SnackBar(content: Text('offline_msg').tr());

                    try {
                      showSnackBar(snackBar);
                      // ignore: empty_catches
                    } catch (exception, stacktrace) {
                      FLog.logThis(
                          className: 'MainPageState',
                          methodName: 'build',
                          text: 'exception',
                          type: LogLevel.ERROR,
                          exception: Exception(exception),
                          stacktrace: stacktrace);
                    }
                  },
                ),
            ],
            automaticallyImplyLeading: false),
        body: LayoutBuilder(builder: (context, constraints) {
          Widget DrawerTile(
              String title, IconData icon, IconData selectedIcon, index,
              {dynamic callback}) {
            callback ??= () {
              setState(() {
                globals.selectedPage = index;
                _pageController.jumpToPage(
                  globals.selectedPage,
                );
              });
            };
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: globals.selectedPage == index
                    ? (CustomTheme.instanceOf(context).isDark()
                        ? Colors.grey.withAlpha(50)
                        : Theme.of(context).primaryColor.withAlpha(35))
                    : Colors.transparent,
                shape: SquircleBorder(
                  radius: BorderRadius.all(Radius.circular(25)),
                ),
                child: ListTile(
                  shape: SquircleBorder(
                    radius: BorderRadius.all(Radius.circular(25)),
                  ),
                  leading: Icon(
                      globals.selectedPage == index ? selectedIcon : icon,
                      color: globals.selectedPage == index
                          ? Theme.of(context).accentColor
                          : Theme.of(context).textTheme.bodyText1.color),
                  title: Text(title,
                          style: TextStyle(
                              color: globals.selectedPage == index
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color))
                      .tr(),
                  selected: globals.selectedPage == index,
                  onTap: callback,
                ),
              ),
            );
          }

          if (constraints.maxWidth > 1000) {
            globals.calendarView = CalendarView.workWeek;
            return Container(
              child: Row(children: <Widget>[
                Container(
                    width: 250 + 0.3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        right: BorderSide(
                            width: 0.3,
                            color: Theme.of(context)
                                .textTheme
                                .headline1
                                .color
                                .withAlpha(110)),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 16),
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          DrawerTile('time_schedule', Icons.today_outlined,
                              Icons.today_rounded, 0),
                          DrawerTile('grades', Icons.assignment_outlined,
                              Icons.assignment_rounded, 1),
                          DrawerTile('absences', Icons.watch_later_outlined,
                              Icons.watch_later_rounded, 2),
                          DrawerTile(
                              'attendance',
                              DevinciIcons.megaphone_outlined,
                              DevinciIcons.megaphone_filled,
                              3),
                          DrawerTile(globals.user.data['name'],
                              Icons.person_outlined, Icons.person_rounded, 4),
                          Divider(
                            height: 16,
                            thickness: 1,
                          ),
                          DrawerTile('free_room', Icons.meeting_room_outlined,
                              Icons.meeting_room_rounded, 5),
                          DrawerTile(
                            'settings',
                            Icons.settings_outlined,
                            Icons.settings_rounded,
                            6,
                          ),
                        ],
                      ),
                    )),
                Container(
                  width: MediaQuery.of(context).orientation ==
                              Orientation.landscape &&
                          globals.showSidePanel &&
                          globals.selectedPage == 0
                      ? MediaQuery.of(context).size.width * 0.80 - 250 - 0.6
                      : MediaQuery.of(context).size.width - 250 - 0.3,
                  child: PageView(
                      children: List<Widget>.from(pages())
                        ..addAll([SallesPage(tablet: true), SettingsPage()]),
                      onPageChanged: (index) {
                        setState(() {
                          globals.selectedPage = index;
                        });
                      },
                      controller: _pageController),
                ),
                MediaQuery.of(context).orientation == Orientation.landscape &&
                        globals.showSidePanel &&
                        globals.selectedPage == 0
                    ? (Container(
                        width: MediaQuery.of(context).size.width * 0.20 + 0.3,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                                width: 0.3,
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .color
                                    .withAlpha(110)),
                          ),
                        ),
                        child: PresencePage(
                          inSidePanel: true,
                        ),
                      ))
                    : SizedBox.shrink()
              ]),
            );
          } else {
            return PageView(
                children: pages(),
                onPageChanged: (index) {
                  setState(() {
                    globals.selectedPage = index;
                  });
                },
                controller: _pageController);
          }
        }),
        bottomNavigationBar: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 1000) {
            return SizedBox.shrink();
          } else {
            return Theme(
              data: Theme.of(context).copyWith(
                // sets the background color of the `BottomNavigationBar`
                canvasColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: BottomNavigationBar(
                  items: bottomIcons(),
                  currentIndex: globals.selectedPage,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  selectedItemColor: Theme.of(context).indicatorColor,
                  unselectedItemColor: Theme.of(context).unselectedWidgetColor,
                  onTap: (index) {
                    setState(() {
                      globals.selectedPage = index;
                      _pageController.animateToPage(globals.selectedPage,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.linear);
                    });
                  }),
            );
          }
        }),
      ),
    );
  }
}
