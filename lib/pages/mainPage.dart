import 'package:devinci/extra/devinci_icons_icons.dart';
import 'package:devinci/pages/agenda.dart';
import 'package:devinci/pages/presence.dart';
import 'package:devinci/pages/salles.dart';
import 'package:devinci/pages/settings.dart';
import 'package:devinci/pages/ui/absences.dart';
import 'package:devinci/pages/ui/notes.dart';
import 'package:devinci/pages/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:easy_localization/easy_localization.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() {
      setState(() {});
    });
  }

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        globals.currentTheme.isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        globals.currentTheme.isDark());
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            elevation: 0.0,
            brightness: MediaQuery.of(context).platformBrightness,
            centerTitle: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              globals.user.data['name'],
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: <Widget>[
              [
                IconButton(
                  icon: IconTheme(
                    data: Theme.of(context).accentIconTheme,
                    child: Icon(OMIcons.add),
                  ),
                  onPressed: () async {
                    await Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CoursEditor(
                                addButton: true,
                              )),
                    );
                  },
                ),
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
                IconButton(
                  icon: IconTheme(
                    data: Theme.of(context).accentIconTheme,
                    child: Icon(OMIcons.settings),
                  ),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context, scrollController) => SettingsPage(
                              scrollController: scrollController,
                            ));
                  },
                ),
              ].elementAt(globals.selectedPage),
              [
                IconButton(
                  icon: IconTheme(
                    data: Theme.of(context).accentIconTheme,
                    child: Icon(OMIcons.today),
                  ),
                  onPressed: () async {
                    globals.calendarController.displayDate = DateTime.now();
                  },
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
                    : SizedBox.shrink()
              ].elementAt(globals.selectedPage),
              globals.selectedPage == 0
                  ? PopupMenuButton(
                      captureInheritedThemes: true,
                      icon: IconTheme(
                        data: Theme.of(context).accentIconTheme,
                        child: Icon(OMIcons.moreVert),
                      ),
                      onSelected: (String choice) {
                        if (choice == 'refresh') {
                          globals.isLoading.setState(0, true);
                        } else if (choice == 'free_room') {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => SallesPage(),
                            ),
                          );
                        } else {
                          setState(() {
                            if (globals.calendarView == CalendarView.day) {
                              globals.calendarView = CalendarView.workWeek;
                              globals.prefs.setBool('calendarViewDay', false);
                              globals.calendarController.view =
                                  CalendarView.workWeek;
                            } else {
                              globals.calendarView = CalendarView.day;
                              globals.prefs.setBool('calendarViewDay', true);
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
                    )
                  : SizedBox.shrink(),
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
                      Scaffold.of(globals.currentContext)
                          .showSnackBar(snackBar);
                      // ignore: empty_catches
                    } catch (e) {}
                  },
                ),
            ],
            automaticallyImplyLeading: false),
        body: PageView(
            children: <Widget>[
              AgendaPage(),
              NotesPage(key: globals.notesPageKey),
              AbsencesPage(key: globals.absencesPageKey),
              PresencePage(),
              UserPage()
            ],
            onPageChanged: (index) {
              setState(() {
                globals.selectedPage = index;
              });
            },
            controller: _pageController),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                      globals.selectedPage == 0 ? Icons.today : OMIcons.today),
                  label: 'time_schedule'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 1
                      ? Icons.assignment
                      : OMIcons.assignment),
                  label: 'grades'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 2
                      ? Icons.watch_later
                      : OMIcons.watchLater),
                  label: 'absences'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 3
                      ? DevinciIcons.megaphone_filled
                      : DevinciIcons.megaphone_outlined),
                  label: 'attendance'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 4
                      ? Icons.person
                      : OMIcons.person),
                  //,
                  label: globals.user.data['name'],
                ),
              ],
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
        ),
      ),
    );
  }
}
