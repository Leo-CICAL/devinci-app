library my_prj.globals;

import 'package:devinci/libraries/timechef/classes.dart';
import 'package:devinci/libraries/timechef/timechef.dart';
import 'package:devinci/pages/ui/absences.dart';
import 'package:devinci/pages/ui/notes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devinci/extra/classes.dart';

final storage = FlutterSecureStorage();

// We use the database factory to open the database
Database db;
var store = StoreRef<String, dynamic>.main();
User user;
TimeChefUser timeChefUser;

bool asXxMoy = false;

BuildContext currentContext;

String crashConsent;

// class AgendaView extends PropertyChangeNotifier<String> {
//   CalendarView _calendarView = CalendarView.day;

//   CalendarView get calendarView => _calendarView;

//   set calendarView(CalendarView value) {
//     _calendarView = value;
//     notifyListeners('calendarView');
//   }
// }

CalendarView calendarView = CalendarView.workWeek;

class AgendaTitle extends PropertyChangeNotifier<String> {
  String _headerText = '';

  String get headerText => _headerText;

  set headerText(String value) {
    _headerText = value;
    notifyListeners('headerText');
  }
}

String feedbackError = '';
StackTrace feedbackStackTrace = StackTrace.fromString('');
String eventId = '';
String feedbackNotes = '';

final agendaTitle = AgendaTitle();

DateTime lastFetchAgenda;

List<Cours> cours = <Cours>[];

Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

int selectedPage = 0;

SharedPreferences prefs;

bool isConnected = true;

DevinciTheme currentTheme = DevinciTheme();

IsLoading isLoading = IsLoading();

bool noteLocked = false;

PageChanger pageChanger = PageChanger();

List<Cours> customCours = <Cours>[];

bool analyticsConsent = true;

FirebaseAnalytics analytics;

FirebaseAnalyticsObserver observer;

CalendarController calendarController;

bool showRestaurant = false;

//globalkeys
final notesPageKey = GlobalKey<NotesPageState>();
final absencesPageKey = GlobalKey<AbsencesPageState>();
