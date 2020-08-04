import 'package:badges/badges.dart';
import 'package:devinci/extra/devinci_icons_icons.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/pages/absences.dart';
import 'package:devinci/pages/agenda.dart';
import 'package:devinci/pages/notes.dart';
import 'package:devinci/pages/settings.dart';
import 'package:devinci/pages/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:devinci/extra/globals.dart' as globals;

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CalendarView calendarView = CalendarView.month;

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
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
                    child: Icon(
                        globals.agendaView.calendarView == CalendarView.day
                            ? OMIcons.dateRange
                            : Icons.date_range),
                  ),
                  onPressed: () {
                    setState(() {
                      if (globals.agendaView.calendarView == CalendarView.day)
                        globals.agendaView.calendarView = CalendarView.month;
                      else
                        globals.agendaView.calendarView = CalendarView.day;
                    });
                  },
                ),
                Text(""),
                Text(""),
                Text(""),
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

// Find the Scaffold in the widget tree and use it to show a SnackBar.
                        Scaffold.of(globals.currentContext)
                            .showSnackBar(snackBar);
                      },
                    ),
            ],
            automaticallyImplyLeading: false),
        body: <Widget>[
          AgendaPage(),
          NotesPage(),
          AbsencesPage(),
          Container(
            child: Center(
              child: Text("Non disponible pour le moment"),
            ),
          ),
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
                  title: Text('EDT'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 1
                      ? Icons.assignment
                      : OMIcons.assignment),
                  title: Text('Notes'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 2
                      ? Icons.watch_later
                      : OMIcons.watchLater),
                  title: Text('Absences'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(globals.selectedPage == 3
                      ? DevinciIcons.megaphone_filled
                      : DevinciIcons.megaphone_outlined),
                  title: Text('Présence'),
                ),
                BottomNavigationBarItem(
                  icon: globals.showUserBadge && globals.selectedPage != 4
                      ? Badge(
                          shape: BadgeShape.circle,
                          borderRadius: 100,
                          child: Icon(globals.selectedPage == 4
                              ? Icons.person
                              : OMIcons.person),
                          badgeContent: Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                        )
                      : Icon(globals.selectedPage == 4
                          ? Icons.person
                          : OMIcons.person),
                  //,
                  title: Text(globals.user.data["name"]),
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
