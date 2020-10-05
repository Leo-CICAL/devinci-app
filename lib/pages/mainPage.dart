import 'package:devinci/extra/devinci_icons_icons.dart';
import 'package:devinci/pages/absences.dart';
import 'package:devinci/pages/agenda.dart';
import 'package:devinci/pages/notes.dart';
import 'package:devinci/pages/presence.dart';
import 'package:devinci/pages/settings.dart';
import 'package:devinci/pages/timechef.dart';
import 'package:devinci/pages/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() {
      setState(() {});
    });
  }

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
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            elevation: 0.0,
            brightness: MediaQuery.of(context).platformBrightness,
            centerTitle: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              globals.user.data["name"],
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: <Widget>[
              <Widget>[
                IconButton(
                  icon: IconTheme(
                    data: Theme.of(context).accentIconTheme,
                    child: Icon(OMIcons.add),
                  ),
                  onPressed: () async {
                    Navigator.push<Widget>(
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
                    child: Icon(OMIcons.add),
                  ),
                  onPressed: () async {
                    const url = 'https://timechef.elior.com/#/recharger';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                      );
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
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
              <Widget>[
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
                        if (choice == "Rafraîchir") {
                          globals.isLoading.setState(0, true);
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
                              ? "Semaine"
                              : "Jour",
                          "Rafraîchir"
                        ].map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
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
              globals.isConnected
                  ? SizedBox.shrink()
                  : IconButton(
                      icon: IconTheme(
                        data: Theme.of(context).accentIconTheme,
                        child: Icon(Icons.offline_bolt),
                      ),
                      onPressed: () {
                        final snackBar =
                            SnackBar(content: Text('Vous êtes hors-ligne'));

                        try {
                          Scaffold.of(globals.currentContext)
                              .showSnackBar(snackBar);
                        } catch (e) {}
                      },
                    ),
            ],
            automaticallyImplyLeading: false),
        body: <Widget>[
          AgendaPage(),
          NotesPage(),
          AbsencesPage(),
          PresencePage(),
          TimeChefPage(),
          UserPage()
        ].elementAt(globals.selectedPage),
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: new BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                      globals.selectedPage == 0 ? Icons.today : OMIcons.today),
                  label: 'EDT',
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 1
                      ? Icons.assignment
                      : OMIcons.assignment),
                  label: 'Notes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 2
                      ? Icons.watch_later
                      : OMIcons.watchLater),
                  label: 'Absences',
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 3
                      ? DevinciIcons.megaphone_filled
                      : DevinciIcons.megaphone_outlined),
                  label: 'Présence',
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 4
                      ? Icons.restaurant
                      : OMIcons.restaurant),
                  label: 'Restaurant',
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 5
                      ? Icons.person
                      : OMIcons.person),
                  //,
                  label: globals.user.data["name"],
                ),
              ],
              currentIndex: globals.selectedPage,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: Theme.of(context).indicatorColor,
              unselectedItemColor: Theme.of(context).unselectedWidgetColor,
              onTap: (index) {
                setState(() {
                  globals.selectedPage = index;
                });
              }),
        ),
      ),
    );
  }
}
