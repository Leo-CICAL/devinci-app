import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart'; //for date locale

import 'package:devinci/extra/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Function setAgendaHeaderState;

class AgendaHeader extends StatefulWidget {
  AgendaHeader({Key key}) : super(key: key);
  @override
  _AgendaHeaderState createState() => _AgendaHeaderState();
}

class _AgendaHeaderState extends State<AgendaHeader> {
  _AgendaHeaderState();

  void initState() {
    setAgendaHeaderState = setState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TitleSection(globals.agendaTitle.headerText,
        padding: const EdgeInsets.only(top: 8.0, left: 16, bottom: 8));
  }
}

class AgendaPage extends StatefulWidget {
  AgendaPage({Key key}) : super(key: key);
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  bool show = false;
  String date;

  _AgendaPageState();

  Future<void> getCalendar() async {
    //print("getCalendar");
    //throw Exception("test");
    if (globals.lastFetchAgenda == null) {
      globals.lastFetchAgenda = DateTime.now();
      String icalUrl = globals.user.data["edtUrl"];
      try {
        globals.cours = await parseIcal(icalUrl);
      } catch (exception, stacktrace) {
        await reportError(
            "agenda.dart | _AgendaPageState | getCalendar() | parseIcal() => $exception",
            stacktrace);
        return;
      }
      setState(() {
        show = true;
      });
    } else if (DateTime.now().difference(globals.lastFetchAgenda).inMinutes >
        30) {
      globals.lastFetchAgenda = DateTime.now();
      String icalUrl = globals.user.data["edtUrl"];
      try {
        globals.cours = await parseIcal(icalUrl);
      } catch (exception, stacktrace) {
        await reportError(
            "agenda.dart | _AgendaPageState | getCalendar() | parseIcal() | after 30 min => $exception",
            stacktrace);
        return;
      }
      setState(() {
        show = true;
      });
    } else {
      setState(() {
        show = true;
      });
    }
    return;
  }

  void initState() {
    Intl.defaultLocale = "fr_FR";
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => getCalendar());
  }

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;

    return show
        ? Column(children: <Widget>[
            AgendaHeader(),
            PropertyChangeProvider(
              value: globals.agendaView,
              child: PropertyChangeConsumer<globals.AgendaView>(
                  properties: ['calendarView'],
                  builder: (context, model, properties) {
                    return Expanded(
                      child: SfCalendar(
                        view: globals.agendaView.calendarView,
                        monthViewSettings: MonthViewSettings(showAgenda: true),
                        dataSource: MeetingDataSource(globals.cours),
                        headerHeight: 0,
                        timeSlotViewSettings: TimeSlotViewSettings(
                          startHour: 7,
                          endHour: 23,
                          nonWorkingDays: <int>[DateTime.sunday],
                          timeFormat: 'h:mm',
                        ),
                        firstDayOfWeek: 1,
                        selectionDecoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3)),
                          shape: BoxShape.rectangle,
                        ),
                        onViewChanged: (ViewChangedDetails viewChangedDetails) {
                          globals.agendaTitle.headerText =
                              DateFormat('MMMM yyyy')
                                  .format(viewChangedDetails.visibleDates[
                                      viewChangedDetails.visibleDates.length ~/
                                          2])
                                  .toString();
                          SchedulerBinding.instance
                              .addPostFrameCallback((duration) {
                            setAgendaHeaderState(() {});
                          });
                        },
                      ),
                    );
                  }),
            )
          ])
        : Center(child: CupertinoActivityIndicator());
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Cours> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}
