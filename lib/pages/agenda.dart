import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:flutter/scheduler.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AgendaPage extends StatefulWidget {
  AgendaPage({Key key}) : super(key: key);
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  bool show = false;

  _AgendaPageState();

  

  Future<void> getCalendar() async {
    //print("getCalendar");
    //throw Exception("test");
    if (globals.lastFetchAgenda == null) {
      globals.lastFetchAgenda = DateTime.now();
      String icalUrl = globals.user.data["edtUrl"];
      try{
        globals.cours = await parseIcal(icalUrl);
      }catch(exception, stacktrace){
        await reportError("agenda.dart | _AgendaPageState | getCalendar() | parseIcal() => $exception", stacktrace);
        return;
      }
      setState(() {
        show = true;
      });
    } else if (DateTime.now().difference(globals.lastFetchAgenda).inMinutes >
        30) {
      globals.lastFetchAgenda = DateTime.now();
      String icalUrl = globals.user.data["edtUrl"];
      try{
      globals.cours = await parseIcal(icalUrl);
      }catch(exception, stacktrace){
        await reportError("agenda.dart | _AgendaPageState | getCalendar() | parseIcal() | after 30 min => $exception", stacktrace);
        return;
      }
      setState(() {
        show = true;
      });
    }else{
      setState(() {
        show = true;
      });
    }
    return;
  }

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => getCalendar());
  }

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;
    
    return show
        ? PropertyChangeProvider(
            value: globals.agendaView,
            child: PropertyChangeConsumer<globals.AgendaView>(
                properties: ['calendarView'],
                builder: (context, model, properties) {
                  return SfCalendar(
                    view: globals.agendaView.calendarView,
                    monthViewSettings: MonthViewSettings(showAgenda: true),
                    dataSource: MeetingDataSource(globals.cours),
                    timeSlotViewSettings: TimeSlotViewSettings(
                      startHour: 7,
                      endHour: 23,
                      nonWorkingDays: <int>[DateTime.sunday],
                      timeFormat: 'h:mm',
                    ),
                    firstDayOfWeek: 1,
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                          color: getColor("text", context), width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      shape: BoxShape.rectangle,
                    ),
                  );
                }))
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
