library my_prj.globals;



import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sentry/sentry.dart' as Sentry;

final Sentry.SentryClient sentry = Sentry.SentryClient(dsn: "https://d90bf661f0ef48d29264be594b6ad954@o400644.ingest.sentry.io/5279681");

final storage = new FlutterSecureStorage();

User user;

bool asXxMoy = false;

BuildContext currentContext;

String crashConsent;


class AgendaView extends PropertyChangeNotifier<String> {
  CalendarView _calendarView = CalendarView.day;

  CalendarView get calendarView => _calendarView;

  set calendarView(CalendarView value) {
    _calendarView = value;
    notifyListeners('calendarView');
  }
}

String feedbackError = "";
StackTrace feedbackStackTrace = StackTrace.fromString("");
String eventId = "";
String feedbackNotes = "";


final agendaView = AgendaView();

DateTime lastFetchAgenda;

List<Cours> cours = new List<Cours>();

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