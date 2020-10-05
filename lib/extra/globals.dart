library my_prj.globals;

import 'package:devinci/libraries/timechef/classes.dart';
import 'package:devinci/libraries/timechef/timechef.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devinci/extra/classes.dart';

final storage = new FlutterSecureStorage();

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
  String _headerText = "";

  String get headerText => _headerText;

  set headerText(String value) {
    _headerText = value;
    notifyListeners('headerText');
  }
}

String feedbackError = "";
StackTrace feedbackStackTrace = StackTrace.fromString("");
String eventId = "";
String feedbackNotes = "";

final agendaTitle = AgendaTitle();

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

//local notification part

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'eu.araulin.devinci.notifications',
    'Notifications',
    'Permet de recevoir des notifications lors de mise à jour de l\'application ou lorsque de nouvelles notes sont détéctées.',
    importance: Importance.max,
    priority: Priority.high,
    channelShowBadge: true,
    ticker: 'ticker');

var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String title, String body, String payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id, title: title, body: body, payload: payload));
    });

var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

var iOSPlatformChannelSpecifics =
    IOSNotificationDetails(badgeNumber: 1, presentBadge: true);
var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

bool showUserBadge = false;

int selectedPage = 0;

SharedPreferences prefs;

bool isConnected = true;

DevinciTheme currentTheme = DevinciTheme();

IsLoading isLoading = IsLoading();

bool noteLocked = false;

PageChanger pageChanger = new PageChanger();

List<Cours> customCours = new List<Cours>();

bool analyticsConsent = true;

FirebaseAnalytics analytics;

FirebaseAnalyticsObserver observer;

CalendarController calendarController;
