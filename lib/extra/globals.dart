library my_prj.globals;

import 'package:devinci/libraries/admin/admin.dart';
import 'package:devinci/libraries/timechef/classes.dart';
import 'package:devinci/libraries/timechef/timechef.dart';
import 'package:devinci/pages/mainPage.dart';
import 'package:devinci/pages/ui/absences.dart';
import 'package:devinci/pages/ui/login.dart';
import 'package:devinci/pages/ui/notes.dart';
import 'package:devinci/pages/ui/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devinci/extra/classes.dart';

final storage = FlutterSecureStorage();

// We use the database factory to open the database
Database db;
var store = StoreRef<String, dynamic>.main();
Student user;
TimeChefUser timeChefUser;

bool asXxMoy = false;

BuildContext currentContext;

String crashConsent;

bool notifConsent;

CalendarView calendarView = CalendarView.workWeek;

bool showSidePanel = false;

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

CalendarController calendarController;

bool showRestaurant = false;

//globalkeys
final notesPageKey = GlobalKey<NotesPageState>();
final absencesPageKey = GlobalKey<AbsencesPageState>();
final mainPageKey = GlobalKey<MainPageState>();
final mainScaffoldKey = GlobalKey<ScaffoldState>();
final adminPageKey = GlobalKey<AdminPageState>();
final loginPageKey = GlobalKey<LoginPageState>();
final userPageKey = GlobalKey<UserPageState>();

String release = '';

GlobalKey showcase_add = GlobalKey();
GlobalKey showcase_today = GlobalKey();
GlobalKey showcase_moreMenu = GlobalKey();
GlobalKey showcase_addCalendar = GlobalKey();
GlobalKey showcase_selectSemester = GlobalKey();
